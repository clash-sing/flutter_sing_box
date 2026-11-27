## 4.0.0

### ⚠️ Breaking change

**存储层精简：`ProfileStorage` 移除，由 `CoreStorage` 取代**

* `ProfileStorage` 已移除，由 `CoreStorage` 取代：后者只保留**路径契约**（存储根目录与 `profiles/profile_<id>.json` 派生路径，Dart 与原生两侧共用）与 **Dart↔原生交接通道**（`using_config` / `selected_profile_name` 两键）
* profile 元数据 CRUD（档案列表、选中项、用量元数据的读写）整体移除——订阅数据的事实源移入宿主 App，由其自行持久化，插件不再代管

**订阅导入拆分：`ProfileService.importProfile` 移除，由 `fetchAndParse` 取代**

* `ProfileService.importProfile` 已移除，由 `fetchAndParse` 取代：纯「下载 + 解析」，**不落盘不落库**，返回 `SubscriptionFetchResult` 快照，持久化由调用方负责

**模型删除**

* `Profile` / `TypedProfile` 模型删除（订阅用量模型 `UserInfo` 保留）

**Android 原生交接收缩**

* Android 原生 `ProfileManager` 改读 `selected_profile_name` 交接键，Kotlin 侧 `Profile` 模型删除
* example 示例 App 移除订阅管理演示页

### Fixes

**首次连接不再同步下载内置规则集（clash_sing_app#27）**

* 打包官方 `geoip-cn.srs` / `geosite-cn.srs`（`assets/rulesets/`，合计约 89 KB）。`init()` 时释放到存储根下的 `rule-sets/`；`SingBoxConfigProvider` 给模板里可识别的官方 remote 规则集写入 `initial_path`，无缓存首启优先读本地文件，成功下载后仍按 `update_interval` 后台更新
* 新增 `RuleSetAssets.applyInitialPaths()`，宿主 App 可在合并配置时调用，覆盖升级前生成、缺少 `initial_path` 的存量档案；不同文件名或非 SagerNet 官方来源的规则集不会被替换

**回退合并时处理 DNS 服务器标签重名（clash_sing_app#16）**

* `_fixSingBoxConfig` 把订阅的 DNS 服务器合并进模板时按 `tag` 去重，订阅同名项顶替模板项（与 sing-box 1.14.2 的“后加覆盖”行为一致）。此前直接追加：订阅复用模板的 `system` / `alidoh` / `udp-bytedance` / `remote` 任一标签时生成重复服务器标签，1.14.3 起内核以 `duplicate DNS server tag` 拒绝整份配置（宿主观感为连接时内核无法启动）

**Android：被取消的 DNS 查询不再卡住线程（clash_sing_app#44）**

* `LocalResolver` 对齐上游 SFA `124a7c1`：查询被内核取消时，除取消系统查询外同时恢复等待中的协程。此前只调 `signal.cancel()`，而 `DnsResolver` 取消后不保证回调，`runBlocking` 会永久占住线程。国内域名会并发走 `system` 与 `udp-bytedance` 竞速，输掉的 `system` 查询每次泄漏一个线程，VPN 进程的线程和内存只增不减，断开重连也不释放（真机常开 VPN 约 20 小时实测累积 93 个）
* 回调里的 `resume` 改为 `tryResume`：取消后系统查询的应答仍可能晚到，二次 resume 会抛 `Already resumed` 导致进程崩溃

**原生订阅的旧版写法先升级再解析（clash_sing_app#30）**

