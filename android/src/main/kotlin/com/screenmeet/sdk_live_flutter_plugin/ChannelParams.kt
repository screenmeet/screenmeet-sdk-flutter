package com.screenmeet.sdk_live_flutter_plugin

import com.screenmeet.sdk.Participant
import com.screenmeet.sdk.ParticipantMediaState
import com.screenmeet.sdk.ScreenMeet


//call: MethodCall
//result: MethodChannel.Result

const val resultStatus = "resultStatus"
const val errorText = "errorText"
const val errorCode = "errorCode"

//Error codes
const val errorCodeWrongMethodParameters = 1001
const val errorCodeConnectFailed = 1002
const val errorCodeNoParticipantFound = 1003

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

    return mapOf(ChannelParams.participantsKey to list)
}

fun zipLocalVideo(mediaState: ParticipantMediaState, textureId: Long): Map<String, Any>  {
    return mapOf(
        ChannelParams.on to (mediaState.isVideoActive && mediaState.videoState.source != ScreenMeet.VideoSource.SCREEN),
        ChannelParams.textureId to textureId
    )
}

enum class CameraType(val type: String) {
    FRONT("front"),
    BACK("back")
}

class ChannelParams {
    companion object {
        const val connectCommand = "connect"
        const val disconnectCommand = "disconnect"
        const val connectUserName = "connectUserName"
        const val connectRoomId = "connectRoomId"

        const val shareScreenCommand = "shareScreen"
        const val shareVideoCommand = "shareVideo"
        const val stopSharingVideoCommand = "stopSharingVideo"
        const val shareAudioCommand = "shareAudio"
        const val stopSharingAudioCommand = "stopSharingAudio"
        const val getMediaStateCommand = "getMediaState"
        const val getParticipantsCommand = "getParticipants"
        const val shareVideoCameraType = "shareVideoCameraType"
        const val getLocalVideoCommand = "getLocalVideo"
        const val changeVideoSourceCommand = "changeVideoSource"

        const val setConfidentialCommand = "setConfidential"
        const val unsetConfidentialCommand = "unsetConfidential"

        const val audioEnabled = "audioEnabled"
        const val videoEnabled = "videoEnabled"
        const val screenEnabled = "screenEnabled"

        const val participantsKey = "participants"
        const val participantId = "participantId"
        const val participantName = "participantName"
        const val textureId = "textureId"
        const val on = "isOn"
    }
}