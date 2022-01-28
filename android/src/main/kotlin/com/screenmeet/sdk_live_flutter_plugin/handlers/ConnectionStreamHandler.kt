package com.screenmeet.sdk_live_flutter_plugin.handlers

import com.screenmeet.sdk.ScreenMeet
import io.flutter.plugin.common.EventChannel

class ConnectionStreamHandler: EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { sink = events }
    override fun onCancel(arguments: Any?) { sink = null }

    fun sendConnectionState(connectionState: ScreenMeet.ConnectionState) {
        sink?.success(connectionState.state.name)
    }
}