* 新增 `SingBoxLegacyUpgrader`：`SingBoxConfigProvider.provide` 解析原生 JSON 之前，按迁移项列表把旧版写法升级成当前内核认的写法，主路径与 `_fixSingBoxConfig` 回退路径都用升级后的配置。每个迁移项对应官方迁移文档的一节，兼容更多旧写法时往列表里加一项；认不出的写法原样保留，升级出错时按原配置继续
* 迁移项：DNS 服务器旧写法（`address`，1.14.0 已删除；`type` 为空字符串或 `legacy` 的也算）→ `type` + `server`，地址与类型的转换参照 sing-box 1.12–1.13 内部的升级逻辑，`rcode://` 服务器（协议头不分大小写，含没有 `tag` 的）去掉，指向它的规则改写成 `predefined` 动作并去掉 route 动作专用的字段。此前旧写法原样透传，Xboard 默认模板、wyx2685/v2board 旧模板这类订阅导入后被内核整份拒收（`legacy DNS server formats ... removed in sing-box 1.14.0`）
  * `detour` 按 1.13 的实际拨号改写：1.13 对旧写法服务器有拨号豁免，新写法没有。没写 `detour` 的服务器在 1.13 走默认出站（`route.final` 指定的出站或 endpoint，没有时是第一个出站），升级后写上该出站；指向空 `direct` 出站时去掉 `detour`（不写就是直连），否则 1.14 启动 DNS 服务器时报错。空 `direct` 按内核的判法：除 `type`、`tag` 外的字段都等于未设置，即 `null`、拨号字段的空列表、标量拨号字段（如 `bind_interface`、`domain_strategy`）的零值、解析为 0 的 `routing_mark`（数字 0 或 `"0x0"` 这类字符串）、等于 0 的时长（只认 `"0"` 或每段都是「零 + 单位」的常见写法，如 `connect_timeout: "0s"`、`"0h0m0s"`；带正负号、`d` 单位等罕见写法按已设置处理），以及 `domain_strategy: "as_is"`；判断的是生成模型读入再序列化后的出站，模型不保留的字段（如 `direct` 的 `domain_strategy`）不算
  * 去掉 `detour` 的服务器主机是域名、又没写 `address_resolver` 时补上 `domain_resolver`：1.14 对这种服务器报 `missing domain resolver for domain server address`，1.13 则由 `direct` 出站解析它的域名。取值按 1.13 的来源顺序：订阅原文的 `route.default_domain_resolver` → `outbound` 规则给这个 `direct` 或 `any` 的解析器 → `dns.servers` 里唯一的另一台服务器；都没有时不写
  * 没有 `tag` 的服务器按它在 `dns.servers` 里的下标补上 `tag`（与 1.14 的命名一致，重名时加后缀）。此前生成的模型要求 `tag` 是字符串，导入直接报错
  * 服务器级的 `strategy`、`client_subnet` 不迁移：新写法把它们放在 `dns` 全局或规则上，按服务器无法等价表达
* 迁移项：DNS 规则的 `outbound` 条件 → 出站的 `domain_resolver` 或 `route.default_domain_resolver`，规则本身去掉。此前生成的 `DNSRule` 没有 `outbound` 字段，`{"outbound": "any", "server": "local"}` 读进来只剩 `{"server": "local"}`，排在最前面，所有 DNS 查询都走这台服务器
  * 按旧规则的首条命中处理：`any` 规则之后的具体出站规则不再生效；规则带的 `strategy` / `disable_cache` / `rewrite_ttl` / `client_subnet` 随 `domain_resolver` 的对象形式保留
  * 还带别的匹配条件的规则、子规则里有 `outbound` 条件的逻辑规则，新写法无法等价表达，整条去掉，不写解析器；`outbound` 为空列表或 `null` 的规则只去掉这个键
  * `_fixSingBoxConfig` 回退路径用模板的 `route`，订阅迁移出的 `route.default_domain_resolver` 指向的服务器在合并后存在时，用它顶替模板的值；订阅没有 `route` 段时不写解析器，回退仍用模板的值
* `_fixSingBoxConfig` 回退合并订阅的 DNS 规则时，跳过引用了模板里没有的规则集的规则（含逻辑规则的子规则）。回退路径用模板的 `route`，订阅自己定义的规则集不会带过来，规则还引用它时内核以 `rule-set not found` 拒绝整份配置（wyx2685/v2board 旧模板的 `category-ads-all` 广告规则就是这样）
* `_fixSingBoxConfig` 回退删掉代理组之后，DNS 服务器的 `detour`（订阅原文写的或升级时补写的）指向已不存在的出站时，改为修正后的 `route.final`，`route.final` 是空 `direct` 时去掉 `detour`，与路由规则的处理一致；`detour` 指向的出站存在但是空 `direct`（例如订阅没有 `direct`、回退时补进来的那个）时同样去掉。此前内核启动时报 `outbound detour not found`

## 3.1.0

### Features

**Windows: helper updates take effect without a manual service restart**

* New `hasPendingHelperUpdate()` API — detects a pending helper update: the renamed-away `clash_sing_helper.exe.old` (produced when the running service locks the binary during an app update) exists **and** the service is running. Short-circuits on the file check alone, so no CLI subprocess is spawned when nothing is pending
* New `restartService()` API — elevates via UAC (`helper.exe restart`) and confirms completion with a two-phase state-transition poll: it must observe the service *leave* running (or the `.old` file disappear — fast restarts can slip entirely between the 500 ms samples, and the new service deletes `.old` before entering running) and then *return* to running. Transient `error`/`unknown` status reads do not count as a transition. Any failure (UAC declined, timeout, restart error) returns `false` so callers can fall back to the old service instead of blocking the user
* `init()` now best-effort deletes leftover `.old` copies of helper / sing-box / libcronet; locked files are ignored — the service-start path on the Go side is the reliable cleanup point
* Bundled `clash_sing_helper.exe` upgraded to **v0.2.0**: adds the `restart` subcommand (synchronous SCM stop→start), service-start cleanup of helper / sing-box / libcronet `.old` copies, an unknown-subcommand guard (only a bare invocation may run as the service body), and a stop-timeout wrapper working around an upstream kardianos/service hang

