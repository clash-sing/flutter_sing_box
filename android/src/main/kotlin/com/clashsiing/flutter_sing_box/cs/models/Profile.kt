package com.clashsiing.flutter_sing_box.cs.models

import android.annotation.SuppressLint
import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Parcelize
@Serializable
data class Profile(
    val id: Int,
    val order: Int,
    val name: String,
    val typed: TypedProfile,
    val userInfo: UserInfo? = null,
) : Parcelable {
    @Parcelize
    @Serializable
    data class TypedProfile(
        val type: ProfileType,
        val path: String,
        val lastUpdated: Long,
        val autoUpdate: Boolean,
        val autoUpdateInterval: Int? = null,
        val remoteUrl: String? = null,
        val webPageUrl: String? = null,
    ) : Parcelable {
        @Parcelize
        @Serializable
        enum class ProfileType : Parcelable {
            @SerialName("local")
            LOCAL,
            @SerialName("remote")
            REMOTE
        }
    }

    @Parcelize
    @Serializable
    data class UserInfo(
        val upload: Long? = null,
        val download: Long? = null,
        val total: Long? = null,
        val expire: Long? = null,
    ) : Parcelable
}
