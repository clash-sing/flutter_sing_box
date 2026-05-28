package io.nekohasekai.sfa.bg

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.ParcelFileDescriptor
import android.os.PowerManager
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.MutableLiveData
import com.clashsing.flutter_sing_box.R
import com.clashsing.flutter_sing_box.cs.PluginManager
import com.clashsing.flutter_sing_box.utils.ProfileManager
import com.clashsing.flutter_sing_box.utils.SettingsManager
import io.nekohasekai.libbox.CommandServer
import io.nekohasekai.libbox.CommandServerHandler
import io.nekohasekai.libbox.Notification
import io.nekohasekai.libbox.OverrideOptions
import io.nekohasekai.libbox.PlatformInterface
import io.nekohasekai.libbox.SystemProxyStatus
//import io.nekohasekai.sfa.Application
//import io.nekohasekai.sfa.R
//import io.nekohasekai.sfa.compose.MainActivity
import io.nekohasekai.sfa.constant.Action
import io.nekohasekai.sfa.constant.Alert
import io.nekohasekai.sfa.constant.Status
//import io.nekohasekai.sfa.database.ProfileManager
//import io.nekohasekai.sfa.database.Settings
import io.nekohasekai.sfa.ktx.hasPermission
//import io.nekohasekai.sfa.vendor.Vendor
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext

class BoxService(private val service: Service, private val platformInterface: PlatformInterface) : CommandServerHandler {
    companion object {
        fun start() {
            val intent =
                runBlocking {
                    withContext(Dispatchers.IO) {
                        Intent(PluginManager.appContext, SettingsManager.serviceClass())
                    }
                }
            ContextCompat.startForegroundService(PluginManager.appContext, intent)
        }

        fun stop() {
            PluginManager.appContext.sendBroadcast(
                Intent(Action.SERVICE_CLOSE).setPackage(
                    PluginManager.appContext.packageName,
                ),
            )
        }
        // 修复 ‘serviceReload’
        fun restart() {
            PluginManager.appContext.sendBroadcast(
                Intent(Action.SERVICE_RESTART).setPackage(
                    PluginManager.appContext.packageName,
                ),
            )
        }
    }

    var fileDescriptor: ParcelFileDescriptor? = null

    private val status = MutableLiveData(Status.Stopped)
    private val binder = ServiceBinder(status)
    private val notification = ServiceNotification(status, service)
    private lateinit var commandServer: CommandServer

    private var receiverRegistered = false
    private val receiver =
        object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    Action.SERVICE_CLOSE -> {
                        stopService()
                    }
                    // 修复 ‘serviceReload’
                    Action.SERVICE_RESTART -> {
                        stopService(isRestart = true)
                    }

