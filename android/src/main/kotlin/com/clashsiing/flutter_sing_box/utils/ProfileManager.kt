package com.clashsiing.flutter_sing_box.utils

import com.clashsiing.flutter_sing_box.cs.models.Profile
import com.tencent.mmkv.MMKV
import kotlinx.serialization.json.Json
import java.io.File

object ProfileManager {
    const val MMKV_ID = "cs_profile"
    private val mmkv by lazy {
        MMKV.mmkvWithID(MMKV_ID, MMKV.MULTI_PROCESS_MODE)
    }
    fun getAllKeys() : List<String>? {
        return  mmkv.allKeys()?.toList()
    }
    fun getSelectedProfile(): Profile? {
        val id = mmkv.decodeInt(Keys.SELECTED_PROFILE_ID, -1)
        val profileKey = getProfileKey(id)
        val content = mmkv.decodeString(profileKey)
        return if (content == null) null
        else Json.decodeFromString<Profile>(content)
    }
    private fun getProfileKey(id: Int): String {
        return "${Keys.PROFILE_PREFIX}$id"
    }

    fun getUsingConfig(): File {
        return File(
            mmkv.decodeString(Keys.USING_CONFIG, ""),
            Keys.USING_CONFIG_FILE_NAME
        )
    }

    private object Keys {
        const val PROFILE_PREFIX: String = "profile_"
        const val SELECTED_PROFILE_ID: String = "selected_profile_id"
        const val USING_CONFIG: String = "using_config"
        const val USING_CONFIG_FILE_NAME: String = "using_config.json"
    }
}