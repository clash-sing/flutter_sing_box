package com.clashsiing.flutter_sing_box_example

import android.app.Application
import android.util.Log
import com.tencent.mmkv.MMKV

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MMKV.initialize(this)
        Log.d("MyApplication", "MMKV init success")
    }
}