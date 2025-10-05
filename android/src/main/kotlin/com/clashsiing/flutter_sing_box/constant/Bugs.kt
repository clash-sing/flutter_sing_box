package com.clashsiing.flutter_sing_box.constant

import android.os.Build
import com.clashsiing.flutter_sing_box.utils.PluginManager

object Bugs {

    // TODO: remove launch after fixed
    // https://github.com/golang/go/issues/68760
    val fixAndroidStack = PluginManager.isDebug ||
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && Build.VERSION.SDK_INT <= Build.VERSION_CODES.N_MR1 ||
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.P

}