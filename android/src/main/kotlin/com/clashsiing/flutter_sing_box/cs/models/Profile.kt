package com.clashsiing.flutter_sing_box.cs.models

import android.annotation.SuppressLint
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
data class Profile(
    val id: Int,
    val order: Int,
    val name: String,
    val typed: TypedProfile,
    val userInfo: UserInfo? = null,
) {
    @Serializable
    data class TypedProfile(
        val type: ProfileType,
        val path: String,
        val lastUpdated: Long,
        val autoUpdateInterval: Int? = null,
        val subscribeUrl: String? = null,
        val webPageUrl: String? = null,
    ) {
        @Serializable
        enum class ProfileType {
            @SerialName("local")
            LOCAL,
            @SerialName("remote")
            REMOTE
        }
    }

    @Serializable
    data class UserInfo(
        val upload: Long? = null,
        val download: Long? = null,
        val total: Long? = null,
        val expire: Long? = null,
    )
}