**Windows: startup proxy-state restoration**

* `init()` now restores the UI proxy state on startup when the service is already `running` from a previous session — the helper `/status` probe re-emits the correct `ProxyState`, so the UI no longer comes up as stopped while the proxy is actually active
* The probe is skipped for every other service state: probing a `stopped` service always hit a connection-refused exception (nobody listens on the helper port) while the initial `stopped` state was already correct; `notInstalled` / `unknown` / `error` are likewise skipped — restoration is best-effort and defers to real-operation feedback when the status read is untrustworthy
* A failed probe during restoration (SCM running but the port transiently unreachable) is logged and ignored instead of surfacing an unhandled exception in the startup chain
* Corrected the exception message thrown by `HelperHttpClient.status()` (`Error starting helper` → `Error querying helper status`)

**Subscription import: fallback naming for unnamed nodes**

* Base64 link-list subscriptions whose share links carry no `#name` fragment produced outbounds with an **empty tag**: sing-box 1.14.4 rejects duplicate empty tags at config initialization (`check` refuses to pass), and earlier kernels failed at startup anyway because groups referenced the empty tag. Unnamed nodes are now auto-named `节点 N`, skipping names already taken by explicit nodes in the same subscription (fixes the scenario tracked as `clash_sing_app#8`)

### Tooling

* `tool/check_helper_asset.sh` — pre-tag release gate for the bundled helper: asserts the restart marker string exists in both architecture binaries and that the native-architecture binary reports a version number above the `0.0.0` local-build sentinel

## 3.0.3

### CI

**Subscription sample regression gate (`tool/subcheck/`)**

* New fully synthetic subscription sample library (no real-provider data): Clash YAML / Base64 link-list / native sing-box JSON samples covering ss (incl. 2022 / obfs / v2ray-plugin), trojan, vmess, vless (incl. REALITY), hysteria1 / hysteria2, tuic and anytls across tcp / ws / grpc / h2 transports
* Each sample is imported through `SingBoxConfigProvider.provide()` — the same conversion path the app uses — and the generated configs are validated with `sing-box check` (matching core version) plus static checks for references to missing outbounds in groups, `route.final`, routing rules and DNS detours
* Findings are classified into seven categories (import errors, dropped nodes, renamed nodes, field mismatches, kernel rejections, start-up failures, provider routing/DNS replaced); per-sample expected results live in `verify/subs/samples.toml`
* Release gate: pushing a `v*` tag now runs the library against both the previous release tag and the new commit, and any regression blocks `publish` and `release`; the comparison report lands in the workflow run summary
* Runs locally too via `tool/subcheck/ci-compare.sh`, which fetches the official sing-box binaries matching each commit's libbox version (no Go toolchain required)

No runtime behavior changes — this release only adds CI verification and tooling.

## 3.0.2

### Features

**Windows: helper / sing-box crash detection**

* While the proxy is `started`, the Windows implementation now probes the helper's `/status` endpoint every 3 seconds (`WindowsConstants.helperWatchInterval`): a `stopped` reply emits `ProxyStopped(errMessage: "代理内核已停止运行。")`, and an unreachable helper (crashed system service) emits `ProxyStopped(errMessage: "Clash Service 服务意外停止运行。")` — previously a helper crash left the UI showing "connected" forever
* A generation counter cancels all in-flight probes on every proxy-state change (start / restart / stop / dispose), so user-initiated transitions are never misreported as crashes

**Windows: helper API port re-read on every request**

* The helper API listens on a random port that changes on every service restart (including the ~1s crash-recovery window) and is written back to `helper.json`; `HelperHttpClient` no longer caches the port across calls — the config is re-read before each request, and on connection refused / timeout the (possibly updated) port is re-read and the request retried once, fixing the state where every helper request failed with connection-refused until the app was restarted
* `HelperHttpClient.forTest(loadConfig)` allows tests to inject the config reader

### Fixes

* Windows `stop()` no longer throws on failure — errors are emitted as `ProxyStopped(errMessage: ...)` on `proxyStateStream`, aligned with `start()` / `restart()`
* Helper HTTP client connect/receive timeouts raised `5s → 15s`: the helper's `/start` includes a readiness probe and `/stop` a graceful-stop + force-kill confirmation (each up to ~10s server-side), so the previous client timeout could fire before the helper reported the real outcome
* `ProxyStopped.errMessage` from helper calls now prefers the helper's HTTP response body (carrying the core's exit reason / sing-box output) over a raw `DioException.toString()`

### Documentation

* Dartdoc coverage pass over the whole public API surface (facade, platform interface, constants, Clash models, storage, generated sing-box models) — comments are now written in Simplified Chinese
* New `tool/doc_coverage.dart`: counts documented public declarations with a pana-like scope (`*.g.dart` / `*.freezed.dart` excluded), `--verbose` lists the missing ones per file; `analyzer` added as an explicit dev dependency for the script

