package com.clashsiing.flutter_sing_box

import android.content.Context
import android.content.Intent
import android.net.VpnService
import com.clashsiing.flutter_sing_box.constant.Action
import com.clashsiing.flutter_sing_box.utils.PluginManager
import com.clashsiing.flutter_sing_box.core.ClashSingVpnService
import com.clashsiing.flutter_sing_box.utils.HttpClient
import com.tencent.mmkv.MMKV
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.atomic.AtomicReference

/** FlutterSingBoxPlugin */
class FlutterSingBoxPlugin :
    FlutterPlugin,
    MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    companion object {
        private const val SETUP = "setup"
        private const val IMPORT_PROFILE = "importProfile"
        private const val START_VPN = "startVpn"
        private const val STOP_VPN = "stopVpn"
        private const val VPN_REQUEST_CODE = 1001
    }
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private var activityBinding: ActivityPluginBinding? = null
    private val pendingStartVpnResult = AtomicReference<Result?>(null)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_sing_box")
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
        MMKV.initialize(applicationContext)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            SETUP -> {
                val catchingResult = runCatching {
                    val args = call.arguments as? Map<*, *>
                    if (args != null) {
                        PluginManager.init(
                            context = applicationContext,
                            isDebug = (args["isDebug"] as? Boolean) ?: throw IllegalArgumentException("arguments['isDebug'] is null"),
                            packageName = (args["packageName"] as? String) ?: throw IllegalArgumentException("arguments['packageName'] is null"),
                            versionName = (args["versionName"] as? String) ?: throw IllegalArgumentException("arguments['versionName'] is null"),
                            versionCode = ((args["versionCode"] as? String)?.toLongOrNull()) ?: throw IllegalArgumentException("arguments['versionCode'] is null"),
                        )
                    } else {
                        throw IllegalArgumentException("Arguments are null")
                    }
                }
                if (catchingResult.isSuccess) {
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", catchingResult.exceptionOrNull()?.message, null)
                }
            }
            IMPORT_PROFILE -> {
                val catchingResult = runCatching {
                    val args = call.arguments as? Map<*, *>
                    if (args != null) {
                        val url = (args["url"] as? String) ?: throw IllegalArgumentException("arguments['url'] is null")
                        HttpClient().use {
                            it.getString(url)
                        }
                    } else {
                        throw IllegalArgumentException("Arguments are null")
                    }
                }
                if (catchingResult.isSuccess) {
                    result.success(catchingResult.getOrNull())
                } else {
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
                applicationContext.sendBroadcast(
                    Intent(Action.SERVICE_CLOSE).setPackage(
                        applicationContext.packageName
                    )
                )
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
            applicationContext.startForegroundService(
                Intent(
                    applicationContext,
                    ClashSingVpnService::class.java
                )
            )
            result.success(null)
        } catch (e: Exception) {
            result.error("VPN_ERROR", "启动VPN服务失败:\n${e.message}", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
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
