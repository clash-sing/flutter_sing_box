# Keep Libbox classes as they might be called from JNI or reflection
-keep class io.nekohasekai.libbox.** { *; }

# Keep MMKV
-keep class com.tencent.mmkv.** { *; }

# Keep AIDL interfaces and generated classes
-keep class com.clashsiing.flutter_sing_box.aidl.** { *; }
-keep interface com.clashsiing.flutter_sing_box.aidl.** { *; }

# Keep Kotlin Serialization models in this plugin
-keep class com.clashsiing.flutter_sing_box.cs.models.** { *; }

# Keep the Plugin class itself (usually safe to keep public entry points)
-keep class com.clashsiing.flutter_sing_box.** { *; }
