package io.nekohasekai.sfa.bg

import android.net.DnsResolver
import android.os.Build
import android.os.CancellationSignal
import android.system.ErrnoException
import androidx.annotation.RequiresApi
import io.nekohasekai.libbox.ExchangeContext
import io.nekohasekai.libbox.LocalDNSTransport
import io.nekohasekai.sfa.ktx.tryResume
import io.nekohasekai.sfa.ktx.tryResumeWithException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.asExecutor
import kotlinx.coroutines.runBlocking
import java.net.InetAddress
import java.net.UnknownHostException
import java.util.concurrent.CancellationException
import kotlin.coroutines.suspendCoroutine

object LocalResolver : LocalDNSTransport {
    private const val RCODE_NXDOMAIN = 3

    override fun raw(): Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q

    @RequiresApi(Build.VERSION_CODES.Q)
    override fun exchange(ctx: ExchangeContext, message: ByteArray) {
        val defaultNetwork = DefaultNetworkMonitor.defaultNetwork ?: error("missing default interface")
        return runBlocking {
            suspendCoroutine { continuation ->
                val signal = CancellationSignal()
                // 对齐上游 SFA 124a7c1 "Fix LocalResolver hanging on canceled queries"：
                // CancellationSignal 取消后 DnsResolver 不保证回调 onAnswer/onError，这里必须同时恢复
                // continuation，否则 runBlocking 会永久占住当前线程（VPN 进程线程只增不减）。
                // 回调改用 tryResume：取消后系统查询的回调仍可能晚到，二次 resume 会抛 Already resumed。
                ctx.onCancel {
                    signal.cancel()
                    continuation.tryResumeWithException(CancellationException())
                }
                val callback =
                    object : DnsResolver.Callback<ByteArray> {
                        override fun onAnswer(answer: ByteArray, rcode: Int) {
                            if (rcode == 0) {
                                ctx.rawSuccess(answer)
                            } else {
                                ctx.errorCode(rcode)
                            }
                            continuation.tryResume(Unit)
                        }

                        override fun onError(error: DnsResolver.DnsException) {
                            when (val cause = error.cause) {
                                is ErrnoException -> {
                                    ctx.errnoCode(cause.errno)
                                    continuation.tryResume(Unit)
                                    return
                                }
                            }
                            continuation.tryResumeWithException(error)
                        }
                    }
                DnsResolver.getInstance().rawQuery(
                    defaultNetwork,
                    message,
                    DnsResolver.FLAG_NO_RETRY,
                    Dispatchers.IO.asExecutor(),
                    signal,
                    callback,
                )
            }
        }
    }

    override fun lookup(ctx: ExchangeContext, network: String, domain: String) {
        val defaultNetwork = DefaultNetworkMonitor.defaultNetwork ?: error("missing default interface")
        return runBlocking {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                suspendCoroutine { continuation ->
                    val signal = CancellationSignal()
                    // 同 exchange：取消时必须恢复 continuation，回调用 tryResume 防止二次 resume
                    ctx.onCancel {
                        signal.cancel()
                        continuation.tryResumeWithException(CancellationException())
                    }
                    val callback =
                        object : DnsResolver.Callback<Collection<InetAddress>> {
                            @Suppress("ThrowableNotThrown")
                            override fun onAnswer(answer: Collection<InetAddress>, rcode: Int) {
                                if (rcode == 0) {
                                    ctx.success(
                                        (answer as Collection<InetAddress?>).mapNotNull { it?.hostAddress }
                                            .joinToString("\n"),
                                    )
                                } else {
                                    ctx.errorCode(rcode)
                                }
                                continuation.tryResume(Unit)
                            }

                            override fun onError(error: DnsResolver.DnsException) {
                                when (val cause = error.cause) {
                                    is ErrnoException -> {
                                        ctx.errnoCode(cause.errno)
                                        continuation.tryResume(Unit)
                                        return
                                    }
                                }
                                continuation.tryResumeWithException(error)
                            }
                        }
                    val type =
                        when {
                            network.endsWith("4") -> DnsResolver.TYPE_A
                            network.endsWith("6") -> DnsResolver.TYPE_AAAA
                            else -> null
                        }
                    if (type != null) {
                        DnsResolver.getInstance().query(
                            defaultNetwork,
                            domain,
                            type,
                            DnsResolver.FLAG_NO_RETRY,
                            Dispatchers.IO.asExecutor(),
                            signal,
                            callback,
                        )
                    } else {
                        DnsResolver.getInstance().query(
                            defaultNetwork,
                            domain,
                            DnsResolver.FLAG_NO_RETRY,
                            Dispatchers.IO.asExecutor(),
                            signal,
                            callback,
                        )
                    }
                }
            } else {
                val answer =
                    try {
                        defaultNetwork.getAllByName(domain)
                    } catch (e: UnknownHostException) {
                        ctx.errorCode(RCODE_NXDOMAIN)
                        return@runBlocking
                    }
                ctx.success(answer.mapNotNull { it.hostAddress }.joinToString("\n"))
            }
        }
    }
}
