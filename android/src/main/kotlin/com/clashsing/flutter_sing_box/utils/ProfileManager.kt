package com.clashsing.flutter_sing_box.utils

import com.tencent.mmkv.MMKV
import java.io.File

object ProfileManager {
    const val MMKV_ID = "cs_profile"
    private val mmkv by lazy {
        MMKV.mmkvWithID(MMKV_ID, MMKV.MULTI_PROCESS_MODE)
    }

    // Dart 侧经 CoreStorage.setSelectedProfileName 写入的交接键,仅用于通知栏展示名称
    fun getSelectedProfileName(): String? {
        return mmkv.decodeString(Keys.SELECTED_PROFILE_NAME)
    }

    fun getUsingConfig(): File {
        return File(
            mmkv.decodeString(Keys.USING_CONFIG, ""),
            Keys.USING_CONFIG_FILE_NAME
        )
    }

    private object Keys {
        const val SELECTED_PROFILE_NAME: String = "selected_profile_name"
        const val USING_CONFIG: String = "using_config"
        const val USING_CONFIG_FILE_NAME: String = "using_config.json"
    }
}
