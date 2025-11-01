package com.clashsiing.flutter_sing_box.cs.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
data class ClientClashMode(
    val modes: List<String>,
    val currentMode: String,
)