### Dependencies

* Bundled Windows `clash_sing_helper.exe` (both `amd64` / `arm64`) rebuilt from the current clash_sing_service source, bringing the matching server-side fixes:
  * sing-box child processes are assigned to a per-helper Job Object with `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE` — if the helper dies for any reason (crash, `taskkill /F`), the kernel terminates all sing-box children instead of leaving them orphaned in the background holding the TUN device and ports
  * On startup the helper force-kills leftover sing-box processes matching its own executable path (orphan cleanup covering crashes produced by older helpers or a failed job assignment)
  * Stop-path hardening across Windows / darwin / linux: a failed stop keeps the reported state "running" and surfaces the error; graceful stop with timeout + force-kill confirmation

## 3.0.1

### Fixes

* Clash h2 transport: the `h2-opts.path` field is now parsed as a scalar string (was a list) — mihomo's spec defines `Path` as a plain string and rejects the array form, so unlike `http-opts`' rotating multi-path list, h2 takes a single path; the Clash → sing-box conversion passes it through directly instead of picking the first non-empty entry

### Dependencies

* Upgrade sing-box core to `1.14.3` (Android `libbox` and the Windows `amd64` / `arm64` binaries updated in sync)
* The `example/` directory is no longer excluded by `.pubignore`, so the example source ships with the package again and pub.dev's Example tab renders it

## 3.0.0

### ⚠️ Breaking change

**Model layer regenerated from the official sing-box JSON Schema**

