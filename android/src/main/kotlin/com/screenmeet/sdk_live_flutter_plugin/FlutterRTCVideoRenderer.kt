package com.screenmeet.sdk_live_flutter_plugin

import android.graphics.SurfaceTexture
import android.util.Log
import com.screenmeet.sdk_live_flutter_plugin.utils.AnyThreadSink
import com.screenmeet.sdk_live_flutter_plugin.utils.ConstraintsMap
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.view.TextureRegistry.SurfaceTextureEntry
import org.webrtc.EglBase
import org.webrtc.RendererCommon.RendererEvents
import org.webrtc.VideoFrame
import org.webrtc.VideoSink
import org.webrtc.VideoTrack

class FlutterRTCVideoRenderer(
        private val entry: SurfaceTextureEntry,
        private val sharedContext: EglBase.Context?
    ) : EventChannel.StreamHandler {

    private val texture: SurfaceTexture = entry.surfaceTexture()

    val textureId: Long
        get() = entry.id()

    private val id = -1
    private var surfaceTextureRenderer = SurfaceTextureRenderer("")

    private var eventChannel: EventChannel? = null
    private var eventSink: EventSink? = null

    private var rendererEvents: RendererEvents? = null
    private var videoTrack: VideoTrack? = null

    override fun onListen(o: Any, sink: EventSink) {
        eventSink = AnyThreadSink(sink)
    }

    override fun onCancel(o: Any) {
        eventSink = null
    }

    /**
     * Sets the `VideoTrack` to be rendered by this `FlutterRTCVideoRenderer`.
     *
     * @param videoTrackNew The `VideoTrack` to be rendered by this
     * `FlutterRTCVideoRenderer` or `null`.
     */
    fun setVideoTrack(videoTrackNew: VideoTrack?) {
        val oldValue = videoTrack
        if (oldValue !== videoTrackNew) {
            if (oldValue != null) {
                removeRendererFromVideoTrack()
            }
            videoTrack = videoTrackNew
            if (videoTrackNew != null) {
                Log.w(TAG,
                    "FlutterRTCVideoRenderer.setVideoTrack, " +
                            "set video track to " + videoTrackNew.id()
                )
                tryAddRendererToVideoTrack()
            } else Log.w(TAG, "FlutterRTCVideoRenderer.setVideoTrack, set video track to null")
        }
    }

    /**
     * Starts rendering [.videoTrack] if rendering is not in progress and
     * all preconditions for the start of rendering are met.
     */
    private fun tryAddRendererToVideoTrack() {
        videoTrack?.apply {
            surfaceTextureRenderer.release()
            rendererEvents = provideRendererEventsListener()
            surfaceTextureRenderer.init(sharedContext, rendererEvents)
            surfaceTextureRenderer.surfaceCreated(texture)
            addSink(rotationSink)
        }
    }

    fun dispose() {
        removeRendererFromVideoTrack()
        eventChannel?.setStreamHandler(null)
        eventSink = null
        surfaceTextureRenderer.release()
        surfaceTextureRenderer.surfaceDestroyed()
        entry.release()
    }

    /**
     * Stops rendering [VideoTrack] and releases the associated acquired
     * resources (if rendering is in progress).
     */
    private fun removeRendererFromVideoTrack() {
        videoTrack?.removeSink(rotationSink)
    }

    private val rotationSink = VideoSink { videoFrame: VideoFrame ->
        val frame = VideoFrame(videoFrame.buffer, 0, videoFrame.timestampNs)
        surfaceTextureRenderer.onFrame(frame)
    }

    private fun provideRendererEventsListener(): RendererEvents {
        return object : RendererEvents {
            private var rotation = -1
            private var width = 0
            private var height = 0

            override fun onFirstFrameRendered() {
                val params = ConstraintsMap()
                params.putInt("id", id)
                params.putString("event", "didFirstFrameRendered")
                eventSink?.success(params.toMap())
            }

            override fun onFrameResolutionChanged(
                videoWidthNew: Int,
                videoHeightNew: Int,
                rotationNew: Int
            ) {
                eventSink?.apply {
                    if (width != videoWidthNew || height != videoHeightNew) {
                        val params = ConstraintsMap()
                        params.putString("event", "didTextureChangeVideoSize")
                        params.putInt("id", id)
                        params.putDouble("width", videoWidthNew.toDouble())
                        params.putDouble("height", videoHeightNew.toDouble())
                        width = videoWidthNew
                        height = videoHeightNew
                        success(params.toMap())
                    }
                    if (rotation != rotationNew) {
                        val params = ConstraintsMap()
                        params.putString("event", "didTextureChangeRotation")
                        params.putInt("id", id)
                        params.putInt("rotation", rotationNew)
                        rotation = rotationNew
                        success(params.toMap())
                    }
                }
            }
        }
    }

    companion object {
        private const val TAG = "FlutterRTCVideoRenderer"
    }

}