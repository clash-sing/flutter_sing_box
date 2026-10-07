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
