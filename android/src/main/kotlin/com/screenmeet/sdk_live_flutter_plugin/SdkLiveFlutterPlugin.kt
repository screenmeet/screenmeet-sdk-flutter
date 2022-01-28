package com.screenmeet.sdk_live_flutter_plugin

import android.app.Activity
import android.app.Application
import android.app.Application.ActivityLifecycleCallbacks
import android.content.Context
import android.os.Bundle
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry

class SdkLiveFlutterPlugin: FlutterPlugin, ActivityAware {

  /// The MethodChannel that will the communication between Flutter and native Android
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private var channel: MethodChannel? = null
  private var methodCallHandler: MethodCallHandlerImpl? = null

  private lateinit var messenger: BinaryMessenger
  private lateinit var textureRegistry: TextureRegistry

  private var application: Application? = null
  private var observer: LifeCycleObserver? = null
  private var lifecycle: Lifecycle? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    startListening(
      binding.applicationContext,
      binding.binaryMessenger,
      binding.textureRegistry
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) { stopListening() }

  private fun startListening(
    appContext: Context,
    binaryMessenger: BinaryMessenger,
    textureRegistry: TextureRegistry
  ) {
    this.messenger = binaryMessenger
    this.textureRegistry = textureRegistry
    this.application = appContext as Application

    channel = MethodChannel(binaryMessenger, "sdk_live_flutter_plugin")
    methodCallHandler = MethodCallHandlerImpl(appContext, binaryMessenger, textureRegistry)
    channel?.setMethodCallHandler(methodCallHandler)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    LifeCycleObserver().let {
      observer = it
      lifecycle = (binding.lifecycle as HiddenLifecycleReference).lifecycle
      lifecycle?.addObserver(it)
      application?.registerActivityLifecycleCallbacks(it)
    }
  }

  override fun onDetachedFromActivity() {
    observer?.let {
      lifecycle?.removeObserver(it)
      application?.unregisterActivityLifecycleCallbacks(it)
    }
    lifecycle = null
  }

  override fun onDetachedFromActivityForConfigChanges() { }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { }

  private fun stopListening() {
    channel?.setMethodCallHandler(null)
    methodCallHandler?.dispose()
    methodCallHandler = null
  }

  private class LifeCycleObserver : ActivityLifecycleCallbacks, DefaultLifecycleObserver {
    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
    override fun onActivityStarted(activity: Activity) {}
    override fun onActivityResumed(activity: Activity) {}
    override fun onResume(owner: LifecycleOwner) {}
    override fun onActivityPaused(activity: Activity) {}
    override fun onActivityStopped(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}
  }
}