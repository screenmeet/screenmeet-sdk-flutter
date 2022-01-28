package com.screenmeet.sdk_live_flutter_plugin.handlers

import com.screenmeet.sdk.Participant
import com.screenmeet.sdk_live_flutter_plugin.FlutterRTCVideoRenderer
import com.screenmeet.sdk_live_flutter_plugin.zipParticipants
import io.flutter.plugin.common.EventChannel

class ParticipantsStreamHandler: EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { sink = events }
    override fun onCancel(arguments: Any?) { sink = null }

    fun sendParticipants(participants: List<Participant>, renderers: Map<String, FlutterRTCVideoRenderer>) {
        sink?.success(zipParticipants(participants, renderers))
    }
}