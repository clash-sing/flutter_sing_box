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
import com.clashsiing.flutter_sing_box.cs.models.ClientClashMode
import com.clashsiing.flutter_sing_box.cs.models.ClientGroup
import com.clashsiing.flutter_sing_box.cs.models.ClientStatus
import com.clashsiing.flutter_sing_box.utils.CommandClient
import com.clashsiing.flutter_sing_box.utils.SettingsManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.nekohasekai.libbox.OutboundGroup
import io.nekohasekai.libbox.StatusMessage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json

class SingBoxConnector(private val applicationContext: Context, val binaryMessenger: BinaryMessenger) {

    companion object {
        private const val TAG = "SingBoxConnector"
        private const val EVENT_CHANNEL_CONNECTED_STATUS = "connected_status_event"
        private const val EVENT_CHANNEL_GROUP = "group_event"
        private const val EVENT_CHANNEL_CLASH_MODE = "clash_mode_event"
        private const val EVENT_CHANNEL_LOG = "log_event"
        private const val EVENT_CHANNEL_PROXY_STATE = "proxy_state_event"
    }

    private lateinit var statusClient: CommandClient
    private lateinit var groupClient: CommandClient
    private lateinit var clashModeClient: CommandClient
    private lateinit var logClient: CommandClient
    private lateinit var coroutineScope: CoroutineScope

    private var service: IService? = null

    @Volatile
    private var statusSink: EventChannel.EventSink? = null
    @Volatile
    private var groupSink: EventChannel.EventSink? = null
    @Volatile
    private var clashModeSink: EventChannel.EventSink? = null
    @Volatile
    private var logSink: EventChannel.EventSink? = null
    @Volatile
    private var proxyStateSink: EventChannel.EventSink? = null

    @Volatile
    internal var clientClashMode: ClientClashMode? = null

