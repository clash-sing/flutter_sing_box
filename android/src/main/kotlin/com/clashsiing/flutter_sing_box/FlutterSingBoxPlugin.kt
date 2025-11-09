package com.clashsiing.flutter_sing_box

import android.content.Intent
import android.net.VpnService
import android.util.Log
import com.clashsiing.flutter_sing_box.core.BoxService
import com.clashsiing.flutter_sing_box.cs.SingBoxConnector
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.nekohasekai.libbox.Libbox
import java.util.concurrent.atomic.AtomicReference
import kotlin.text.contains

class FlutterSingBoxPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    companion object {
        private const val METHOD_CHANNEL_NAME = "flutter_sing_box_method"
        private const val VPN_REQUEST_CODE = 1001
    }

    private lateinit var channel: MethodChannel
    private var singBoxConnector: SingBoxConnector? = null
    private var activityBinding: ActivityPluginBinding? = null
    private val pendingStartVpnResult = AtomicReference<Result?>(null)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        singBoxConnector = SingBoxConnector(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        singBoxConnector = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startVpn" -> {
                val activity = activityBinding?.activity
                if (activity == null) {
                    result.error("NO_ACTIVITY", "无法获取Activity实例", null)
                    return
                }
                pendingStartVpnResult.set(result)
                val intent = VpnService.prepare(activity)
                if (intent != null) {
                    activity.startActivityForResult(intent, VPN_REQUEST_CODE)
                } else {
                    startVpnService(result)
                }
            }
            "stopVpn" -> {
                BoxService.stop()
                result.success(null)
            }
            "setClashMode" -> {
                val clashMode = call.arguments as String?
                if (clashMode.isNullOrBlank()) {
                    result.error("INVALID_CLASH_MODE", "无效的Clash模式", null)
                    return
                }
                if (singBoxConnector?.clientClashMode?.modes?.contains(clashMode) == true) {
                    Libbox.newStandaloneCommandClient().setClashMode(clashMode)
                    result.success(null)
                } else {
                    result.error("INVALID_CLASH_MODE", "无效的Clash模式", null)
                }
            }
            "setOutbound" -> {
                val groupArgName = "groupTag"
                val outboundArgName = "outboundTag"
                if (call.arguments !is Map<*, *>) {
                    result.error("INVALID_ARGUMENTS", "无效的参数", null)
                    return
                }
                val argsMap = call.arguments as Map<*, *>
                val groupTag = argsMap[groupArgName] as String?
                val outboundTag = argsMap[outboundArgName] as String?
                if (groupTag.isNullOrBlank() || outboundTag.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENTS", "无效的参数", null)
                    return
                }
                try {
                    Log.d("setOutbound", "groupTag: $groupTag, outboundTag: $outboundTag")
                    Libbox.newStandaloneCommandClient().selectOutbound(groupTag, outboundTag)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("INVALID_ARGUMENTS", "无效的参数", null)
                    return
                }
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
            result.success(null)
        } catch (e: Exception) {
            result.error("VPN_ERROR", "启动VPN服务失败:\n${e.message}", null)
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
        singBoxConnector?.connect()
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
        singBoxConnector?.disconnect()
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == VPN_REQUEST_CODE) {
            val result = pendingStartVpnResult.getAndSet(null)
            if (result != null) {
                if (resultCode == android.app.Activity.RESULT_OK) {
                    startVpnService(result)
                } else {
                    result.error("VPN_PERMISSION_DENIED", "用户拒绝了VPN权限", null)
                }
            }
            return true
        }
        return false
    }
}