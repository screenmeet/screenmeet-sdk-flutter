package com.screenmeet.sdk_live_flutter_plugin_example

import android.app.Application
import com.screenmeet.sdk.ScreenMeet

class App: Application() {

    override fun onCreate() {
        super.onCreate()

        val configuration = ScreenMeet.Configuration("1e24f87ca1");
        ScreenMeet.init(this, configuration)
        registerActivityLifecycleCallbacks(ScreenMeet.activityLifecycleCallback())
    }
}