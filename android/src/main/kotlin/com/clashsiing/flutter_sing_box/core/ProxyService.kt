package com.clashsiing.flutter_sing_box.core

import android.app.Service
import android.content.Intent
import io.nekohasekai.libbox.Notification
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel

class ProxyService : Service(), PlatformInterfaceWrapper {

    private val coroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val service = BoxService(this, this, coroutineScope)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int) =
        service.onStartCommand()

    override fun onBind(intent: Intent) = service.onBind()
    override fun onDestroy() {
        service.onDestroy()
        coroutineScope.cancel()
    }

    override fun writeLog(message: String) = service.writeLog(message)

    override fun sendNotification(notification: Notification) =
        service.sendNotification(notification)

}