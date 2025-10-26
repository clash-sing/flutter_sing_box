package com.clashsiing.flutter_sing_box.cs.models

import android.annotation.SuppressLint
import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Parcelize
@Serializable
data class SelectedProxy(
    val profileId: Int,
    val group: String,
    val outbound: String,
) : Parcelable