    private val callback = ServiceCallback()

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            service = IService.Stub.asInterface(binder)
            coroutineScope.launch {
                service?.apply {
                    registerCallback(callback)
                    callback.onServiceStatusChanged(status)
                }
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
            connect()
        }
    }

    private fun createEventChannel() {
        EventChannel(binaryMessenger, EVENT_CHANNEL_CONNECTED_STATUS).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { statusSink = events }
            override fun onCancel(arguments: Any?) { statusSink = null }
        })
        EventChannel(binaryMessenger, EVENT_CHANNEL_GROUP).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { groupSink = events }
            override fun onCancel(arguments: Any?) { groupSink = null }
        })
        EventChannel(binaryMessenger, EVENT_CHANNEL_CLASH_MODE).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { clashModeSink = events }
            override fun onCancel(arguments: Any?) { clashModeSink = null }
        })
        EventChannel(binaryMessenger, EVENT_CHANNEL_LOG).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { logSink = events }
            override fun onCancel(arguments: Any?) { logSink = null }
        })
        EventChannel(binaryMessenger, EVENT_CHANNEL_PROXY_STATE).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { proxyStateSink = events }
            override fun onCancel(arguments: Any?) { proxyStateSink = null }
        })
    }

    fun connect() {
        if (this::coroutineScope.isInitialized && coroutineScope.coroutineContext.isActive) {
            return
        }
        createEventChannel()
        coroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

        val intent = Intent(applicationContext, SettingsManager.serviceClass())
        intent.action = Action.SERVICE
        applicationContext.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)

        statusClient = CommandClient(coroutineScope, CommandClient.ConnectionType.Status, StatusClient())
        groupClient = CommandClient(coroutineScope, CommandClient.ConnectionType.Groups, GroupClient())
        clashModeClient = CommandClient(coroutineScope, CommandClient.ConnectionType.ClashMode, ClashModeClient())
        logClient = CommandClient(coroutineScope, CommandClient.ConnectionType.Log, LogClient())
    }

    fun disconnect() {
        if (!this::coroutineScope.isInitialized) {
            return
        }
        try {
            coroutineScope.cancel()
            disconnectClient()
            applicationContext.unbindService(serviceConnection)
        } catch (e: Exception) {
            Log.w(TAG, "disconnect: 解绑失败: ${e.message}")
        }
    }

    private fun connectClient() {
        statusClient.connect()
        groupClient.connect()
        clashModeClient.connect()
        logClient.connect()
    }

    private fun disconnectClient() {
        statusClient.disconnect()
        groupClient.disconnect()
        clashModeClient.disconnect()
        logClient.disconnect()
    }

    inner class ServiceCallback : IServiceCallback.Stub() {
        override fun onServiceStatusChanged(status: Int) {
            Log.d(TAG, "onServiceStatusChanged: $status")
            val proxyStatus: Status = when (status) {
                Status.Stopped.ordinal -> Status.Stopped
                Status.Starting.ordinal -> Status.Starting
                Status.Started.ordinal -> Status.Started
                Status.Stopping.ordinal -> Status.Stopping
                else -> throw IllegalArgumentException("Unknown status: $status")
            }
            Log.d(TAG, "proxyStatus: $proxyStatus")
            coroutineScope.launch(Dispatchers.Main.immediate) {
                Log.d(TAG, "proxyStateSink is null: ${proxyStateSink == null}")
                proxyStateSink?.success(proxyStatus.name)
            }
            coroutineScope.launch {
                if (proxyStatus == Status.Started) {
                    connectClient()
                } else if (proxyStatus == Status.Stopped) {
                    disconnectClient()
                }
            }
        }

        override fun onServiceAlert(type: Int, message: String?) {
            Log.e(TAG, "onServiceAlert: $type $message")
            coroutineScope.launch(Dispatchers.Main.immediate) {
                proxyStateSink?.success(Status.Stopped.name)
            }
            disconnectClient()
        }
    }

    inner class StatusClient : CommandClient.Handler {
        override fun onConnected() {
            Log.d(TAG, "onConnected:  -------------------------")
        }
        override fun onDisconnected() {
            Log.d(TAG, "onDisconnected:  -------------------------")
        }

        override fun updateStatus(status: StatusMessage) {
            val clientStatus = ClientStatus(
                memory = status.memory,
                goroutines = status.goroutines,
                connectionsIn = status.connectionsIn,
                connectionsOut = status.connectionsOut,
                trafficAvailable = status.trafficAvailable,
                uplink = status.uplink,
                downlink = status.downlink,
                uplinkTotal = status.uplinkTotal,
                downlinkTotal = status.downlinkTotal
            )
            coroutineScope.launch(Dispatchers.Main.immediate) {
                clientClashMode?.let {
                    clashModeSink?.success(Json.encodeToString(clientClashMode))
                }
                statusSink?.success(Json.encodeToString(clientStatus))
            }
        }
    }

    inner class GroupClient : CommandClient.Handler {
        override fun updateGroups(newGroups: MutableList<OutboundGroup>) {
            Log.d(TAG, "updateGroups: $newGroups")
            val clientGroups: List<ClientGroup> = newGroups.map {
                ClientGroup(
                    tag = it.tag,
                    type = it.type,
                    selectable = it.selectable,
                    selected = it.selected,
                    isExpand = it.isExpand,
                    item = if (it.items.hasNext()) ClientGroup.GroupItem(
                        tag = it.items.next().tag,
                        type = it.items.next().type,
                        urlTestDelay = it.items.next().urlTestDelay,
                        getURLTestTime = it.items.next().urlTestTime,
                    ) else null
                )
            }
            coroutineScope.launch(Dispatchers.Main.immediate) {
                groupSink?.success(Json.encodeToString(clientGroups))
            }
        }
    }

    inner class ClashModeClient : CommandClient.Handler {
        override fun initializeClashMode(modeList: List<String>, currentMode: String) {
            Log.d(TAG, "initializeClashMode: $modeList $currentMode")
            clientClashMode = ClientClashMode(
                modes = modeList,
                currentMode = currentMode
            )
//            coroutineScope.launch(Dispatchers.Main.immediate) {
//                clashModeSink?.success(Json.encodeToString(clientClashMode))
//            }
        }
        override fun updateClashMode(newMode: String) {
            Log.d(TAG, "updateClashMode: $newMode")
            clientClashMode?.copy(currentMode = newMode)
//            coroutineScope.launch(Dispatchers.Main.immediate) {
//                clashModeSink?.success(Json.encodeToString(clientClashMode))
//            }
        }
    }

    inner class LogClient : CommandClient.Handler {
        override fun clearLogs() {
            Log.d(TAG, "clearLogs: -------------------------")
        }
        override fun appendLogs(message: List<String>) {
//            Log.d(TAG, "appendLogs: $message")
            coroutineScope.launch(Dispatchers.Main.immediate) {
                logSink?.success(Json.encodeToString(message))
            }
        }
    }
}
