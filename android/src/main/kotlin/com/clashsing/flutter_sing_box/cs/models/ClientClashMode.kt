package com.clashsing.flutter_sing_box.cs.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
data class ClientClashMode(
    val modes: List<String>,
    var currentMode: String,
)
