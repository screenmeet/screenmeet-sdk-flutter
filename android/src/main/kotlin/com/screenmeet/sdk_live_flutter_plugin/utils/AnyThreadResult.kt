package com.screenmeet.sdk_live_flutter_plugin.utils

import android.os.Handler
import android.os.Looper
import com.screenmeet.sdk_live_flutter_plugin.errorCode
import com.screenmeet.sdk_live_flutter_plugin.errorText
import com.screenmeet.sdk_live_flutter_plugin.resultStatus
import io.flutter.plugin.common.MethodChannel

class AnyThreadResult(private val result: MethodChannel.Result) : MethodChannel.Result {

    private val handler = Handler(Looper.getMainLooper())

    fun successful(params: Map<String, Any>? = null) {
        success(params?.toMutableMap()?.apply {
            this[resultStatus] = true
        } ?: mapOf(resultStatus to true))
    }

    fun error(text: String, code: Int) {
        success(mapOf(resultStatus to false, errorText to text, errorCode to code))
    }

    fun error(text: String, code: Int, params: Map<String, Any>? = null) {
        success(params?.toMutableMap()?.apply {
            this[resultStatus] = false
            this[errorText] = text
            this[errorCode] = code
            putAll(params)
        } ?: mapOf(resultStatus to false))
    }

    override fun success(o: Any?) {
        post { result.success(o) }
    }

    override fun error(s: String, s1: String?, o: Any?) {
        post { result.error(s, s1, o) }
    }
    override fun notImplemented() {
        post { result.notImplemented() }
    }

    private fun post(r: Runnable) {
        if (Looper.getMainLooper() == Looper.myLooper()) r.run() else handler.post(r)
    }
}