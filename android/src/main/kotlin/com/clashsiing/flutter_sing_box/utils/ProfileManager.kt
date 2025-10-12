package com.clashsiing.flutter_sing_box.utils

import com.tencent.mmkv.MMKV

object ProfileManager {
    private val mmkv = MMKV.mmkvWithID("cs-sing-box", MMKV.MULTI_PROCESS_MODE)


    fun get(id: Long): Profile? {
        return mmkv.decodeParcelable(id.toString(), Profile::class.java)
    }

    @Deprecated("Just for debug")
    fun getContent(): String? {
        val profile = mmkv.decodeString("profile")
        return profile
    }
}