                    PowerManager.ACTION_DEVICE_IDLE_MODE_CHANGED -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            serviceUpdateIdleMode()
                        }
                    }
                }
            }
        }

    private fun startCommandServer() {
        val commandServer = CommandServer(this, platformInterface)
        commandServer.start()
        this.commandServer = commandServer
    }

    private var lastProfileName = ""

    private suspend fun startService() {
        try {
            withContext(Dispatchers.Main) {
                notification.show(lastProfileName, R.string.status_starting)
            }

//            val selectedProfileId = Settings.selectedProfile
//            if (selectedProfileId == -1L) {
//                stopAndAlert(Alert.EmptyConfiguration)
//                return
//            }
//
//            val profile = ProfileManager.get(selectedProfileId)
//            if (profile == null) {
//                stopAndAlert(Alert.EmptyConfiguration)
//                return
//            }
//
//            val content = File(profile.typed.path).readText()
            val configFile = ProfileManager.getUsingConfig()
            val profile = ProfileManager.getSelectedProfile()
            if (profile == null || !configFile.exists()) {
                stopAndAlert(Alert.EmptyConfiguration)
                return
            }
            val content = configFile.readText()
            if (content.isBlank()) {
                stopAndAlert(Alert.EmptyConfiguration)
                return
            }

            lastProfileName = profile.name
            withContext(Dispatchers.Main) {
                notification.show(lastProfileName, R.string.status_starting)
            }

            DefaultNetworkMonitor.start()

            try {
                commandServer.startOrReloadService(
                    content,
                    OverrideOptions().apply {
                        autoRedirect = SettingsManager.autoRedirect
//                        if (Vendor.isPerAppProxyAvailable() && Settings.perAppProxyEnabled) {
//                            val appList = Settings.getEffectivePerAppProxyList()
//                            if (Settings.getEffectivePerAppProxyMode() == Settings.PER_APP_PROXY_INCLUDE) {
//                                includePackage =
//                                    PlatformInterfaceWrapper.StringArray((appList + Application.application.packageName).iterator())
//                            } else {
//                                excludePackage =
//                                    PlatformInterfaceWrapper.StringArray((appList - Application.application.packageName).iterator())
//                            }
//                        }
                    },
                )
            } catch (e: Exception) {
                stopAndAlert(Alert.CreateService, e.message)
                return
            }

            if (commandServer.needWIFIState()) {
                val wifiPermission =
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                        android.Manifest.permission.ACCESS_FINE_LOCATION
                    } else {
                        android.Manifest.permission.ACCESS_BACKGROUND_LOCATION
                    }
                if (!service.hasPermission(wifiPermission)) {
                    stopAndAlert(Alert.RequestLocationPermission)
                    return
                }
            }

            status.postValue(Status.Started)
            withContext(Dispatchers.Main) {
                notification.show(lastProfileName, R.string.status_started)
            }
            notification.start()
        } catch (e: Exception) {
            stopAndAlert(Alert.StartService, e.message)
            return
        }
    }

    override fun serviceStop() {
        notification.close()
        status.postValue(Status.Starting)
        val pfd = fileDescriptor
        if (pfd != null) {
            pfd.close()
            fileDescriptor = null
        }
        closeService()
    }

    override fun serviceReload() {
        // 修复 ‘serviceReload’
        restart()
//        runBlocking {
//            serviceReload0()
//        }
    }

    suspend fun serviceReload0() {
//        val selectedProfileId = Settings.selectedProfile
//        if (selectedProfileId == -1L) {
//            stopAndAlert(Alert.EmptyConfiguration)
//            return
//        }
//
//        val profile = ProfileManager.get(selectedProfileId)
//        if (profile == null) {
//            stopAndAlert(Alert.EmptyConfiguration)
//            return
//        }
//
//        val content = File(profile.typed.path).readText()

        val configFile = ProfileManager.getUsingConfig()
        val profile = ProfileManager.getSelectedProfile()
        if (profile == null || !configFile.exists()) {
            stopAndAlert(Alert.EmptyConfiguration)
            return
        }
        val content = configFile.readText()
        if (content.isBlank()) {
            stopAndAlert(Alert.EmptyConfiguration)
            return
        }
        lastProfileName = profile.name
        // Bug fix：切换配置文件时，通知栏显示的配置文件名可能不是最新的
        withContext(Dispatchers.Main) {
            notification.show(lastProfileName, R.string.status_starting)
        }
        try {
            commandServer.startOrReloadService(
                content,
                OverrideOptions().apply {
                    autoRedirect = SettingsManager.autoRedirect
//                    if (Vendor.isPerAppProxyAvailable() && Settings.perAppProxyEnabled) {
//                        val appList = Settings.getEffectivePerAppProxyList()
//                        if (Settings.getEffectivePerAppProxyMode() == Settings.PER_APP_PROXY_INCLUDE) {
//                            includePackage = PlatformInterfaceWrapper.StringArray((appList + Application.application.packageName).iterator())
//                        } else {
//                            excludePackage = PlatformInterfaceWrapper.StringArray((appList - Application.application.packageName).iterator())
//                        }
//                    }
                },
            )
        } catch (e: Exception) {
            stopAndAlert(Alert.CreateService, e.message)
            return
        }

        if (commandServer.needWIFIState()) {
            val wifiPermission =
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    android.Manifest.permission.ACCESS_FINE_LOCATION
                } else {
                    android.Manifest.permission.ACCESS_BACKGROUND_LOCATION
                }
            if (!service.hasPermission(wifiPermission)) {
                stopAndAlert(Alert.RequestLocationPermission)
                return
            }
        }
    }

    override fun getSystemProxyStatus(): SystemProxyStatus? {
        val status = SystemProxyStatus()
        if (service is VPNService) {
            status.available = service.systemProxyAvailable
            status.enabled = service.systemProxyEnabled
        }
        return status
    }

    override fun setSystemProxyEnabled(isEnabled: Boolean) {
        serviceReload()
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun serviceUpdateIdleMode() {
        if (PluginManager.powerManager.isDeviceIdleMode) {
            commandServer.pause()
        } else {
            commandServer.wake()
        }
    }

    /**
     * 修复 ‘serviceReload’，添加参数 isRestart
     *
     */
    @OptIn(DelicateCoroutinesApi::class)
    private fun stopService(isRestart: Boolean = false) {
        if (status.value != Status.Started) return
        status.value = Status.Stopping
        if (receiverRegistered) {
            service.unregisterReceiver(receiver)
            receiverRegistered = false
        }
        notification.close()
        GlobalScope.launch(Dispatchers.IO) {
            val pfd = fileDescriptor
            if (pfd != null) {
                pfd.close()
                fileDescriptor = null
            }
            DefaultNetworkMonitor.stop()
            closeService()
            commandServer.apply {
                close()
//                Seq.destroyRef(refnum)
            }
            SettingsManager.startedByUser = false
            withContext(Dispatchers.Main) {
                status.value = Status.Stopped
                service.stopSelf()
//                修复 ‘serviceReload’
                if (isRestart) {
                    start()
                }
            }
        }
    }

    private fun closeService() {
        runCatching {
            commandServer.closeService()
        }.onFailure {
            commandServer.setError("android: close service: ${it.message}")
        }
    }

    private suspend fun stopAndAlert(type: Alert, message: String? = null) {
        SettingsManager.startedByUser = false
        val pfd = fileDescriptor
        if (pfd != null) {
            pfd.close()
            fileDescriptor = null
        }
        DefaultNetworkMonitor.stop()
        if (::commandServer.isInitialized) {
            closeService()
            commandServer.close()
        }
        withContext(Dispatchers.Main) {
            if (receiverRegistered) {
                service.unregisterReceiver(receiver)
                receiverRegistered = false
            }
            notification.close()
            binder.broadcast { callback ->
                callback.onServiceAlert(type.ordinal, message)
            }
            status.value = Status.Stopped
            service.stopSelf()
        }
    }

    @OptIn(DelicateCoroutinesApi::class)
    @Suppress("SameReturnValue")
    internal fun onStartCommand(): Int {
        if (status.value != Status.Stopped) return Service.START_NOT_STICKY
        status.value = Status.Starting

        if (!receiverRegistered) {
            ContextCompat.registerReceiver(
                service,
                receiver,
                IntentFilter().apply {
                    addAction(Action.SERVICE_CLOSE)
                    addAction(Action.SERVICE_RESTART)     // 修复 ‘serviceReload’
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        addAction(PowerManager.ACTION_DEVICE_IDLE_MODE_CHANGED)
                    }
                },
                ContextCompat.RECEIVER_NOT_EXPORTED,
            )
            receiverRegistered = true
        }

        GlobalScope.launch(Dispatchers.IO) {
            SettingsManager.startedByUser = true
            try {
                startCommandServer()
            } catch (e: Exception) {
                stopAndAlert(Alert.StartCommandServer, e.message)
                return@launch
            }
            startService()
        }
        return Service.START_NOT_STICKY
    }

    internal fun onBind(): IBinder = binder

    internal fun onDestroy() {
        binder.close()
    }

    internal fun onRevoke() {
        stopService()
    }

    internal fun sendNotification(notification: Notification) {
        val builder =
            NotificationCompat.Builder(service, notification.identifier).setShowWhen(false)
                .setContentTitle(notification.title).setContentText(notification.body)
                .setOnlyAlertOnce(true).setSmallIcon(R.drawable.ic_menu)
                .setCategory(NotificationCompat.CATEGORY_EVENT)
                .setPriority(NotificationCompat.PRIORITY_HIGH).setAutoCancel(true)
        if (!notification.subtitle.isNullOrBlank()) {
            builder.setContentInfo(notification.subtitle)
        }
        if (!notification.openURL.isNullOrBlank()) {
            builder.setContentIntent(
                PendingIntent.getActivity(
                    service,
                    0,
                    PluginManager.launchIntent.apply {
                        setAction(Action.OPEN_URL).setData(Uri.parse(notification.openURL))
                        setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                    },
                    ServiceNotification.flags,
                ),
            )
        }
        GlobalScope.launch(Dispatchers.Main) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                PluginManager.notification.createNotificationChannel(
                    NotificationChannel(
                        notification.identifier,
                        notification.typeName,
                        NotificationManager.IMPORTANCE_HIGH,
                    ),
                )
            }
            PluginManager.notification.notify(notification.typeID, builder.build())
        }
    }

    override fun writeDebugMessage(message: String?) {
        Log.d("sing-box", message!!)
    }
}