* The hand-written flat sing-box models (`outbound.dart` / `inbound.dart` / `dns.dart` / `route.dart` / `tls.dart` / `log.dart` / `experimental.dart` / `sing_box.dart` under `lib/src/data/models/singbox/`) have been **removed**. The public API now comes exclusively from the schema-generated model layer (`gen/`), re-exported through the package barrel — class names `Outbound` / `Inbound` / `SingBox` / `DNS` / `RouteOptions` / `Rule` etc. stay the same, so existing `import 'package:flutter_sing_box/flutter_sing_box.dart'` keeps working
* `Outbound` and `Inbound` are now **sealed class hierarchies** discriminated by `type` (`SelectorOutbound`, `VlessOutbound`, `Hysteria2Inbound`, …). Code that accessed flat fields on the base class (e.g. a group's `outbounds` list) must switch on the concrete subtype instead; `fromJson` picks the subtype by its `type` discriminator
* Unknown-type tolerance: unrecognized `outbound` / `inbound` types deserialize into `UnknownOutbound` / `UnknownInbound` which pass their raw JSON through untouched (round-trip safe); unmodeled **top-level sections** of `SingBox` (e.g. `ntp`) are likewise preserved on read and merged back on write
* Renames aligned with the schema: `Dns` → `DNS`, `Route` → `RouteOptions`, `Log` → `LogOptions`, `Experimental` → `ExperimentalOptions`; `Tls` / `Utls` / `Reality` / `Transport` / `Multiplex` are replaced by the granular generated options classes (`OutboundTLSOptions`, `OutboundUTLSOptions`, `V2RayTransport`, …)

**Transport-type constant renames**

* `OutboundTransportType`: `webSocket` → `ws`, `gRPC` → `grpc`, `httpUpgrade` → `httpupgrade` — the constant **values** are unchanged, only the Dart identifiers

### Features

**Clash subscription transport options**

* `ClashProxy` now parses `ws-opts` / `grpc-opts` / `http-opts` / `h2-opts`, and the Clash → sing-box conversion maps them to transport settings: ws path / headers / early data (`max-early-data` + `early-data-header-name`) / `v2ray-http-upgrade` (httpupgrade form), gRPC service name, HTTP method / path / headers (mihomo rotates the path list per connection — the first entry is used), and h2 host / path lists

**Clash snell proxies**

* `ClashProxy` now parses `psk` / `version` / `reuse` / `obfs-opts` (snell fields), and the Clash → sing-box conversion emits `SnellOutbound` — mapping `obfs-opts.mode` / `obfs-opts.host` to `obfs_mode` / `obfs_host`, `udp` to `network`, and passing `reuse` through
* Snell version 5 downgrades to version 4 (same as mihomo: v5 servers are backward-compatible with v4 clients, the downgrade happens before the reuse/UDP checks); a missing `version` (mihomo defaults to the legacy v1 protocol) and versions 1-3 have no schema counterpart and are skipped (same policy as socks5-over-TLS); `version` accepts both int and string YAML spellings; the Clash `ports` hop syntax has no sing-box equivalent (`server_ports` is not in the snell schema branch) and is ignored

**Clash socks5 & http proxies**

* `ClashProxy` → `Outbound` conversion now covers `socks5` (`username` / `password` pass-through, `udp` → `network`) and `http` (plain HTTP proxy, or an HTTPS proxy via `tls: true` with `sni` / `skip-cert-verify` / `alpn`)
* A socks5 node with `tls: true` is skipped: the sing-box socks outbound has no TLS capability, so such a node could never connect (same policy as unmapped protocol versions)

**Default subscription User-Agent**

* `SubscribeUserAgent` — the default User-Agent builder for subscription requests — is now exported as part of the package's public API
* The built string is simplified to the core identifiers `sing-box/<version> mihomo/1.19.32 v2ray/5.22.0`; the previously spoofed third-party client identifiers (clash-verge / ClashMetaForAndroid / ClashForWindows) are dropped

**Model layer fidelity & subscription parsing**

* Open-map types from the schema (e.g. `HTTPHeader`) are modeled as key-passthrough classes — every entry survives `fromJson` / `toJson` round-trips, so WebSocket `Host` headers on vless / vmess CDN nodes are preserved
* Outbound acceptance when parsing subscriptions now derives from the generated model registry instead of a hand-maintained 11-type allow-list: every modeled type passes (block stays excluded — deprecated by sing-box), unmodeled types are still silently dropped
* `OutboundType` gains `socks` / `http` / `shadowTLS` / `snell` / `block` constants

### Dependencies

* Remove the unused `equatable` dependency
* The upstream core LICENSE files bundled under `assets/windows/` are dropped from the package (the package's own top-level LICENSE stays)

## 2.1.1

### Features

**Base64 subscription (share-link) parsing**

* New share-link protocols: `ss://` (including the SIP003 `plugin` parameter), `vless://` and `vmess://` (base64-JSON body) — joining the existing hysteria / hysteria2 / anytls / trojan links
* Link parameters now honored: `sni` / `peer` (`peer` is hysteria v1's official name, `sni` accepted as an alias), `servername`, and comma-separated `alpn`; the hysteria / hysteria2 `mport` multi-port syntax maps to sing-box `server_ports`

**Clash config conversion**

* `ClashProxy` → `Outbound` conversion now covers vmess, vless (incl. Reality / `flow`), Shadowsocks (with plugin options), hysteria2 and Realm (`realm` / `realm_opts` port mappings)
* New fields on `ClashProxy` / `Outbound`: `flow`, `obfs`, idle-session options, `servername`; transport handling extended to `ws` / `grpc` / `httpupgrade` / `http` and raw TCP

**Clash DNS conversion**

* Clash `dns.nameserver-policy` is now converted into sing-box DNS servers plus matching `evaluate` → `respond` → `route` rule chains; outbounds whose server matches a policy domain get `domain_resolver` assigned accordingly
* DNS rules carried by the subscription are inserted at the **front** of the generated rule list (was appended), so they take priority over the template defaults

**JSON Schema validation**

* The plugin now bundles the sing-box JSON Schema (draft 2020-12) and validates every generated config on subscription import — all three source formats (JSON / YAML / Base64) converge at this checkpoint
* Validation is diagnostic-only by design: failures are logged with path-annotated error details but never block the import, since the schema's strict `additionalProperties` would otherwise reject newer-core or provider-specific fields that the core itself tolerates

### Dependencies

* Upgrade sing-box core to `1.14.2` (Windows `amd64` / `arm64` binaries updated in sync, upstream LICENSE files added alongside)

## 2.1.0

### Features

* Windows arm64 support: the bundled binaries are now dual-architecture — `assets/windows/` is restructured into `amd64/` and `arm64/` subdirectories, each containing `sing-box.exe` / `libcronet.dll` / `clash_sing_helper.exe` (core version stays `1.14.1`; both architectures are taken from the official sing-box release zips)
* `init()` now detects the machine's **native** architecture (via `GetNativeSystemInfo`) and extracts only the matching set: on arm64 devices (e.g. Snapdragon laptops) the app UI keeps running under Windows' built-in x64 emulation while the core and the helper service run natively as arm64 — no app-side or CI changes required; on amd64 machines behavior is unchanged (extracted file names stay the same, upgrades go through the existing sha256 + rename-fallback path)

## 2.0.5

* Relax the mmkv version constraint to `>=1.3.17 <3.0.0`: apps can now downgrade mmkv to 1.3.x for 32-bit Android (armeabi-v7a).
* The Android native dependency now reads the actually-resolved mmkv version from `pubspec.lock` and automatically pairs the same-version `com.tencent:mmkv` AAR, eliminating the version-mismatch risk of manual syncing.

## 2.0.4

### ⚠️ Breaking change

* `ProfileService.isLocaleFile` renamed to `isLocalFile` (typo fix); it now recognizes only canonical `file:` URIs — raw Windows paths must be normalized via `parseSubscribeLink` first

### Features

* Add `ProfileService.parseSubscribeLink(String)`: normalizes Windows drive-letter paths (`C:\...` / `C:/...`) and UNC paths (`\\server\share\...`) into canonical `file:` URIs, with special characters (`#` / spaces / non-ASCII) percent-encoded instead of being truncated as a fragment separator; all other inputs are parsed as regular URIs
* `FlutterSingBoxConstants.localFilePrefix` is now the constant `'file://'` on all platforms (was an empty string on Windows, which made every string match the prefix)

### Fixes

* Windows: local-file subscriptions were never recognized — a drive-letter path parses with a single-letter scheme (`c:`), so it was misclassified as a remote URL and the import always failed; importing local files now works on Windows

## 2.0.3

### Fixes and improvements

* Bug fixes

## 2.0.2

### Dependencies

* Upgrade sing-box core to `1.14.1`

### Fixes and improvements

* Minor bug fixes and performance improvements

## 2.0.1

### Documentation

* Update the showcase project name (`clash_sing` → `clash-sing`) in README / README_CN to match the renamed repository

## 2.0.0

### ⚠️ Breaking change

* `ProxyState` is now a `sealed class` (was an enum); each state is its own `final class`: `ProxyStopped` / `ProxyStarting` / `ProxyStarted` / `ProxyStopping`
  * `ProxyStopped` carries a nullable `errMessage` (non-null = abnormal stop, e.g. start failure or core crash) with value-based `==` / `hashCode`; the other three states are const singletons
  * Existing `== ProxyState.started`-style comparisons keep working via preserved `static const` compatibility constants (`ProxyState.stopped` / `.starting` / `.started` / `.stopping`); exhaustive switches over the old enum must migrate to type patterns (`case ProxyStopped():`)
  * The `name` getter and `fromName()` keep their original semantics
* Windows: `start()` / `restart()` no longer throw on failure; the failure reason is emitted as `ProxyStopped(errMessage: ...)` on `proxyStateStream` (also resetting the state machine from `starting`), making the state stream the single source of truth for startup failures — aligned with the Android native alert path; callers awaiting these futures can no longer catch failures from the returned future

### Features

* Android `proxyStateStream`: abnormal-stop events from the native side (`EventSink.error(code: "Stopped", message)`) now surface their error message as `ProxyStopped.errMessage` instead of being swallowed

## 1.3.0

### Dependencies

* Upgrade sing-box core to `1.14.0`: Android (`libbox`, jitpack) `1.13.21` → `1.14.0`; Windows `sing-box.exe` / `libcronet.dll` binaries upgraded in sync

### Compatibility (adapting to libbox 1.14.0 breaking API changes, aligned with upstream sing-box-for-android 1.14.0)

* `PlatformInterface`: remove the deleted `systemCertificates()`; add default implementations for 13 new interface methods (shell / bridge / neighbor-table monitoring, etc., treated as "unsupported"); `getInterfaces()` now includes `gateway` info
* `TunOptions`: `dnsServerAddress` changed from a single value to an iterator; `openTun` migrated to `dnsMode` + multiple DNS server writes
* `CommandServerHandler`: implement `triggerNativeCrash()` / `connectSSHAgent()`
* `CommandClientHandler`: implement `writeOutbounds()` (this plugin does not subscribe to that command; empty implementation)
* Notification API: `identifier` semantics changed to a notification tag; the `sendNotification` channel is now derived from `typeID`; add `cancelNotification`
* Remove the `Libbox.redirectStderr()` call deleted by libbox (`Setup()` now redirects stderr to `CrashReport-<source>.log` automatically)

### Features

* Configuration model extensions, adding sing-box 1.14.0 fields:
  * `DnsRule`: add `race` / `rcode` / `tag` fields; `action` made nullable with the `RuleAction.route` default removed; `rules` narrowed to `List<DnsRule>`; `matchResponse` relaxed to `dynamic`
  * `RouteRule`: `action` made nullable with the `RuleAction.route` default removed
  * `RuleSet`: add local `rules` (inline rule-set); remove the deprecated `downloadDetour`
  * `Outbound`: add `hopInterval` / `hopIntervalMax` / `bbrProfile` / `disableChromeParrot` / `realm` (Hysteria2-related) fields
  * `Route` / `SingBox`: add `defaultHttpClient` / `httpClients` fields
  * `ClientGroupItem`: `tag` / `type` changed to mutable fields

### ⚠️ Runtime behavior notes

* sing-box 1.14.0 hard-removes the legacy DNS server format (legacy `dns.servers`) deprecated since 1.12: old-format configs fail immediately at startup; user configs must use the new DNS format (the new format generated by the Clash/Base64 config converters in this plugin is unaffected)

## 1.2.0

### 🎉 Milestone: official Windows platform support

Promoted from the "in development" state of 1.1.5 to officially usable: the desktop hosts the sing-box process as a system service, with system proxy settings and real-time Clash API logs.

### ⚠️ Breaking Changes

* Minimum environment requirements raised: Dart SDK `^3.11.0` → `^3.12.0`, Flutter `>=3.41.0` → `>=3.44.0`

### Features

* **Official Windows platform support**:
  * Add `SystemProxyService`: set/clear the Windows system proxy via FFI
  * Add the `ProxyMode` enum and the `defaultMixedPort` constant; `CsSettingsStorage` adds `proxyMode` / `mixedPort` / `systemProxyActive` settings
  * `emitProxyState` linked with system proxy on/off; `init` adds crash self-recovery logic
  * Add Clash API real-time log subscription (`logStream`): WebSocket-based connection to the `/logs` endpoint with automatic reconnection and a custom API port
* **Resource extraction enhancements**: compare the SHA256 of resources and target files in memory to avoid temp-file writes and cleanup; for running exes exclusively locked on Windows (errno 32), fall back to renaming the old file to `.old` before writing the new one
* Network layer `DioClient` adds an `allowBadCertificates` switch to control certificate validation at runtime, fixing request failures on the Windows desktop caused by incomplete certificate chains of subscription sites

### Fixes

* Fix the Windows Clash log level mapping error (`warning` → `warn`)
* Fix missing `await` on asynchronous calls in Windows service operations (status check, install, uninstall, start, stop) and resource copy methods

### Improvements

* Migrate the Android build script from Groovy (`build.gradle`) to Kotlin DSL (`build.gradle.kts`), requiring AGP 9.0.1 / Kotlin 2.3.20 / Java 17
* Remove unnecessary Android permissions
* Simplify the Windows platform asset configuration in pubspec.yaml
* Example: upgrade the Android build toolchain (Gradle / AGP / Kotlin / SDK); migrate the UI layer from `flutter/material` to material_ui

### Dependencies

* Upgrade the sing-box core (Android `libbox` / Windows `sing-box.exe`): `1.13.15` → `1.13.21`
* Upgrade MMKV: `2.4.1` → `2.4.2` (2.4.1 has an MSVC cbridge crash on Windows)
* Upgrade `dio`: → `^5.11.1`
* Remove the `path_provider` dependency

## 1.1.5

### Features

* **Add Windows platform support** (in development; the desktop hosts the sing-box process as a system service, compensating for the lack of a VPN Service on desktop platforms):
  * Add service management APIs: `installService` / `uninstallService` / `queryServiceStatus`, installed via PowerShell runas elevation with status polling to determine the result
  * Implement Windows VPN control and proxy state listening (`proxyStateStream`)
  * Add `HelperCli`, wrapping all CLI subcommands of `clash_sing_helper.exe` (status / stop / install / uninstall / start)
* **Windows Clash API support**:
  * Add Clash configuration models and an HTTP client
  * Implement Clash mode reading and switching (`clashModeStream`, `setClashMode`)
  * Implement proxy group fetching, outbound switching and URL latency testing
* The storage layer adds Clash API port and test URL settings

### Improvements

* Upgrade Android `libbox` (sing-box core): `1.13.14` → `1.13.15`
* Upgrade Windows `sing-box.exe` to `1.13.15`
* The Clash API port adapts to changes dynamically
* Remove the unused location permission on Android

### Fixes

* Fix the Windows Clash HTTP client proxy type mapping error
* Fix Windows Clash proxy group parsing and type conversion logic

### Refactoring

* Refactor the service install API: parameters collapsed into a `HelperConfig` object; hardcoded paths extracted into constants
* Promote service management capabilities (uninstall / start / stop) to the platform abstraction layer and facade
* Optimize proxy state stream controller initialization and state dispatch logic
* `FlutterSingBoxWindows` delegates to `HelperCli`, removing the migrated helper methods

### Dependencies

* Upgrade `dio`: → `^5.10.0`

## 1.1.4

### Dependencies

* Upgrade Android `libbox` (sing-box core): `1.13.12` → `1.13.14`

## 1.1.3

### Features

* Add naive protocol outbound type support
* Add a standalone TLS configuration model (`tls.dart`)
* Add a `domainResolver` field to the Outbound model
* Add `domain_resolver` and `tls` fields to the DNS Server model

### Fixes

* Fix the DNS Server model `path` field type: `List<String>` → `String`

### Improvements

* Remove the `sniff_override_destination` option from the sing-box template config

## 1.1.2

### Documentation

* Fully document public APIs with English dartdoc comments, covering constants, providers, services, network, storage, etc., improving the pub.dev documentation coverage score

### Dependencies

* Upgrade `device_info_plus`: `^12.2.0` → `^13.1.0`
* Upgrade `package_info_plus`: `^9.0.0` → `^10.1.0`

## 1.1.0

### ⚠️ Breaking Changes

* Minimum environment requirements raised: Dart SDK `^3.9.0` → `^3.11.0`, Flutter `>=3.3.0` → `>=3.41.0`
* Fix the Android plugin package name typo: `com.clashsiing.flutter_sing_box` → `com.clashsing.flutter_sing_box` (update native references or consumer-rules configurations accordingly, if any)
* Introduce the freezed code generation framework, adding `freezed` and `freezed_annotation` dependencies

### Features

* Add Rule Set configuration support and optimize the sing-box config template structure
* Support a custom User-Agent for subscription requests, with a built-in default User-Agent generator
* Greatly extend the sing-box configuration model fields: Outbound adds `username`, `quic`, etc.; DNS / Route models gain many additional fields
* Add a standalone storage module with the `KeyValueStorage` abstract interface (MMKV / Memory implementations)
* Add `CsSettingsStorage` for per-app proxy settings
* Add the `ClientLog` data model
* Profile adds the `outboundsCount` field and supports fetching all Profile IDs
* Add the `defaultTestUrl` constant

### Improvements

* Cache the sing-box version string to avoid repeated fetches (performance optimization)
* Add `explicitToJson` to models, fixing JSON serialization of nested models
* Refactor the VPN service startup logic, caching event stream state
* Upgrade JSON serialization dependencies: `json_annotation` → 4.12.0, `json_serializable` → 6.14.0
* Remove the `android:process=":remote"` attribute from VpnService

### Fixes

* Fix VPN service restart
* Fix Clash mode setting and connection management issues
* Fix the Android service shutdown logic
* Add a null guard for `logSink` in `appendLogs` to avoid a null pointer exception

### Refactoring

* Refactor the storage layer: `ProfileManager` renamed to `ProfileStorage`, replacing direct MMKV calls with the `KeyValueStorage` abstract interface
* Migrate `ClientGroupItem` / `ClientGroup` to freezed data classes
* Make some Route and RuleSet fields optional for flexibility
* Refactor the Android service implementation and update dependencies
* Clean up the deprecated custom module and debug code

## 1.0.12

### Features

* Add app-level proxy mode (disable / exclude / include)
* Support per-app proxy rules via the app list

### Improvements

* Update the MMKV dependency to 2.4.0
* Optimize app list storage (JSON array format)
* Update the Android build environment (Kotlin 2.3.20, Gradle 8.14.4)

### Refactoring

* Remove the `sniff` field from the Inbound model
* Refactor the app list data structure (List/Set conversion optimization)

## 1.0.11

* Update `sing-box` dependency to `1.12.25` for Android.

## 1.0.10

- **Route Rule**: Added IP CIDR and port filtering support
  - New fields: `ip_cidr`, `source_ip_cidr`, `port`, `port_range`, `source_port`, `source_port_range`
  - Enhanced traffic matching with IP and port-based routing
  - Full JSON serialization support with backward compatibility

## 1.0.9

### Features

* Add DNS rule action configuration and new domain matching fields
* Add `RuleAction` constants for routing rules

### Improvements

* Optimize proxy configuration template and simplify DNS/route rules
* Adjust default log level from `trace` to `info`
* Update User-Agent string for better compatibility

### Refactoring

* Remove remote rule set configuration (geoip-cn, geosite-cn)
* Simplify configuration structure and improve performance
* Make Route fields optional for flexibility

## 1.0.8

* Update `sing-box` dependency to `1.12.24` for Android.

## 1.0.7

* Update `sing-box` dependency to `1.12.23` for Android.

## 1.0.6

* Update `sing-box` dependency to `1.12.22` for Android.

## 1.0.5

* Update `sing-box` dependency to `1.12.20` for Android.

## 1.0.4

* Update `libbox` dependency to `1.12.19` for Android.
* Update documentation and project links in README.
* Bump version to 1.0.4.

## 1.0.3

* Add `getSingBoxVersion()` API to retrieve the underlying sing-box core version.
* Optimize memory usage and stability for long-running VPN services.
* Improve error handling during remote profile synchronization.
* Update dependencies to latest versions (dio, mmkv, package_info_plus, etc.).
* Minor bug fixes and performance improvements.

## 1.0.2

* Improve package description and API documentation coverage to increase pub score.
* Add comprehensive README with features, platform support, and basic usage.
* Add Chinese documentation (`README_CN.md`).
* Showcase projects using this plugin (clash_sing_app).

## 1.0.0

* Initial release of the `flutter_sing_box` plugin.
* Support for sing-box as a VPN service.
* Ability to import remote profiles.
* Clash API support for managing proxies and groups.
* UI for managing profiles and viewing connection status.
* Support for various protocols like Hysteria, TUIC, etc.
* Core functionalities like network service, profile management, and custom logging.
* Many bug fixes and performance improvements.
