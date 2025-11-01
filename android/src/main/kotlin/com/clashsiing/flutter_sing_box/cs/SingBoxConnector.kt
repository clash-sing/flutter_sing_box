package com.clashsiing.flutter_sing_box.cs

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import com.clashsiing.flutter_sing_box.aidl.IService
import com.clashsiing.flutter_sing_box.aidl.IServiceCallback
import com.clashsiing.flutter_sing_box.constant.Action
import com.clashsiing.flutter_sing_box.constant.Status
import com.clashsiing.flutter_sing_box.utils.CommandClient
import com.clashsiing.flutter_sing_box.utils.SettingsManager
import io.flutter.plugin.common.EventChannel
import io.nekohasekai.libbox.OutboundGroup
import io.nekohasekai.libbox.StatusMessage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

object SingBoxConnector {
    private const val TAG = "SingBoxConnector"
    private lateinit var statusClient: CommandClient
    private lateinit var groupClient: CommandClient
    private lateinit var clashModeClient: CommandClient
    private lateinit var coroutineScope: CoroutineScope
    private var service: IService? = null
    var statusSink: EventChannel.EventSink? = null
    var groupSink: EventChannel.EventSink? = null
    var clashModeSink: EventChannel.EventSink? = null
    private val callback = ServiceCallback()
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            service = IService.Stub.asInterface(binder).apply {
                registerCallback(callback)
                callback.onServiceStatusChanged(status)
            }
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            try {
                service?.unregisterCallback(callback)
            } catch (e: Exception) {
                Log.w(TAG, "unregisterCallback: 不需要取消注册。 ${e.message}")
            }
        }

        override fun onBindingDied(name: ComponentName?) {
            Log.d(TAG, "ServiceConnection.onBindingDied: ${name?.toString()}")
            reconnect()
        }

    }
    internal fun reconnect() {
        val application = PluginManager.appContext
        try {
            application.unbindService(serviceConnection)
        } catch (e: Exception) {
            Log.w(TAG, "unbindService: 不需要解绑。 ${e.message}")
        }
        coroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
        statusClient = CommandClient(
            coroutineScope,
            CommandClient.ConnectionType.Status,
            StatusClient()
        )
        groupClient = CommandClient(
            coroutineScope,
            CommandClient.ConnectionType.Groups,
            GroupClient()
        )
        clashModeClient = CommandClient(
            coroutineScope,
            CommandClient.ConnectionType.ClashMode,
            ClashModeClient()
        )

        val intent = Intent(application, SettingsManager.serviceClass())
        intent.action = Action.SERVICE
        application.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
    }

    internal fun disconnect() {
        try {
            PluginManager.appContext.unbindService(serviceConnection)
            disconnectClient()
            coroutineScope.cancel()
        } catch (e: Exception) {
            Log.w(TAG, "unbindService: 不需要解绑。 ${e.message}")
        }
    }

    private fun connectClient() {
        statusClient.connect()
        groupClient.connect()
        clashModeClient.connect()
    }

    private fun disconnectClient() {
        statusClient.disconnect()
        groupClient.disconnect()
        clashModeClient.disconnect()
    }

    class ServiceCallback() : IServiceCallback.Stub() {
        override fun onServiceStatusChanged(status: Int) {
            Log.d(TAG, "onServiceStatusChanged: $status")
            if (status == Status.Started.ordinal) {
                connectClient()
            } else if (status == Status.Stopped.ordinal) {
                disconnectClient()
            }
        }

        override fun onServiceAlert(type: Int, message: String?) {
            Log.e(TAG, "onServiceAlert: $type $message")
            disconnectClient()
        }

    }

    class StatusClient : CommandClient.Handler {
        override fun onConnected() {
            Log.d(TAG, "onConnected: ")
        }
        override fun onDisconnected() {
            Log.d(TAG, "onDisconnected: ")
        }

        override fun updateStatus(status: StatusMessage) {
            Log.d(TAG, "updateStatus: $status")
            // Log.d(TAG, "updateStatus: ${ProfileManager.getAllKeys()}")
            val statusMap = mapOf(
                "connectionsIn" to status.connectionsIn,
                "connectionsOut" to status.connectionsOut,
                "uplink" to status.uplink,
                "downlink" to status.downlink,
                "uplinkTotal" to status.uplinkTotal,
                "downlinkTotal" to status.downlinkTotal,
                "memory" to status.memory
            )
            coroutineScope.launch(Dispatchers.Main.immediate) {
                statusSink?.success(statusMap)
            }
        }
    }

    class GroupClient : CommandClient.Handler {
        override fun updateGroups(newGroups: MutableList<OutboundGroup>) {
            Log.d(TAG, "updateGroups: $newGroups")
            coroutineScope.launch(Dispatchers.Main.immediate) {
                groupSink?.success(newGroups.toString())
            }
        }
    }

    class ClashModeClient : CommandClient.Handler {
        override fun initializeClashMode(modeList: List<String>, currentMode: String) {
            Log.d(TAG, "initializeClashMode: $modeList $currentMode")
            coroutineScope.launch(Dispatchers.Main.immediate) {
                clashModeSink?.success(mapOf("modeList" to modeList, "currentMode" to currentMode))
            }
        }
        override fun updateClashMode(newMode: String) {
            Log.d(TAG, "updateClashMode: $newMode")
            coroutineScope.launch(Dispatchers.Main.immediate) {
                clashModeSink?.success(mapOf("currentMode" to newMode))
            }
        }
    }
}