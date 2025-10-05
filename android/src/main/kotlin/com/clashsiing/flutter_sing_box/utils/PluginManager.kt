package com.clashsiing.flutter_sing_box.utils

import android.app.NotificationManager
import android.content.Context
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import androidx.core.content.getSystemService

object PluginManager {
    private const val ERROR_MSG = "PluginManager not initialized. Call PluginManager.init() first."
    @Volatile
    private var _appContext: Context? =  null

    val appContext: Context
        get() = _appContext ?: throw throwError()

    private var _isDebug: Boolean? = null

    val isDebug: Boolean
        get() = _isDebug ?: throw throwError()

    private var _packageName: String? =  null

    val packageName: String
        get() = _packageName ?: throw throwError()

    private var _versionName: String? =  null

    val versionName: String
        get() = _versionName ?: throw throwError()

    private var _versionCode: Long? = null

    val versionCode: Long
        get() = _versionCode ?: throw throwError()

    /**
     * Initializes the configuration. Called from the main plugin class.
     */
    fun init(
        context: Context,
        isDebug: Boolean,
        packageName: String,
        versionName: String,
        versionCode: Long
    ) {
        val checkedResult = _appContext
        if (checkedResult != null) {
            return
        }
        synchronized(this) {
            val doubleCheckedResult = _appContext
            if (doubleCheckedResult != null) {
                return
            }
            this._appContext = context.applicationContext
            this._isDebug = isDebug
            this._packageName = packageName
            this._versionName = versionName
            this._versionCode = versionCode
        }
    }

    val connectivity by lazy { appContext.getSystemService<ConnectivityManager>() ?: throw throwError() }

    val packageManager by lazy { appContext.packageManager ?: throw throwError() }

    val wifiManager by lazy { appContext.getSystemService<WifiManager>() ?: throw throwError() }

    val notification by lazy { appContext.getSystemService<NotificationManager>() ?: throw throwError() }

    val launchIntent by lazy { packageManager.getLaunchIntentForPackage(packageName) ?: throw throwError() }

    private fun throwError() : Throwable = IllegalStateException(ERROR_MSG)

}