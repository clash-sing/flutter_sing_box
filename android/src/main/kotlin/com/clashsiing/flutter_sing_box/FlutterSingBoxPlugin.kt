package com.clashsiing.flutter_sing_box

import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterSingBoxPlugin */
class FlutterSingBoxPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var pluginBinding: FlutterPlugin.FlutterPluginBinding
    private val applicationContext by lazy { pluginBinding.applicationContext }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_sing_box")
        channel.setMethodCallHandler(this)
        pluginBinding = flutterPluginBinding
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    applicationContext.startForegroundService(
                        Intent(
                            pluginBinding.applicationContext,
                            ClashSingVpnService::class.java
                        )
                    )

                } else {
                    applicationContext.startService(
                        Intent(
                            pluginBinding.applicationContext,
                            ClashSingVpnService::class.java
                        )
                    )
                }
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
