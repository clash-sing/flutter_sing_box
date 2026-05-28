package com.clashsing.flutter_sing_box.utils

import io.nekohasekai.sfa.constant.ServiceMode
import com.tencent.mmkv.MMKV
import io.nekohasekai.sfa.bg.ProxyService
import io.nekohasekai.sfa.bg.VPNService
import org.json.JSONArray

object SettingsManager {
    const val MMKV_ID = "cs_settings"
    private val mmkv by lazy {
        MMKV.mmkvWithID(MMKV_ID, MMKV.MULTI_PROCESS_MODE)
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
            ServiceMode.VPN -> VPNService::class.java
            else -> ProxyService::class.java
        }
    }

    val disableMemoryLimit = mmkv.decodeBool(Keys.DISABLE_MEMORY_LIMIT, false)

    var startedByUser: Boolean
        get() = mmkv.decodeBool(Keys.STARTED_BY_USER, false)
        set(value) {
            mmkv.encode(Keys.STARTED_BY_USER, value)
        }

    /*
    var perAppProxyMode: Int
        get() = mmkv.decodeInt(Keys.PER_APP_PROXY_MODE,
            Keys.PER_APP_PROXY_EXCLUDE
        )
        set(value) {
            mmkv.encode(Keys.PER_APP_PROXY_MODE, value)
        }
*/

    var perAppProxyMode: Int
        get() = try {
            mmkv.decodeInt(Keys.PER_APP_PROXY_MODE, Keys.PER_APP_PROXY_DISABLED)
        } catch (_: Exception) {
            Keys.PER_APP_PROXY_DISABLED
        }
        set(value) {
            require(value in Keys.PER_APP_PROXY_DISABLED..Keys.PER_APP_PROXY_INCLUDE) {
                "perAppProxyEnabled 的值必须在 0 到 2 之间，当前值为：$value"
            }
            mmkv.encode(Keys.PER_APP_PROXY_MODE, value)
        }

    val perAppProxyExcludeList: List<String>
        get() {
            val jsonStr = mmkv.decodeString(Keys.PER_APP_PROXY_EXCLUDE_LIST, "[]")
            val jsonArray = JSONArray(jsonStr)
            val list = (0 until jsonArray.length()).map { jsonArray.getString(it) }
            return list
        }

    val perAppProxyIncludeList: List<String>
        get() {
            val jsonStr = mmkv.decodeString(Keys.PER_APP_PROXY_INCLUDE_LIST, "[]")
            val jsonArray = JSONArray(jsonStr)
            val list = (0 until jsonArray.length()).map { jsonArray.getString(it) }
            return list
        }

    var systemProxyEnabled: Boolean
        get() = mmkv.decodeBool(Keys.SYSTEM_PROXY_ENABLED, true)
        set(value) {
            mmkv.encode(Keys.SYSTEM_PROXY_ENABLED, value)
        }
    var autoRedirect: Boolean
        get() = mmkv.decodeBool(Keys.AUTO_REDIRECT, false)
        set(value) {
            mmkv.encode(Keys.AUTO_REDIRECT, value)
        }

    object Keys {
        const val DYNAMIC_NOTIFICATION = "dynamic_notification"
        const val SERVICE_MODE = "service_mode"
        const val SELECTED_PROFILE = "selected_profile"
        const val DISABLE_MEMORY_LIMIT = "disable_memory_limit"
        const val STARTED_BY_USER = "started_by_user"
//        const val PER_APP_PROXY_ENABLED = "per_app_proxy_enabled"
        const val PER_APP_PROXY_EXCLUDE_LIST = "per_app_proxy_exclude_list"
        const val PER_APP_PROXY_INCLUDE_LIST = "per_app_proxy_include_list"
        const val PER_APP_PROXY_MODE = "per_app_proxy_mode"
        const val PER_APP_PROXY_DISABLED = 0
        const val PER_APP_PROXY_INCLUDE = 1
        const val PER_APP_PROXY_EXCLUDE = 2
        const val SYSTEM_PROXY_ENABLED = "system_proxy_enabled"
        const val AUTO_REDIRECT = "auto_redirect"

    }
}