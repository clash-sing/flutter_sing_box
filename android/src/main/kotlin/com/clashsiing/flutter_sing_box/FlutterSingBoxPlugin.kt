package com.clashsiing.flutter_sing_box

import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.util.Log
import com.clashsiing.flutter_sing_box.core.BoxService
import com.clashsiing.flutter_sing_box.cs.PluginManager
import com.clashsiing.flutter_sing_box.cs.ServiceManager
import com.tencent.mmkv.MMKV
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.atomic.AtomicReference

/** FlutterSingBoxPlugin */
class FlutterSingBoxPlugin :
    FlutterPlugin,
    MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener, EventChannel.StreamHandler {
    companion object {
        private const val TAG = "FlutterSingBoxPlugin"
        private const val INIT = "init"
        private const val START_VPN = "startVpn"
        private const val STOP_VPN = "stopVpn"
        private const val VPN_REQUEST_CODE = 1001
        private const val METHOD_CHANNEL_NAME = "flutter_sing_box_method"
        private const val EVENT_CHANNEL_NAME = "flutter_sing_box_event"
    }
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var applicationContext: Context
    private var activityBinding: ActivityPluginBinding? = null
    private val pendingStartVpnResult = AtomicReference<Result?>(null)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            INIT -> {
                val catchingResult = runCatching {
                    MMKV.initialize(applicationContext)
                    val args = call.arguments as? Map<*, *>
                    if (args != null) {
                        val isDebug = (args["isDebug"] as? Boolean) ?: throw IllegalArgumentException("arguments['isDebug'] is null")
                        PluginManager.init(context = applicationContext, isDebug)
                        ServiceManager.reconnect()
                    } else {
                        throw IllegalArgumentException("Arguments are null")
                    }
                }
                if (catchingResult.isSuccess) {
                    result.success(null)
                } else {
                    Log.e(TAG, "init error", catchingResult.exceptionOrNull())
                    result.error("INVALID_ARGS", catchingResult.exceptionOrNull()?.message, null)
                }
            }
            START_VPN -> {
                // 检查是否有Activity绑定
                val activity = activityBinding?.activity
                if (activity == null) {
                    result.error("NO_ACTIVITY", "无法获取Activity实例", null)
                    return
                }
                
                // 保存result引用，用于权限请求回调
                pendingStartVpnResult.set(result)
                
                // 请求VPN权限
                val intent = VpnService.prepare(applicationContext)
                if (intent != null) {
                    activity.startActivityForResult(intent, VPN_REQUEST_CODE)
                } else {
                    // 已经有VPN权限，可以直接启动服务
                    startVpnService(result)
                }
            }
            STOP_VPN -> {
                BoxService.stop()
//                applicationContext.sendBroadcast(
//                    Intent(Action.SERVICE_CLOSE).setPackage(
//                        applicationContext.packageName
//                    )
//                )
                result.success(null)
            }
            "sendEventToFlutter" -> {
                eventSink?.success("Hello from Android!")
                result.success(null)
            }
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun startVpnService(result: Result) {
        try {

            BoxService.start()
//            applicationContext.startForegroundService(
//                Intent(
//                    applicationContext,
//                    ClashSingVpnService::class.java
//                )
//            )
            result.success(null)
        } catch (e: Exception) {
            result.error("VPN_ERROR", "启动VPN服务失败:\n${e.message}", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        ServiceManager.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        ServiceManager.eventSink = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ): Boolean {
        if (requestCode == VPN_REQUEST_CODE) {
            val result = pendingStartVpnResult.getAndSet(null)
            if (result != null) {
                if (resultCode == android.app.Activity.RESULT_OK) {
                    // 用户授予了VPN权限，启动服务
                    startVpnService(result)
                } else {
                    // 用户拒绝了VPN权限
                    result.error("VPN_PERMISSION_DENIED", "用户拒绝了VPN权限", null)
                }
            }
            return true
        }
        return false
    }
}
