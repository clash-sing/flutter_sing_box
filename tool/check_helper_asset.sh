#!/usr/bin/env bash
# 插件发版前 asset 完整性检查（推 v* tag 前本地必跑）。
#
# 拦截三类历史踩坑：
#   1. asset 忘记随 helper 改动更新（grep 不到 restart 子命令特征串）
#   2. 误用本地 0.0.0 构建产物发版（version 数值不大于 1000000，
#      会破坏 example/upgrade 的数值升级链——0.0.0 会被判定为降级）
#   3. version 输出格式异常（非纯数字）
#
# 用法：在 flutter_sing_box 仓库根执行 ./tool/check_helper_asset.sh
set -euo pipefail

cd "$(dirname "$0")/.."

# 本机架构映射（version 子命令只能在对应架构的机器上执行）
case "$(uname -m)" in
  x86_64|amd64) native_arch=amd64 ;;
  aarch64|arm64) native_arch=arm64 ;;
  *) native_arch= ;;
esac

fail=0
for arch in amd64 arm64; do
  exe="assets/windows/$arch/clash_sing_helper.exe"
  if [[ ! -f "$exe" ]]; then
    echo "✗ [$arch] 缺少 $exe"
    fail=1
    continue
  fi

  # 检查 1：restart 子命令特征串（clash_sing_service 的 restart 日志文案）
  if ! grep -q "Helper restart" "$exe"; then
    echo "✗ [$arch] 二进制缺少 restart 子命令（旧版 helper 误打包？）"
    fail=1
  fi

  # 检查 2/3：version 输出为纯数字且大于 1000000（即非 0.0.0 本地构建）
  # ——仅本机架构可执行；交叉架构跳过（version 检查由对应架构 CI/人工兜底）
  if [[ "$arch" == "$native_arch" ]]; then
    ver="$("$exe" version)"
    if ! [[ "$ver" =~ ^[0-9]+$ ]]; then
      echo "✗ [$arch] version 输出非纯数字: $ver"
      fail=1
    elif (( ver <= 1000000 )); then
      echo "✗ [$arch] version=$ver（疑似 0.0.0 本地构建；发版须用 CI Release 的 tag 产物覆盖 asset）"
      fail=1
    else
      echo "✓ [$arch] version=$ver, restart 特征串存在"
    fi
  else
    echo "○ [$arch] 非本机架构：仅检查 restart 特征串（version 需在 $arch 机器上验证）"
  fi
done

if (( fail )); then
  echo "检查未通过：请修复后再推 tag。"
  exit 1
fi
echo "asset 检查全部通过。"
