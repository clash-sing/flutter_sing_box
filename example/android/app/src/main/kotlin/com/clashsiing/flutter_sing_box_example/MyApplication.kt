package com.clashsiing.flutter_sing_box_example

import android.app.Application
import android.util.Log
import com.clashsiing.flutter_sing_box.cs.PluginManager
import com.tencent.mmkv.MMKV

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MMKV.initialize(this)
        PluginManager.init(this, false)
        Log.d("MyApplication", "MMKV init success")
    }
}