package com.screenmeet.sdk_live_flutter_plugin.handlers

import io.flutter.plugin.common.EventChannel

class RemoteControlStreamHandler: EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { sink = events }
    override fun onCancel(arguments: Any?) { sink = null }

}