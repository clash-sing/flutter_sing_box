package com.clashsiing.flutter_sing_box.cs.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
data class ClientGroup(
    val tag: String,
    val type: String,
    val selectable: Boolean,
    val selected : String,
    val isExpand: Boolean,
    val item: GroupItem? = null,
) {
    @Serializable
    data class GroupItem(
        val tag: String,
        val type: String,
        val urlTestDelay: Int,
        val getURLTestTime: Long,
    )
}
