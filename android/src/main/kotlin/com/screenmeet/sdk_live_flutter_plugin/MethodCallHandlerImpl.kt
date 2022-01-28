package com.screenmeet.sdk_live_flutter_plugin

import io.flutter.view.TextureRegistry
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import android.content.Context
import android.graphics.Rect
import com.screenmeet.sdk.*
import com.screenmeet.sdk.domain.entity.ChatMessage
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.connectCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.connectRoomId
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.connectUserName
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.disconnectCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.getLocalVideoCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.getMediaStateCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.getParticipantsCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.setConfidentialCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.shareAudioCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.shareScreenCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.shareVideoCameraType
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.shareVideoCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.stopSharingAudioCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.stopSharingVideoCommand
import com.screenmeet.sdk_live_flutter_plugin.ChannelParams.Companion.unsetConfidentialCommand
import com.screenmeet.sdk_live_flutter_plugin.handlers.ConnectionStreamHandler
import com.screenmeet.sdk_live_flutter_plugin.handlers.LocalMediaStateStreamHandler
import com.screenmeet.sdk_live_flutter_plugin.handlers.LocalVideoStreamHandler
import com.screenmeet.sdk_live_flutter_plugin.handlers.ParticipantsStreamHandler
import com.screenmeet.sdk_live_flutter_plugin.utils.AnyThreadResult
import io.flutter.plugin.common.*
import org.webrtc.VideoTrack
import java.util.HashMap

class MethodCallHandlerImpl internal constructor(
    private val context: Context,
    private val messenger: BinaryMessenger,
    private val textureRegistry: TextureRegistry
) : MethodCallHandler, SessionEventListener {

    private val connectionStateEventChannel =    "platform_channel_events/screenmeet/connectionState"
    private val remoteParticipantsEventChannel = "platform_channel_events/screenmeet/remoteParticipants"
    private val localMediaStateEventChannel =    "platform_channel_events/screenmeet/localMediaState"
    private val localVideoEventChannel =         "platform_channel_events/screenmeet/localVideo"

    private var connectionStateChannel: EventChannel
    private var localMediaStateChannel: EventChannel
    private var remoteParticipantChannel: EventChannel
    private var localVideoChannel: EventChannel

    private var connectionStreamHandler: ConnectionStreamHandler
    private var localMediaStateStreamHandler: LocalMediaStateStreamHandler
    private var participantsStreamHandler: ParticipantsStreamHandler
    private var localVideoStreamHandler: LocalVideoStreamHandler

    private var localRenderer: FlutterRTCVideoRenderer? = null
    private var localVideoTrack: VideoTrack? = null

    private val renderers = mutableMapOf<String, FlutterRTCVideoRenderer>()

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
    }

    override fun onMethodCall(call: MethodCall, notSafeResult: MethodChannel.Result) {
        val result = AnyThreadResult(notSafeResult)
        when (call.method) {
            connectCommand -> connect(call, result)
            disconnectCommand -> {
                ScreenMeet.disconnect()
                clearTextures()
                result.successful()
            }
            shareScreenCommand -> {
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
            "getPlatformVersion" -> result.success(getPlatformVersion())
            else -> result.notImplemented()
        }
    }

    private fun getPlatformVersion() = "Android ${android.os.Build.VERSION.RELEASE}"

    private fun connect(call: MethodCall, result: AnyThreadResult) {
        val code: String? = call.argument(connectRoomId)
        val userName: String? = call.argument(connectUserName)

        code ?: run {
            result.error("Parameters for this channel method are wrong", errorCodeWrongMethodParameters)
            return
        }

        ScreenMeet.registerEventListener(this)
        ScreenMeet.connect(code, object : CompletionHandler {
            override fun onSuccess() { result.successful() }

            override fun onFailure(error: CompletionError) {
                result.error(error.message, errorCodeConnectFailed)
            }
        })
    }

    private fun setConfidential(call: MethodCall) {
        try {
            val map = call.arguments as HashMap<String, HashMap<String, Double>>
            for ((_, value) in map) {
                val x: Double = value["x"] ?: 0.0
                val y: Double = value["y"] ?: 0.0
                val width: Double = value["width"] ?: 0.0
                val height: Double = value["height"] ?: 0.0
                val r = Rect(x.toInt(), y.toInt(), (x + width).toInt(), (y + height).toInt())
                //ScreenMeet.setConfidential(key, r)
            }
        } catch (e: ClassCastException) {
            io.flutter.Log.e("SdkLiveFlutterPlugin", "ClassCastException $e")
        }
    }

    private fun unsetConfidential(call: MethodCall) {
        call.argument<String?>("id")?.let {
            //ScreenMeet.unsetConfidential(it)
        }
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
            localRenderer = FlutterRTCVideoRenderer(surfaceTexture, entry)
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
                if (renderers[participant.id] == null) {
                    val entry = textureRegistry.createSurfaceTexture()
                    val surfaceTexture = entry.surfaceTexture()
                    val renderer = FlutterRTCVideoRenderer(surfaceTexture, entry)
                    renderers[participant.id] = renderer
                    renderer.setVideoTrack(participant.videoTrack)
                }
            } else if (!participant.mediaState.isVideoActive) {
                renderers[participant.id]?.let { renderer ->
                    renderer.setVideoTrack(null)
                    renderer.dispose()
                    renderers.remove(participant.id)
                }
            }
        }
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
                else -> {
                    result.error("Parameters for this channel method are wrong. Unknown camera type", errorCodeWrongMethodParameters)
                }
            }
        }
    }

    private fun clearTextures()  {
        for ((_, renderer) in renderers) {
            renderer.setVideoTrack(null)
            renderer.dispose()
        }
        renderers.clear()
    }

    override fun onActiveSpeakerChanged(participant: Participant) { }

    override fun onChatMessage(chatMessage: ChatMessage) { }

    override fun onConnectionStateChanged(newState: ScreenMeet.ConnectionState) {
        if (newState.state == ScreenMeet.SessionState.DISCONNECTED){
            ScreenMeet.unregisterEventListener(this)
        }
        connectionStreamHandler.sendConnectionState(newState)
    }

    override fun onLocalAudioCreated() { sendMediaState() }

    override fun onLocalAudioStopped() { sendMediaState() }

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

    fun dispose(){
        clearTextures()
    }
}