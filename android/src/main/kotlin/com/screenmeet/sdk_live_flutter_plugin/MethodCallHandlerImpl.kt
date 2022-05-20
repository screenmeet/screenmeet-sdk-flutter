package com.screenmeet.sdk_live_flutter_plugin

import android.app.Activity
import android.app.Application
import android.content.Context
import android.graphics.*
import com.screenmeet.sdk.*
import com.screenmeet.sdk.domain.entity.ChatMessage
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.challengeSolution
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.changeVideoSourceCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.collectMetrics
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.connectCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.connectRoomId
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.disconnectCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.featureGrantAccessCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.featureRejectAccessCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.featureType
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.getLocalVideoCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.getMediaStateCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.getParticipantsCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.height
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.id
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.logLevel
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.organizationKey
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.setConfidentialCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.setConfigCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.shareAudioCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.shareScreenCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.shareScreenWithImageTransfer
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.shareVideoCameraType
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.shareVideoCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.solveChallenge
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.stopSharingAudioCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.stopSharingVideoCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.unsetConfidentialCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.width
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.x
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.y
import com.screenmeet.sdk_live_flutter_plugin.handlers.*
import com.screenmeet.sdk_live_flutter_plugin.utils.AnyThreadResult
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.view.TextureRegistry
import org.webrtc.VideoTrack

typealias FeatureRequestResult = (granted: Boolean) -> Unit

