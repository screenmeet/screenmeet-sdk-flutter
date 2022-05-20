package com.screenmeet.sdk_live_flutter_plugin.utils

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel.EventSink

class AnyThreadSink(private val eventSink: EventSink) : EventSink {
    private val handler = Handler(Looper.getMainLooper())
    override fun success(o: Any) {
        post { eventSink.success(o) }
    }

    override fun error(s: String, s1: String, o: Any) {
        post { eventSink.error(s, s1, o) }
    }

    override fun endOfStream() {
        post { eventSink.endOfStream() }
    }

    private fun post(r: Runnable) {
        if (Looper.getMainLooper() == Looper.myLooper()) {
            r.run()
        } else handler.post(r)
    }
}