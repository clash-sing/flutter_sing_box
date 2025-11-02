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
import io.flutter.plugin.common.EventChannel
import io.nekohasekai.libbox.OutboundGroup
import io.nekohasekai.libbox.StatusMessage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json

object SingBoxConnector {
    private const val TAG = "SingBoxConnector"
    private lateinit var statusClient: CommandClient
    private lateinit var groupClient: CommandClient
    private lateinit var clashModeClient: CommandClient
    private lateinit var logClient: CommandClient
    private lateinit var coroutineScope: CoroutineScope
    private var service: IService? = null
    var statusSink: EventChannel.EventSink? = null
    var groupSink: EventChannel.EventSink? = null
    var clashModeSink: EventChannel.EventSink? = null
    var logSink: EventChannel.EventSink? = null
    var proxyStateSink: EventChannel.EventSink? = null
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
        logClient = CommandClient(
            coroutineScope,
            CommandClient.ConnectionType.Log,
            LogClient()
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
        logClient.connect()
    }

    private fun disconnectClient() {
        statusClient.disconnect()
        groupClient.disconnect()
        clashModeClient.disconnect()
        logClient.disconnect()
    }

    class ServiceCallback() : IServiceCallback.Stub() {
        override fun onServiceStatusChanged(status: Int) {
            Log.d(TAG, "onServiceStatusChanged: $status")
            val proxyStatus: Status = when (status) {
                Status.Stopped.ordinal -> Status.Stopped
                Status.Starting.ordinal -> Status.Starting
                Status.Started.ordinal -> Status.Started
                Status.Stopping.ordinal -> Status.Stopping
                else -> throw IllegalArgumentException("Unknown status: $status")
            }
            coroutineScope.launch(Dispatchers.Main.immediate) {
                proxyStateSink?.success(proxyStatus.name)
            }
            if (proxyStatus == Status.Started) {
                connectClient()
            } else if (proxyStatus == Status.Stopped) {
                disconnectClient()
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

    class StatusClient : CommandClient.Handler {
        override fun onConnected() {
            Log.d(TAG, "onConnected: ")
        }
        override fun onDisconnected() {
            Log.d(TAG, "onDisconnected: ")
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
                statusSink?.success(Json.encodeToString(clientStatus))
            }
        }
    }

    class GroupClient : CommandClient.Handler {
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

    class ClashModeClient : CommandClient.Handler {
        private var clashModeList = listOf<String>()
        override fun initializeClashMode(modeList: List<String>, currentMode: String) {
            Log.d(TAG, "initializeClashMode: $modeList $currentMode")
            clashModeList = modeList
            val clientClashMode = ClientClashMode(
                modes = clashModeList,
                currentMode = currentMode
            )
            coroutineScope.launch(Dispatchers.Main.immediate) {
                clashModeSink?.success(Json.encodeToString(clientClashMode))
            }
        }
        override fun updateClashMode(newMode: String) {
            Log.d(TAG, "updateClashMode: $newMode")
            val clientClashMode = ClientClashMode(
                modes = clashModeList,
                currentMode = newMode
            )
            coroutineScope.launch(Dispatchers.Main.immediate) {
                clashModeSink?.success(Json.encodeToString(clientClashMode))
            }
        }
    }

    class LogClient : CommandClient.Handler {
        override fun clearLogs() {
            Log.d(TAG, "clearLogs: -------------------------")
        }
        override fun appendLogs(message: List<String>) {
            Log.d(TAG, "appendLogs: $message")
            coroutineScope.launch(Dispatchers.Main.immediate) {
                logSink?.success(Json.encodeToString(message))
            }
        }
    }
}