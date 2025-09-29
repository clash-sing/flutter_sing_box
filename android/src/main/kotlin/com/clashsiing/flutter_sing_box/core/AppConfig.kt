package com.clashsiing.flutter_sing_box.core

import android.content.Context

object AppConfig {
    lateinit var appContext: Context
        private set

    var isDebug: Boolean = false
        private set

    var packageName: String = ""
        private set

    var versionName: String = ""
        private set

    var versionCode: Long = 1
        private set

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
        this.appContext = context.applicationContext
        this.isDebug = isDebug
        this.packageName = packageName
        this.versionName = versionName
        this.versionCode = versionCode
    }
}