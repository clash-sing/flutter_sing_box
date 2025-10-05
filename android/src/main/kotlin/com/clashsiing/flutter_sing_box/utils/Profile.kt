package com.clashsiing.flutter_sing_box.utils

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Profile(
    val id: Long = 0L,
    val userOrder: Long = 0L,
    val name: String = "",
    val typed: TypedProfile = TypedProfile()
) : Parcelable
