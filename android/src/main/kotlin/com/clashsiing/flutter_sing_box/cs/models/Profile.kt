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
    val userOrder: Int,
    val name: String,
    val typed: TypedProfile,
    val userInfo: UserInfo?,
) : Parcelable {
    @Parcelize
    @Serializable
    data class TypedProfile(
        val type: ProfileType,
        val path: String,
        val lastUpdated: Long,
        val autoUpdate: Boolean,
        val autoUpdateInterval: Int?,
        val remoteUrl: String?,
        val webPageUrl: String?,
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
        val upload: Long?,
        val download: Long?,
        val total: Long?,
        val expire: Long?,
    ) : Parcelable
}
