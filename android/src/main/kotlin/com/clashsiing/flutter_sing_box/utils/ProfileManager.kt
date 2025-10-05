package com.clashsiing.flutter_sing_box.utils

import com.tencent.mmkv.MMKV

object ProfileManager {
    private val mmkv = MMKV.mmkvWithID("cs-sing-box", MMKV.MULTI_PROCESS_MODE)
    fun getProfile(): String? {
        return mmkv.decodeString("profile")
    }
}