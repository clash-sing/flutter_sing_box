#!/usr/bin/env bash
# 发版前的订阅样本对比：CI 的 subcheck 任务调用，本机也能跑。
# 对比「上一个发布 tag」和「这次的提交」，有样本变坏就以非零退出，挡住发布。
# 内核用 sing-box 官方发布的二进制，版本取各自提交里 android/build.gradle.kts 的 libbox 版本。
#
# 用法：tool/subcheck/ci-compare.sh [新提交，默认 HEAD] [旧提交，默认新提交之前最近的 v* tag]
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(git -C "$here" rev-parse --show-toplevel)"
new="${1:-HEAD}"
old="${2:-$(git -C "$repo" describe --tags --abbrev=0 --match 'v*' "${new}^" 2>/dev/null || true)}"

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) platform=linux-amd64 ;;
  Linux-aarch64) platform=linux-arm64 ;;
  Darwin-arm64) platform=darwin-arm64 ;;
  Darwin-x86_64) platform=darwin-amd64 ;;
  *) echo "不支持的平台：$(uname -s)-$(uname -m)" >&2; exit 1 ;;
esac

# 下载某个提交对应版本的 sing-box 到 tools/subcheck.py 找内核的位置（.cache/sing-box/v<版本>/sing-box）
fetch_kernel() {
  local ref="$1" ver dest name
  ver="$(git -C "$repo" show "${ref}:android/build.gradle.kts" | grep -oE 'libbox:[0-9][0-9.]*' | head -n 1 | cut -d: -f2 || true)"
  if [[ -z "$ver" ]]; then
    echo "读不出 ${ref} 的 libbox 版本（android/build.gradle.kts）" >&2
    exit 1
  fi
  dest="$here/.cache/sing-box/v${ver}"
  [[ -x "$dest/sing-box" ]] && return 0
  name="sing-box-${ver}-${platform}"
  mkdir -p "$dest"
  curl -fsSL "https://github.com/SagerNet/sing-box/releases/download/v${ver}/${name}.tar.gz" \
    | tar -xz -C "$dest" --strip-components=1 "${name}/sing-box"
}

cd "$here"
fetch_kernel "$new"
if [[ -z "$old" ]]; then
  echo "没有更早的 v* tag，只跑一遍样本库，不做对比"
  python3 tools/subcheck.py run "$new" --repo "$repo"
  exit 0
fi
fetch_kernel "$old"

echo "订阅样本对比：${old} → ${new}"
status=0
python3 tools/subcheck.py compare "$old" "$new" --repo "$repo" --fail-on-worse > .cache/compare.md || status=$?
cat .cache/compare.md
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  cat .cache/compare.md >> "$GITHUB_STEP_SUMMARY"
fi
if [[ $status -eq 2 ]]; then
  echo "::error::有样本变坏（见上面的「变坏」一栏），先修再发版"
fi
exit "$status"
