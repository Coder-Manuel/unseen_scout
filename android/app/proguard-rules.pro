# Flutter core (REQUIRED)
-keep class io.flutter.** { *; }

# Specifically required for path_provider
-keep class io.flutter.util.PathUtils { *; }

# JNI (your stack shows jni usage)
-keep class com.github.dart_lang.jni.** { *; }

# Path provider (important)
-keep class io.flutter.plugins.pathprovider.** { *; }

# Keep method channels
-keep class io.flutter.plugin.common.** { *; }

# Prevent stripping via reflection
-keepattributes *Annotation*

# Silence warnings
-dontwarn io.flutter.**