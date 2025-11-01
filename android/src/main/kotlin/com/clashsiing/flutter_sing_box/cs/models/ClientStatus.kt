package com.clashsiing.flutter_sing_box.cs.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
data class ClientStatus(
    val memory: Long,
    val goroutines: Int,
    val connectionsIn: Int,
    val connectionsOut: Int,
    val trafficAvailable: Boolean,
    val uplink: Long,
    val downlink: Long,
    val uplinkTotal: Long,
    val downlinkTotal: Long
)
