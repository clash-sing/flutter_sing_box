package com.clashsiing.flutter_sing_box.utils

import android.content.Context
import android.os.Parcelable
import com.clashsiing.flutter_sing_box.R
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class TypedProfile(
    val path: String = "",
    val type: Type = Type.Local,
    val remoteURL: String = "",
    val lastUpdated: Date = Date(0),
    val autoUpdate: Boolean = false,
    val autoUpdateInterval: Int = 60
) : Parcelable {
    enum class Type {
        Local, Remote;

        fun getString(context: Context): String {
            return when (this) {
                Local -> context.getString(R.string.profile_type_local)
                Remote -> context.getString(R.string.profile_type_remote)
            }
        }

        companion object {
            fun valueOf(value: Int): Type {
                for (it in values()) {
                    if (it.ordinal == value) {
                        return it
                    }
                }
                return Local
            }
        }
    }
}