class MethodCallHandlerImpl internal constructor(
    private val context: Context,
    messenger: BinaryMessenger,
    private val textureRegistry: TextureRegistry
) : MethodCallHandler, SessionEventListener {

    private val connectionStateEventChannel =    "platform_channel_events/screenmeet/connectionState"
    private val remoteParticipantsEventChannel = "platform_channel_events/screenmeet/remoteParticipants"
    private val localMediaStateEventChannel =    "platform_channel_events/screenmeet/localMediaState"
    private val localVideoEventChannel =         "platform_channel_events/screenmeet/localVideo"
    private val remoteControlEventChannel =      "platform_channel_events/screenmeet/remoteControl"
    private val featureRequestEventChannel =     "platform_channel_events/screenmeet/featureRequest"
    private val imageTransferEventChannel =      "platform_channel_events/screenmeet/imageTransfer"

    private var connectionStateChannel: EventChannel
    private var localMediaStateChannel: EventChannel
    private var remoteParticipantChannel: EventChannel
    private var localVideoChannel: EventChannel
    private var remoteControlChannel: EventChannel
    private var featureRequestChannel: EventChannel
    private var imageTransferChannel: BasicMessageChannel<Any>

    private var connectionStreamHandler: ConnectionStreamHandler
    private var localMediaStateStreamHandler: LocalMediaStateStreamHandler
    private var participantsStreamHandler: ParticipantsStreamHandler
    private var localVideoStreamHandler: LocalVideoStreamHandler
    private var remoteControlStreamHandler: RemoteControlStreamHandler
    private var featureRequestStreamHandler: FeatureRequestStreamHandler
    private var imageTransferStreamHandler: ImageTransferStreamHandler<Any>

    private var localRenderer: FlutterRTCVideoRenderer? = null
    private var localVideoTrack: VideoTrack? = null

    private val renderers = mutableMapOf<String, FlutterRTCVideoRenderer>()
    private val featureRequestCallbacks = mutableMapOf<String, FeatureRequestResult>()

    private var challenge: Challenge? = null
    private var connectResult: AnyThreadResult? = null

    private var flutterDelegate: FlutterDelegate = FlutterDelegate()

    var activity: Activity? = null

    init {
        connectionStateChannel = EventChannel(messenger, connectionStateEventChannel).apply {
            connectionStreamHandler = ConnectionStreamHandler()
            setStreamHandler(connectionStreamHandler)
        }
        remoteParticipantChannel = EventChannel(messenger, remoteParticipantsEventChannel).apply {
            participantsStreamHandler = ParticipantsStreamHandler()
            setStreamHandler(participantsStreamHandler)
        }
        localVideoChannel = EventChannel(messenger, localVideoEventChannel).apply {
            localVideoStreamHandler = LocalVideoStreamHandler()
            setStreamHandler(localVideoStreamHandler)
        }
        localMediaStateChannel = EventChannel(messenger, localMediaStateEventChannel).apply {
            localMediaStateStreamHandler = LocalMediaStateStreamHandler()
            setStreamHandler(localMediaStateStreamHandler)
        }
        remoteControlChannel = EventChannel(messenger, remoteControlEventChannel).apply {
            remoteControlStreamHandler = RemoteControlStreamHandler()
            setStreamHandler(remoteControlStreamHandler)
        }
        featureRequestChannel = EventChannel(messenger, featureRequestEventChannel).apply {
            featureRequestStreamHandler = FeatureRequestStreamHandler()
            setStreamHandler(featureRequestStreamHandler)
        }

        imageTransferChannel = BasicMessageChannel(
            messenger,
            imageTransferEventChannel,
            StandardMessageCodec.INSTANCE
        ).apply {
            imageTransferStreamHandler = ImageTransferStreamHandler(flutterDelegate)
            setMessageHandler(imageTransferStreamHandler)
        }
    }

    override fun onMethodCall(call: MethodCall, notSafeResult: MethodChannel.Result) {
        val result = AnyThreadResult(notSafeResult)
        when (call.method) {
            setConfigCommand -> setConfig(call, result)
            connectCommand -> connect(call, result)
            solveChallenge -> solveChallenge(call, result)
            disconnectCommand -> {
                ScreenMeet.disconnect()
                clearTextures()
                result.successful()
            }
            shareScreenCommand -> {
                ScreenMeet.shareScreen()
                result.successful()
            }
            shareScreenWithImageTransfer -> {
                ScreenMeet.shareScreen()
                result.successful()
            }
            shareVideoCommand -> { handleShareVideoCommand(call, result) }
            stopSharingVideoCommand -> {
                ScreenMeet.stopVideoSharing()
                result.successful()
            }
            shareAudioCommand -> {
                ScreenMeet.shareAudio()
                result.successful()
            }
            stopSharingAudioCommand -> {
                ScreenMeet.stopAudioSharing()
                result.successful()
            }
            getMediaStateCommand -> {
                val mediaState = ScreenMeet.localMediaState()
                result.successful(zipMediaState(mediaState))
            }
            getLocalVideoCommand -> {
                val mediaState = ScreenMeet.localMediaState()
                handleTextureForLocalVideo(mediaState)
                val textureId = localRenderer?.textureId ?: -1L
                result.successful(zipLocalVideo(mediaState, textureId))
            }
            getParticipantsCommand -> {
                val participants = ScreenMeet.participants()
                handleTexturesForRemoteParticipants(participants)
                result.successful(zipParticipants(participants, renderers))
            }
            setConfidentialCommand -> { setConfidential(call) }
            unsetConfidentialCommand -> { unsetConfidential(call) }
            changeVideoSourceCommand -> { changeVideoSource(result) }
            featureGrantAccessCommand -> { handleFeatureAccessCommand(call, result,true) }
            featureRejectAccessCommand -> { handleFeatureAccessCommand(call, result,false) }
            else -> result.notImplemented()
        }
    }

    private fun setConfig(call: MethodCall, result: AnyThreadResult) {
        val organizationKey: String? = call.argument(organizationKey)
        //val endpoint: String? = call.argument(endpoint)
        val collectMetrics: Boolean = call.argument(collectMetrics) ?: true
        val logLevel: String? = call.argument(logLevel)

        if(organizationKey != null && organizationKey.isNotBlank()){
            val configuration = ScreenMeet.Configuration(organizationKey)
            configuration.collectMetrics(collectMetrics)
            when(logLevel){
                "info" -> ScreenMeet.Configuration.LogLevel.INFO
                "debug" -> ScreenMeet.Configuration.LogLevel.DEBUG
                "error" -> ScreenMeet.Configuration.LogLevel.ERROR
                else -> null
            }?.let { configuration.logLevel(it) }

            ScreenMeet.init(context, configuration)
            ScreenMeet.setFlutterDelegate(flutterDelegate)
            (context as Application).registerActivityLifecycleCallbacks(ScreenMeet.activityLifecycleCallback())
            activity?.let { ScreenMeet.setContext(it) }
            result.successful()
        } else result.error("OrganizationKey can not be empty!", errorCodeWrongMethodParameters)
    }

    private fun connect(call: MethodCall, result: AnyThreadResult) {
        val code: String? = call.argument(connectRoomId)
        //val userName: String? = call.argument(connectUserName)

        code ?: run {
            result.error("Parameters for this channel method are wrong", errorCodeWrongMethodParameters)
            return
        }
        connectResult = result
        ScreenMeet.registerEventListener(this)
        ScreenMeet.connect(code, object : CompletionHandler {
            override fun onSuccess() {
                connectResult?.successful()
            }

            override fun onFailure(error: CompletionError) {
                when (error.code) {
                    ErrorCode.CAPTCHA_ERROR -> {
                        error.challenge?.let {
                            challenge = error.challenge
                            connectResult?.error(error.message, errorCaptchaRequired, zipChallenge(it))
                        } ?: connectResult?.error(error.message, errorCaptchaRequired)
                    }
                    ErrorCode.WAITING_FOR_KNOCK_PERMISSION -> connectResult?.error(error.message, errorKnowEntryPermissionRequired)
                    else -> connectResult?.error(error.message, errorCodeConnectFailed)
                }
            }
        })
    }

    private fun solveChallenge(call: MethodCall, result: AnyThreadResult) {
        val solution: String? = call.argument(challengeSolution)
        solution ?: run {
            result.error("Challenge solution can not be empty", errorCodeWrongMethodParameters)
            return
        }
        connectResult = result
        challenge?.solve(solution) ?: result.error("requested challenge not found. Try again", errorCodeWrongMethodParameters)
    }

    private fun setConfidential(call: MethodCall) {
        try {
            val map = call.arguments as HashMap<*, *>
            val key = map[id] as String
            val x: Double = map[x] as Double
            val y: Double = map[y] as Double
            val width: Double = map[width] as Double
            val height: Double = map[height] as Double
            val r = Rect(x.toInt(), y.toInt(), (x + width).toInt(), (y + height).toInt())
            ScreenMeet.setConfidential(key, r)
        } catch (e: ClassCastException) {
            io.flutter.Log.e("SdkLiveFlutterPlugin", "ClassCastException $e")
        }
    }

    private fun unsetConfidential(call: MethodCall) {
        val args = call.arguments
        if(args is String) ScreenMeet.unsetConfidential(args)
    }

    private fun sendMediaState() {
        val mediaState = ScreenMeet.localMediaState()
        localMediaStateStreamHandler.sendMediaState(mediaState)
    }

    private fun sendLocalVideo() {
        val mediaState = ScreenMeet.localMediaState()
        handleTextureForLocalVideo(mediaState)
        localVideoStreamHandler.sendLocalVideo(mediaState, localRenderer)
    }

    private fun sendParticipants() {
        val participants = ScreenMeet.participants()
        handleTexturesForRemoteParticipants(participants)
        participantsStreamHandler.sendParticipants(participants, renderers)
    }

    private fun handleTextureForLocalVideo(mediaState: ParticipantMediaState) {
        if (mediaState.isVideoActive && mediaState.videoState.cameraEnabled) {
            val entry = textureRegistry.createSurfaceTexture()
            val surfaceTexture = entry.surfaceTexture()
            localRenderer = FlutterRTCVideoRenderer(surfaceTexture, entry, ScreenMeet.eglContext)
            localRenderer?.setVideoTrack(localVideoTrack)
        } else {
            localRenderer?.setVideoTrack(null)
            localRenderer?.dispose()
            localRenderer = null
        }
    }

    private fun handleTexturesForRemoteParticipants(participants: List<Participant>) {
        participants.forEach { participant ->
            if (participant.mediaState.isVideoActive && participant.videoTrack != null) {
                val entry = textureRegistry.createSurfaceTexture()
                val surfaceTexture = entry.surfaceTexture()
                val renderer = FlutterRTCVideoRenderer(surfaceTexture, entry, null)
                renderers[participant.id] = renderer
                renderer.setVideoTrack(participant.videoTrack)
            } else if (!participant.mediaState.isVideoActive) {
                renderers[participant.id]?.let { renderer ->
                    renderer.setVideoTrack(null)
                    renderer.dispose()
                    renderers.remove(participant.id)
                }
            }
        }
    }

    private fun changeVideoSource(result: AnyThreadResult){
        when(ScreenMeet.localMediaState().videoState.source){
            ScreenMeet.VideoSource.FRONT_CAMERA -> ScreenMeet.shareCamera(false)
            ScreenMeet.VideoSource.BACK_CAMERA -> ScreenMeet.shareCamera(true)
            else -> {}
        }
        result.successful()
    }

    private fun handleShareVideoCommand(call: MethodCall, result: AnyThreadResult) {
        call.argument<String?>(shareVideoCameraType)?.let { cameraType ->
            when(cameraType){
                CameraType.FRONT.type -> {
                    ScreenMeet.shareCamera(true)
                    result.successful()
                }
                CameraType.BACK.type -> {
                    ScreenMeet.shareCamera(false)
                    result.successful()
                }
                else -> result.error(
                    "Parameters for this channel method are wrong. Unknown camera type",
                    errorCodeWrongMethodParameters
                )
            }
        }
    }

    private fun handleFeatureAccessCommand(call: MethodCall, result: AnyThreadResult, granted: Boolean) {
        (call.arguments as? HashMap<*, *>)?.let {
            (it[featureType] as? String)?.let { featureType ->
                featureRequestCallbacks[featureType]?.let { decisionHandler ->
                    decisionHandler(granted)
                } ?: result.error("Parameters for this channel method are wrong. Feature request with given requestor id or type not found", errorCodeWrongMethodParameters)
            } ?: result.error("Parameters for this channel method are wrong. Feature requestor id or feature type", errorCodeWrongMethodParameters)
        } ?: result.error("Parameters for this channel method are wrong", errorCodeWrongMethodParameters)
    }

    private fun clearTextures()  {
        for ((_, renderer) in renderers) {
            renderer.setVideoTrack(null)
            renderer.dispose()
        }
        renderers.clear()
    }

    override fun onActiveSpeakerChanged(participant: Participant) { }

    override fun onConnectionStateChanged(newState: ScreenMeet.ConnectionState) {
        if (newState.state == ScreenMeet.SessionState.DISCONNECTED){
            ScreenMeet.unregisterEventListener(this)
        }
        connectionStreamHandler.sendConnectionState(newState)
    }

    override fun onLocalAudioCreated() {
        sendMediaState()
    }

    override fun onLocalAudioStopped() {
        sendMediaState()
    }

    override fun onLocalVideoCreated(videoTrack: VideoTrack) {
        localVideoTrack = videoTrack
        sendMediaState()
        sendLocalVideo()
    }

    override fun onLocalVideoStopped() {
        localRenderer?.setVideoTrack(null)
        localRenderer?.dispose()
        localVideoTrack = null

        sendMediaState()
        sendLocalVideo()
    }

    override fun onParticipantJoined(participant: Participant) { sendParticipants() }

    override fun onParticipantLeft(participant: Participant) { sendParticipants() }

    override fun onParticipantMediaStateChanged(participant: Participant) { sendParticipants() }

    override fun onChatMessage(chatMessage: ChatMessage) { }

    override fun onFeatureRequest(feature: Feature, decisionHandler: FeatureRequestResult) {
        featureRequestCallbacks[mapEntitlement(feature.entitlement)] = decisionHandler
        featureRequestStreamHandler.sendPermissionRequest(feature)
    }

    override fun onFeatureRequestRejected(entitlement: Entitlement) {
        featureRequestCallbacks.remove(mapEntitlement( entitlement))
        featureRequestStreamHandler.sendFeatureCancel(entitlement)
    }

    override fun onFeatureStarted(feature: Feature) {

    }

    override fun onFeatureStopped(feature: Feature) {

    }

    fun dispose(){ clearTextures() }
}