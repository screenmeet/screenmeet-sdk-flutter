package com.screenmeet.sdk_live_flutter_plugin.handlers

import com.screenmeet.sdk.ParticipantMediaState
import com.screenmeet.sdk_live_flutter_plugin.FlutterRTCVideoRenderer
import com.screenmeet.sdk_live_flutter_plugin.zipLocalVideo
import io.flutter.plugin.common.EventChannel

class LocalVideoStreamHandler: EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { sink = events }
    override fun onCancel(arguments: Any?) { sink = null }

    fun sendLocalVideo(localMediaState: ParticipantMediaState, renderer: FlutterRTCVideoRenderer?) {
        val textureId = renderer?.textureId ?: -1L
        sink?.success(zipLocalVideo(localMediaState, textureId))
    }
}