package com.clashsiing.flutter_sing_box.utils

import com.clashsiing.flutter_sing_box.constant.ServiceMode
import com.clashsiing.flutter_sing_box.core.ClashSingVpnService
import com.clashsiing.flutter_sing_box.core.ProxyService
import com.tencent.mmkv.MMKV

object SettingsManager {
    private val mmkv by lazy {
        MMKV.mmkvWithID("settings_data", MMKV.MULTI_PROCESS_MODE)
    }

    val dynamicNotification = mmkv.decodeBool(Keys.DYNAMIC_NOTIFICATION, true)

    var serviceMode: String
        get() = mmkv.decodeString(Keys.SERVICE_MODE) ?: ServiceMode.VPN
        set(value) {
            mmkv.encode(Keys.SERVICE_MODE, value)
        }

    var selectedProfile: Long
        get() = mmkv.decodeLong(Keys.SELECTED_PROFILE, -1)
        set(value) {
            mmkv.encode(Keys.SELECTED_PROFILE, value)
        }

    fun serviceClass(): Class<*> {
        return when (serviceMode) {
            ServiceMode.VPN -> ClashSingVpnService::class.java
            else -> ProxyService::class.java
        }
    }

    val disableMemoryLimit = mmkv.decodeBool(Keys.DISABLE_MEMORY_LIMIT, false)

    var startedByUser: Boolean
        get() = mmkv.decodeBool(Keys.STARTED_BY_USER, false)
        set(value) {
            mmkv.encode(Keys.STARTED_BY_USER, value)
        }

    var perAppProxyEnabled: Boolean
        get() = mmkv.decodeBool(Keys.PER_APP_PROXY_ENABLED, false)
        set(value) {
            mmkv.encode(Keys.PER_APP_PROXY_ENABLED, value)
        }

    var perAppProxyList: List<String>
        get() = mmkv.decodeStringSet(Keys.PER_APP_PROXY_LIST, emptySet())?.toList() ?: emptyList()
        set(value) {
            mmkv.encode(Keys.PER_APP_PROXY_LIST, value.toSet())
        }

    var perAppProxyMode: Int
        get() = mmkv.decodeInt(Keys.PER_APP_PROXY_MODE,
            Keys.PER_APP_PROXY_EXCLUDE
        )
        set(value) {
            mmkv.encode(Keys.PER_APP_PROXY_MODE, value)
        }

    var systemProxyEnabled: Boolean
        get() = mmkv.decodeBool(Keys.SYSTEM_PROXY_ENABLED, true)
        set(value) {
            mmkv.encode(Keys.SYSTEM_PROXY_ENABLED, value)
        }

    object Keys {
        const val DYNAMIC_NOTIFICATION = "dynamic_notification"
        const val SERVICE_MODE = "service_mode"
        const val SELECTED_PROFILE = "selected_profile"
        const val DISABLE_MEMORY_LIMIT = "disable_memory_limit"
        const val STARTED_BY_USER = "started_by_user"
        const val PER_APP_PROXY_ENABLED = "per_app_proxy_enabled"
        const val PER_APP_PROXY_LIST = "per_app_proxy_list"
        const val PER_APP_PROXY_MODE = "per_app_proxy_mode"
        const val PER_APP_PROXY_DISABLED = 0
        const val PER_APP_PROXY_EXCLUDE = 1
        const val PER_APP_PROXY_INCLUDE = 2
        const val SYSTEM_PROXY_ENABLED = "system_proxy_enabled"

    }
}