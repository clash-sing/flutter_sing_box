package com.clashsiing.flutter_sing_box.utils

import com.tencent.mmkv.MMKV

object SettingsManager {
    private val mmkv = MMKV.mmkvWithID("cs-settings", MMKV.MULTI_PROCESS_MODE)

    val dynamicNotification = mmkv.decodeBool(Keys.DYNAMIC_NOTIFICATION, true)

    object Keys {
        const val DYNAMIC_NOTIFICATION = "dynamic_notification"
    }
}