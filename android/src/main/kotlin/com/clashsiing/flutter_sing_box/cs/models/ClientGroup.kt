package com.clashsiing.flutter_sing_box.cs.models

import android.annotation.SuppressLint
import io.nekohasekai.libbox.OutboundGroup
import io.nekohasekai.libbox.OutboundGroupItem
import io.nekohasekai.libbox.OutboundGroupItemIterator
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
data class ClientGroup(
    val tag: String,
    val type: String,
    val selectable: Boolean,
    val selected : String,
    val isExpand: Boolean,
    val items: List<GroupItem>,
) {
    constructor(item: OutboundGroup) : this(
        item.tag,
        item.type,
        item.selectable,
        item.selected,
        item.isExpand,
        item.items.toList().map { GroupItem(it) },
    )

    @Serializable
    data class GroupItem(
        val tag: String,
        val type: String,
        val urlTestTime: Long,
        val urlTestDelay: Int,
    ) {
        constructor(item: OutboundGroupItem) : this(
            item.tag,
            item.type,
            item.urlTestTime,
            item.urlTestDelay,
        )
    }
}

internal fun OutboundGroupItemIterator.toList(): List<OutboundGroupItem> {
    val list = mutableListOf<OutboundGroupItem>()
    while (hasNext()) {
        list.add(next())
    }
    return list
}