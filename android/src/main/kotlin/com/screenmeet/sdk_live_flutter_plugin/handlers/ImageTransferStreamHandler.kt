package com.screenmeet.sdk_live_flutter_plugin.handlers

import android.graphics.*
import androidx.palette.graphics.Palette
import com.screenmeet.sdk.FlutterDelegate
import io.flutter.plugin.common.BasicMessageChannel

class ImageTransferStreamHandler<T>(
    private val flutterDelegate: FlutterDelegate
): BasicMessageChannel.MessageHandler<T> {

    private var hidePaint: Paint = Paint()

    @Suppress("UNCHECKED_CAST")
    override fun onMessage(message: T?, reply: BasicMessageChannel.Reply<T>) {
        // The array of parameters contains raw image data as the first element,
        // then followed by any number of dictionaries of rectangles
        val params = message as? ArrayList<Any> ?: return
        var frame: Bitmap? = null
        val confidentialList = mutableListOf<Rect>()
        params.forEachIndexed { index, any ->
            if (index == 0){
                val imageBytes = any as? ByteArray ?: return
                val options = BitmapFactory.Options().apply { inMutable = true }
                frame = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size, options)
            } else {
                val rectMap = any as? HashMap<String, Double> ?: return@forEachIndexed
                val left = rectMap["x"] ?: 0.0
                val top = rectMap["y"] ?: 0.0
                val right = left + (rectMap["width"] ?: 0.0)
                val bottom = top + (rectMap["height"] ?: 0.0)
                val i = 2
                confidentialList.add(
                    Rect(
                        left.toInt() - i,
                        top.toInt() - i,
                        right.toInt() + i,
                        bottom.toInt() + i
                    )
                )
            }
        }
        frame ?: return

        applyConfidentiality(Canvas(frame!!), confidentialList, Palette.from(frame!!))
        flutterDelegate.setFrame(frame!!)
    }

    private fun applyConfidentiality(
        canvas: Canvas,
        bounds: List<Rect>,
        builder: Palette.Builder
    ) {
        bounds.forEach { bound ->
            try {
                builder.setRegion(bound.left, bound.top, bound.right, bound.bottom)
                val palette = builder.generate()
                hidePaint.color = palette.getMutedColor(hidePaint.color)
                canvas.drawRect(bound, hidePaint)
            } catch (ignored: IllegalArgumentException) {
            } catch (ignored: NegativeArraySizeException) {
            }
        }
    }

    init {
        hidePaint.isAntiAlias = true
        hidePaint.color = Color.RED
        hidePaint.style = Paint.Style.FILL
        val strokeWidth = 15f
        hidePaint.strokeWidth = strokeWidth
    }
}