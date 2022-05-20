package com.screenmeet.sdk_live_flutter_plugin

import android.graphics.Bitmap
import com.screenmeet.sdk.*
import java.io.ByteArrayOutputStream

const val resultStatus = "resultStatus"
const val errorText = "errorText"
const val errorCode = "errorCode"

//Error codes
const val errorCodeWrongMethodParameters = 1001
const val errorCodeConnectFailed = 1002
const val errorCodeNoParticipantFound = 1003
const val errorKnowEntryPermissionRequired = 1004
const val errorCaptchaRequired = 1005

fun zipMediaState(mediaState: ParticipantMediaState): Map<String, Any> {
    return mapOf(
        ChannelParams.videoEnabled to (mediaState.isVideoActive && mediaState.videoState.source != ScreenMeet.VideoSource.SCREEN),
        ChannelParams.audioEnabled to mediaState.isAudioActive,
        ChannelParams.screenEnabled to (mediaState.isVideoActive && mediaState.videoState.source == ScreenMeet.VideoSource.SCREEN)
    )
}

fun zipParticipants(participants: List<Participant>, renderers: Map<String, FlutterRTCVideoRenderer>): Map<String, Any> {
    val list = mutableListOf<Map<String, Any>>()

    participants.forEach { participant ->
        val texture = renderers[participant.id]?.textureId ?: -1L
        list.add(
            mapOf(
                ChannelParams.participantId to participant.id,
                ChannelParams.participantName to participant.identity.name,
                ChannelParams.textureId to texture,
                ChannelParams.videoEnabled to (participant.mediaState.isVideoActive
                        && participant.mediaState.videoState.source != ScreenMeet.VideoSource.SCREEN),
                ChannelParams.audioEnabled to participant.mediaState.isAudioActive,
                ChannelParams.screenEnabled to (participant.mediaState.isVideoActive
                        && participant.mediaState.videoState.source == ScreenMeet.VideoSource.SCREEN)
            )
        )
    }

    return mapOf(ChannelParams.participants to list)
}

fun zipLocalVideo(mediaState: ParticipantMediaState, textureId: Long): Map<String, Any>  {
    return mapOf(
        ChannelParams.on to (mediaState.isVideoActive && mediaState.videoState.source != ScreenMeet.VideoSource.SCREEN),
        ChannelParams.textureId to textureId
    )
}

fun mapEntitlement(entitlement: Entitlement) = when(entitlement){
    Entitlement.LASER_POINTER -> "laserpointer"
    Entitlement.REMOTE_CONTROL -> "remotecontrol"
    else -> "unknown"
}

fun zipChallenge(challenge: Challenge): Map<String, Any> {
    val stream = ByteArrayOutputStream()
    challenge.bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
    val byteArray: ByteArray = stream.toByteArray()
    challenge.bitmap.recycle()
    return mapOf(ChannelParams.challenge to byteArray)
}

fun zipFeatureCancel(entitlement: Entitlement) = mapOf(
    ChannelParams.featureCancel to true,
    ChannelParams.featureType to mapEntitlement(entitlement),
)

fun zipFeature(feature: Feature) = mapOf(
    ChannelParams.featureType to mapEntitlement(feature.entitlement),
    ChannelParams.featureRequestorId to (feature.requestorId ?: ""),
    ChannelParams.featureRequestorName to (feature.requestor?.identity?.name ?: "")
)

enum class CameraType(val type: String) {
    FRONT("front"),
    BACK("back")
}

class ChannelParams {
    companion object {
        const val setConfigCommand = "setConfig"
        const val connectCommand = "connect"
        const val disconnectCommand = "disconnect"
        const val connectUserName = "connectUserName"
        const val connectRoomId = "connectRoomId"

        const val shareScreenCommand = "shareScreen"
        const val shareScreenWithImageTransfer = "shareScreenWithImageTransfer"
        const val shareVideoCommand = "shareVideo"
        const val stopSharingVideoCommand = "stopSharingVideo"
        const val shareAudioCommand = "shareAudio"
        const val stopSharingAudioCommand = "stopSharingAudio"
        const val getMediaStateCommand = "getMediaState"
        const val getParticipantsCommand = "getParticipants"
        const val shareVideoCameraType = "shareVideoCameraType"
        const val getLocalVideoCommand = "getLocalVideo"
        const val changeVideoSourceCommand = "changeVideoSource"

        const val getConfidentialBounds = "getConfidentialBounds"
        const val setConfidentialCommand = "setConfidential"
        const val unsetConfidentialCommand = "unsetConfidential"

        const val audioEnabled = "audioEnabled"
        const val videoEnabled = "videoEnabled"
        const val screenEnabled = "screenEnabled"

        const val localParticipant = "localParticipant"
        const val participants = "participants"
        const val participantId = "participantId"
        const val participantName = "participantName"
        const val textureId = "textureId"
        const val on = "isOn"

        const val organizationKey = "organizationKey"
        const val collectMetrics = "collectMetrics"
        const val endpoint = "endpoint"
        const val logLevel = "logLevel"

        const val featureType = "featureType"
        const val featureCancel= "featureCancel"
        const val featureRequestorId = "featureRequestorId"
        const val featureRequestorName = "featureRequestorName"

        const val featureGrantAccessCommand = "featureGrantAccess"
        const val featureRejectAccessCommand = "featureRejectAccess"

        const val id = "id"
        const val x = "x"
        const val y = "y"
        const val width = "width"
        const val height = "height"

        const val challenge = "challenge"
        const val challengeSolution = "challengeSolution"
        const val solveChallenge = "solveChallenge"

        const val resultStatus = "resultStatus"
        const val errorText = "errorText"
        const val errorCode = "errorCode"
    }
}