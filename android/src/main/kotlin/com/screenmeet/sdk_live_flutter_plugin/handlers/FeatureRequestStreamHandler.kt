package com.screenmeet.sdk_live_flutter_plugin.handlers

import com.screenmeet.sdk.Entitlement
import com.screenmeet.sdk.Feature
import com.screenmeet.sdk_live_flutter_plugin.zipFeature
import com.screenmeet.sdk_live_flutter_plugin.zipFeatureCancel
import io.flutter.plugin.common.EventChannel

class FeatureRequestStreamHandler: EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { sink = events }
    override fun onCancel(arguments: Any?) { sink = null }

    fun sendPermissionRequest(feature: Feature) {
        sink?.success(zipFeature(feature))
    }

    fun sendFeatureCancel(entitlement: Entitlement) {
        sink?.success(zipFeatureCancel(entitlement))
    }

}