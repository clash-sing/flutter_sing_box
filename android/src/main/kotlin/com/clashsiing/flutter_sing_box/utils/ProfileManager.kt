package com.clashsiing.flutter_sing_box.utils

import com.clashsiing.flutter_sing_box.cs.models.Profile
import com.clashsiing.flutter_sing_box.cs.models.SelectedProxy
import com.tencent.mmkv.MMKV
import kotlinx.serialization.json.Json

object ProfileManager {
    private val mmkv = MMKV.mmkvWithID("cs-profile", MMKV.SINGLE_PROCESS_MODE)

    fun getAllKeys() : List<String>? {
        return  mmkv.allKeys()?.toList()
    }
    fun getSelectedProxy(): SelectedProxy? {
        val content = mmkv.decodeString(Keys.SELECTED_PROXY)
        return if (content == null) null
        else Json.decodeFromString<SelectedProxy>(content)
    }
    private fun getProfileKey(id: Int): String {
        return "${Keys.PROFILE_PREFIX}$id"
    }
    fun getProfile(id: Int) : Profile? {
        val content = mmkv.decodeString(getProfileKey(id))
        return if (content == null) null
        else Json.decodeFromString<Profile>(content)
    }

    private object Keys {
        const val PROFILE_PREFIX: String = "profile_"
        const val SELECTED_PROXY: String = "selected_proxy"
    }
}