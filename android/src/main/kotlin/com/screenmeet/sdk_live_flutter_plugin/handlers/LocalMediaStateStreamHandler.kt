package com.screenmeet.sdk_live_flutter_plugin.handlers

import com.screenmeet.sdk.ParticipantMediaState
import com.screenmeet.sdk_live_flutter_plugin.zipMediaState
import io.flutter.plugin.common.EventChannel

class LocalMediaStateStreamHandler: EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { sink = events }
    override fun onCancel(arguments: Any?) { sink = null }

    fun sendMediaState(mediaState: ParticipantMediaState) {
        sink?.success(zipMediaState(mediaState))
    }
}