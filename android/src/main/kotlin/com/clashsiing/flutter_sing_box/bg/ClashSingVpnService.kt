package com.clashsiing.flutter_sing_box.bg

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.VpnService
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

@SuppressLint("VpnServicePolicy")
class ClashSingVpnService : VpnService() {

    companion object {
        const val NOTIFICATION_ID = 1
        const val CHANNEL_ID = "ForegroundServiceChannel"
    }

    private var serviceScope: CoroutineScope? = null
    private val notificationManager by lazy {
        getSystemService(NOTIFICATION_SERVICE) as NotificationManager
    }
    private val notificationBuilder by lazy {
        NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.mipmap.sym_def_app_icon)
            .setContentTitle("前台服务正在运行")
            .setContentText("点击可返回应用")
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, notificationBuilder.build())
        if (intent?.action == "STOP_SERVICE") {
            stopSelf()
            return START_NOT_STICKY
        } else {
            if (serviceScope?.isActive != true) {
                doHeavyWork()
            }
            return START_STICKY
        }
    }

    private fun doHeavyWork() {
        if (serviceScope?.isActive != true) {
            serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
            serviceScope?.launch {
                while (isActive) {
                    delay(1000)
                    notificationManager.notify(
                        NOTIFICATION_ID,
                        notificationBuilder.setContentText("Time: ${System.currentTimeMillis()}").build()
                    )
                    println("Foreground Service is running... ${System.currentTimeMillis()}")
                }
                // 在这里执行你的耗时任务
            }
        }
    }

    private fun createNotificationChannel() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "前台服务通知",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "用于前台服务持续运行的通知"
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
    override fun onDestroy() {
        serviceScope?.cancel()
        serviceScope = null
        super.onDestroy()
    }
}