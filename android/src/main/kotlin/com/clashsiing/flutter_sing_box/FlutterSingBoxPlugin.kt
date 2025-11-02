package com.clashsiing.flutter_sing_box

import android.content.Context
import android.content.Intent
import android.net.VpnService
import com.clashsiing.flutter_sing_box.core.BoxService
import com.clashsiing.flutter_sing_box.cs.SingBoxConnector
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.atomic.AtomicReference

/** FlutterSingBoxPlugin */
class FlutterSingBoxPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {
    companion object {
        private const val START_VPN = "startVpn"
        private const val STOP_VPN = "stopVpn"
        private const val PROXY_STATE = "proxyState"
        private const val VPN_REQUEST_CODE = 1001
        private const val METHOD_CHANNEL_NAME = "flutter_sing_box_method"
        private const val EVENT_CHANNEL_CONNECTED_STATUS = "connected_status_event"
        private const val EVENT_CHANNEL_GROUP = "group_event"
        private const val EVENT_CHANNEL_CLASH_MODE = "clash_mode_event"
        private const val EVENT_CHANNEL_LOG = "log_event"
        private const val EVENT_CHANNEL_PROXY_STATE = "proxy_state_event"
    }
    private lateinit var channel: MethodChannel
    private lateinit var eventChannelConnectedStatus: EventChannel
    private lateinit var eventChannelGroup: EventChannel
    private lateinit var eventChannelClashMode: EventChannel
    private lateinit var eventChannelLog: EventChannel
    private lateinit var eventChannelProxyState: EventChannel
    private lateinit var applicationContext: Context
    private var activityBinding: ActivityPluginBinding? = null
    private val pendingStartVpnResult = AtomicReference<Result?>(null)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext

        eventChannelConnectedStatus = EventChannel(
            flutterPluginBinding.binaryMessenger,
            EVENT_CHANNEL_CONNECTED_STATUS
        )
        eventChannelConnectedStatus.setStreamHandler(ConnectedStatusStream())

        eventChannelGroup = EventChannel(
            flutterPluginBinding.binaryMessenger,
            EVENT_CHANNEL_GROUP
        )
        eventChannelGroup.setStreamHandler(GroupStream())

        eventChannelClashMode = EventChannel(
            flutterPluginBinding.binaryMessenger,
            EVENT_CHANNEL_CLASH_MODE
        )
        eventChannelClashMode.setStreamHandler(ClashModeStream())

        eventChannelLog = EventChannel(
            flutterPluginBinding.binaryMessenger,
            EVENT_CHANNEL_LOG
        )
        eventChannelLog.setStreamHandler(LogStream())

        eventChannelProxyState = EventChannel(
            flutterPluginBinding.binaryMessenger,
            EVENT_CHANNEL_PROXY_STATE
        )
        eventChannelProxyState.setStreamHandler(ProxyStateStream())
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
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
//            PROXY_STATE -> {
//                result.success(SingBoxConnector.proxyState)
//            }
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
        eventChannelConnectedStatus.setStreamHandler(null)
        eventChannelGroup.setStreamHandler(null)
        eventChannelClashMode.setStreamHandler(null)
        eventChannelLog.setStreamHandler(null)
        eventChannelProxyState.setStreamHandler(null)
    }

    // ActivityAware
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
        SingBoxConnector.reconnect()
    }

    // ActivityAware
    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
    }

    // ActivityAware
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    // ActivityAware
    override fun onDetachedFromActivity() {
        SingBoxConnector.disconnect()
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
    }

    // PluginRegistry.ActivityResultListener
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
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

    class ConnectedStatusStream : StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            SingBoxConnector.statusSink = events
        }

        override fun onCancel(arguments: Any?) {
            SingBoxConnector.statusSink = null
        }
    }

    class GroupStream : StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            SingBoxConnector.groupSink = events
        }

        override fun onCancel(arguments: Any?) {
            SingBoxConnector.groupSink = null
        }
    }

    class ClashModeStream : StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            SingBoxConnector.clashModeSink = events
        }

        override fun onCancel(arguments: Any?) {
            SingBoxConnector.clashModeSink = null
        }
    }

    class LogStream : StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            SingBoxConnector.logSink = events
        }

        override fun onCancel(arguments: Any?) {
            SingBoxConnector.logSink = null
        }
    }

    class ProxyStateStream : StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            SingBoxConnector.proxyStateSink = events
        }

        override fun onCancel(arguments: Any?) {
            SingBoxConnector.proxyStateSink = null
        }
    }

}
