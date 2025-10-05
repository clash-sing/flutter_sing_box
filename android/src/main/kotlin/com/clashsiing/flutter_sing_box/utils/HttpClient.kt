package com.clashsiing.flutter_sing_box.utils

import com.clashsiing.flutter_sing_box.ktx.unwrap
import io.nekohasekai.libbox.Libbox
import java.io.Closeable
import java.util.Locale

class HttpClient : Closeable {
    companion object {
        val userAgent by lazy {
            var userAgent = "SFA/"
            userAgent += PluginManager.versionName
            userAgent += " ("
            userAgent += PluginManager.versionCode
            userAgent += "; sing-box "
            userAgent += Libbox.version()
            userAgent += "; language "
            userAgent += Locale.getDefault().toLanguageTag().replace("-", "_")
            userAgent += ")"
            userAgent
        }
    }

    private val client = Libbox.newHTTPClient()

    init {
        client.modernTLS()
    }

    fun getString(url: String): String {
        val request = client.newRequest()
        request.setUserAgent(userAgent)
        request.setURL(url)
        val response = request.execute()
        return response.content.unwrap
    }

    override fun close() {
        client.close()
    }
}