package com.clashsing.flutter_sing_box.cs.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
  * @property level 日志级别 (0=Panic, 1=Fatal, 2=Error, 3=Warn, 4=Info, 5=Debug, 6=Trace)
 *
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
data class ClientLog(
    val level: Int,
    val message: String
)
