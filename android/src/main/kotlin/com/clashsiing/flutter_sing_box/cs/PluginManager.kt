package com.clashsiing.flutter_sing_box.cs

import android.app.NotificationManager
import android.content.Context
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import android.os.PowerManager
import androidx.core.content.getSystemService
import com.clashsiing.flutter_sing_box.constant.Bugs
import com.tencent.mmkv.MMKV
import go.Seq
import io.nekohasekai.libbox.Libbox
import io.nekohasekai.libbox.SetupOptions
import java.io.File
import java.util.Locale

object PluginManager {
    private const val TAG = "PluginManager"

    private val mmkv = MMKV.mmkvWithID("clash_sing_plugin", MMKV.MULTI_PROCESS_MODE)

    private const val ERROR_MSG = "PluginManager not initialized. Call PluginManager.init() first."
    @Volatile
    private var _appContext: Context? =  null
    val appContext: Context get() = _appContext ?: throw throwError()

    /**
     * Initializes the configuration. Called from the main plugin class.
     */
    fun init(context: Context, isDebug: Boolean? = null) {
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
            if (isDebug != null) {
                mmkv.encode(Keys.DEBUG, isDebug)
            }
            initSingBox()
        }
    }

    private fun initSingBox() {
        Seq.setContext(appContext)
        Libbox.setLocale(Locale.getDefault().toLanguageTag().replace("-", "_"))
        val baseDir = appContext.filesDir
        baseDir.mkdirs()
        val workingDir = appContext.getExternalFilesDir(null) ?: return
        workingDir.mkdirs()
        val tempDir = appContext.cacheDir
        tempDir.mkdirs()
        Libbox.setup(SetupOptions().also {
            it.basePath = baseDir.path
            it.workingPath = workingDir.path
            it.tempPath = tempDir.path
            it.fixAndroidStack = Bugs.fixAndroidStack
        })
        Libbox.redirectStderr(File(workingDir, "stderr.log").path)
    }


    val connectivity by lazy { appContext.getSystemService<ConnectivityManager>() ?: throw throwError() }

    val packageManager by lazy { appContext.packageManager ?: throw throwError() }

    val wifiManager by lazy { appContext.getSystemService<WifiManager>() ?: throw throwError() }

    val notification by lazy { appContext.getSystemService<NotificationManager>() ?: throw throwError() }

    val launchIntent by lazy { packageManager.getLaunchIntentForPackage(appContext.packageName) ?: throw throwError() }

    val powerManager by lazy { appContext.getSystemService<PowerManager>() ?: throw throwError() }

    private fun throwError() : Throwable = IllegalStateException(ERROR_MSG)

    val isDebug: Boolean
        get() = mmkv.decodeBool(Keys.DEBUG, false)


    private object Keys {
        const val DEBUG = "debug"
    }
}