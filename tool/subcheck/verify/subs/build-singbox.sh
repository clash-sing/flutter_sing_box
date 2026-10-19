#!/usr/bin/env bash
# 按 tag 编译 sing-box，供 tools/subcheck.py 做内核校验。产物在 .cache/sing-box/<tag>/sing-box，不进库。
# 用法：verify/subs/build-singbox.sh v1.14.1
# 编译标签取 libbox 共享标签里在 macOS 上不需要 cgo 的部分；naive、usbip、openvpn、openconnect 等
# 与订阅里的常见协议无关，没带（见 README 的「已知边界」）。
set -euo pipefail
tag="${1:?用法：build-singbox.sh <tag，如 v1.14.1>}"
root="$(cd "$(dirname "$0")/../.." && pwd)"
out="$root/.cache/sing-box/$tag"
bin="$out/sing-box"
go_bin="${GO:-$(command -v go || echo /opt/homebrew/bin/go)}"
if [[ -x "$bin" ]]; then
  echo "已存在：$bin"
  exit 0
fi
src="$root/.cache/sing-box/src-$tag"
if [[ ! -d "$src/.git" ]]; then
  rm -rf "$src"
  git clone --quiet --depth 1 --branch "$tag" https://github.com/SagerNet/sing-box.git "$src"
fi
mkdir -p "$out" "$root/.cache/go/mod" "$root/.cache/go/build"
(cd "$src" && GOMODCACHE="$root/.cache/go/mod" GOCACHE="$root/.cache/go/build" \
  "$go_bin" build -tags with_gvisor,with_quic,with_wireguard,with_utls,with_clash_api -o "$bin" ./cmd/sing-box)
"$go_bin" version -m "$bin" | grep -E "vcs.revision|-tags"
echo "已编译：$bin"
