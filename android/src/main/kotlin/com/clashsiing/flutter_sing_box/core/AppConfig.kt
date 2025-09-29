package com.clashsiing.flutter_sing_box.core

import android.content.Context

object AppConfig {
    @Volatile
    private var _appContext: Context? =  null

    val appContext: Context?
        get() = _appContext ?: throw IllegalStateException("AppConfig not initialized")

    private var _isDebug: Boolean? = null

    val isDebug: Boolean
        get() = _isDebug ?: throw IllegalStateException("AppConfig not initialized")

    private var _packageName: String? =  null

    val packageName: String
        get() = _packageName ?: throw IllegalStateException("AppConfig not initialized")

    private var _versionName: String? =  null

    val versionName: String
        get() = _versionName ?: throw IllegalStateException("AppConfig not initialized")

    private var _versionCode: Long? = null

    val versionCode: Long
        get() = _versionCode ?: throw IllegalStateException("AppConfig not initialized")

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
}