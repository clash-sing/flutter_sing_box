package com.clashsiing.flutter_sing_box_example

import android.app.Application
import android.util.Log
import com.clashsiing.flutter_sing_box.cs.PluginManager
import com.tencent.mmkv.MMKV

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        val rootDir = MMKV.initialize(this)
        Log.d("MyApplication", "MMKV rootDir: $rootDir")
        PluginManager.init(this, false)
    }
}