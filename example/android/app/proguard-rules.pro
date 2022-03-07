-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt # core serialization annotations

# kotlinx-serialization-json specific. Add this if you have java.lang.NoClassDefFoundError kotlinx.serialization.json.JsonObjectSerializer
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

-keep,includedescriptorclasses class com.screenmeet.sdk.**$$serializer { *; }
-keepclassmembers class com.screenmeet.sdk.** {
    *** Companion;
}
-keepclasseswithmembers class com.screenmeet.sdk.** {
    kotlinx.serialization.KSerializer serializer(...);
}

-keep class com.screenmeet.sdk.** { *; }
-keep class org.webrtc.** { *; }
-keep class org.mediasoup.** { *; }
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.android.FlutterFragment { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.engine.renderer.FlutterRenderer { *; }
-dontwarn org.webrtc.**