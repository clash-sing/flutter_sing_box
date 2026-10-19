"""订阅样本库运行器：对 flutter_sing_box 的指定提交跑 verify/subs/ 的样本，
判定节点是否被丢、字段是否写对、内核是否接受、原生订阅的分流与 DNS 是否保留。

用法：
  python3 tools/subcheck.py run <sha|分支|tag> [--only a,b] [--local] [--flutter 路径] [--kernel 路径] [--repo 路径]
  python3 tools/subcheck.py compare <旧> <新> [--repo 路径] [--fail-on-worse]

--repo 指向本机的 flutter_sing_box 仓库；不写时读 .cache/repos/ 下的镜像。
--fail-on-worse：有样本变坏时返回 2（给 CI 挡发版用）；有增有减不算。
本文件不依赖同目录的其它模块，可以单独交给开发者。
  python3 tools/subcheck.py check-manifest
"""
import argparse
import base64
import binascii
import datetime as dt
import hashlib
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import tomllib
import urllib.parse
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FORMATS = ("clash", "base64", "singbox")
NON_NODE_TYPES = {"selector", "urltest", "direct", "block", "dns"}
ABSENT = "<无>"
KIND_LABEL = {
    "import_error": "导入报错",
    "nodes_missing": "丢了节点",
    "nodes_renamed": "名字被改",
    "field_mismatch": "字段不符",
    "kernel_rejected": "内核拒收",
    "start_error": "启动会失败",
    "provider_replaced": "分流 / DNS 被换",
}
# 严重度：整份用不了 > 丢节点 > 细节不对。compare 先比严重度，同级再比具体条目。
LEVEL = {"import_error": 3, "kernel_rejected": 3, "start_error": 3, "nodes_missing": 2,
         "nodes_renamed": 1, "field_mismatch": 1, "provider_replaced": 1}
CODEGEN_DEPS = ("build_runner", "json_serializable", "freezed")
DEFAULT_FLUTTER = Path.home() / "dev" / "flutter" / "bin" / "flutter"
CHECK_TIMEOUT = 20
# 判定逻辑改了就加一：旧结果文件里的版本号对不上时，compare 会重跑而不是拿旧结果比
JUDGE_VERSION = 7
VMESS_JSON = "vmess-json "
CUSTOM_KERNEL = "（--kernel 指定）"  # 结果文件里 kernel 字段的取值：不是按插件版本取的内核


class SubcheckError(Exception):
    pass


def _pubspec_version(text):
    m = re.search(r"^version:[ \t]*(\S+)", text, re.M)
    return m[1] if m else None


def _libbox_version(text):
    m = re.search(r"libbox:([\d.]+)", text)
    return m[1] if m else None


def _atomic_write(path, text):
    """写临时文件再 os.replace，中途失败不会留下半截的结果文件。"""
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    os.replace(tmp, path)


def subs_dir(root=ROOT):
    return Path(root) / "verify" / "subs"


# ---------- 样本清单 ----------

def validate_manifest(samples, base_dir):
    """返回问题列表，空列表表示合格。base_dir 是 samples.toml 所在目录。"""
    problems = []
    seen = set()
    for i, s in enumerate(samples):
        sid = s.get("id") or f"第 {i + 1} 条"

        def bad(msg):
            problems.append(f"{sid}：{msg}")

        for key in ("id", "file", "format", "subject", "source"):
            if not isinstance(s.get(key), str) or not s[key].strip():
                bad(f"缺少 {key}")
        if s.get("id") in seen:
            bad("id 重复")
        seen.add(s.get("id"))
        fmt = s.get("format")
        if fmt not in FORMATS:
            bad(f"format 只能是 {' / '.join(FORMATS)}")
        f = s.get("file")
        if isinstance(f, str) and f.strip() and not (Path(base_dir) / f).is_file():
            bad(f"文件不存在：{f}")
        has_nodes, has_count = "expect_nodes" in s, "expect_node_count" in s
        if has_nodes == has_count:
            bad("expect_nodes 与 expect_node_count 必须恰好写一个")
        nodes = s.get("expect_nodes", [])
        if not (isinstance(nodes, list) and all(isinstance(n, str) for n in nodes)):
            bad("expect_nodes 必须是字符串列表")
            nodes = []
        if has_count and not (isinstance(s["expect_node_count"], int) and s["expect_node_count"] >= 0):
            bad("expect_node_count 必须是非负整数")
        drops = s.get("allow_drop", [])
        if not (isinstance(drops, list) and all(isinstance(n, str) for n in drops)):
            bad("allow_drop 必须是字符串列表")
        if s.get("expect_provider_route") and fmt != "singbox":
            bad("expect_provider_route 只能用在 singbox 样本上")
        if "line_ending" in s:
            if fmt != "base64":
                bad("line_ending 只能用在 base64 样本上")
            elif s["line_ending"] not in ("crlf", "lf"):
                bad("line_ending 只能是 crlf 或 lf")
        if not isinstance(s.get("issues", []), list):
            bad("issues 必须是列表")
        fields = s.get("expect_fields", {})
        if not isinstance(fields, dict) or not all(isinstance(v, dict) for v in fields.values()):
            bad("expect_fields 必须是「节点 → {字段路径 = 值}」")
        else:
            for tag in fields:
                if tag not in nodes:
                    bad(f"expect_fields 写给了不在 expect_nodes 里的节点：{tag}")
    return problems


def load_manifest(path):
    path = Path(path)
    if not path.exists():
        raise SubcheckError(f"找不到样本清单：{path}")
    samples = tomllib.loads(path.read_text(encoding="utf-8")).get("sample", [])
    problems = validate_manifest(samples, path.parent)
    if problems:
        raise SubcheckError("样本清单不合格：\n" + "\n".join(f"- {p}" for p in problems))
    return samples


# ---------- 订阅原文 ----------

def expand_line(line):
    """样本里的可读写法展开成真实链接：`vmess-json {...}` → `vmess://<base64(紧凑 JSON)>`，其余原样。
    JSON 照 Xboard 用的 PHP json_encode 的默认行为转义：非 ASCII 转成 \\uXXXX，/ 转成 \\/。"""
    if line.startswith(VMESS_JSON):
        obj = json.loads(line[len(VMESS_JSON):])
        compact = json.dumps(obj, separators=(",", ":")).replace("/", "\\/")
        return "vmess://" + base64.b64encode(compact.encode()).decode()
    return line


def subscription_text(sample, base_dir):
    """交给 provide() 的订阅原文。clash / singbox 原样；base64 逐行展开，按 line_ending
    （默认 crlf：Xboard 的 General.php 每条链接都以 \\r\\n 结尾）拼接后整体 base64。"""
    text = (Path(base_dir) / sample["file"]).read_text(encoding="utf-8")
    if sample["format"] != "base64":
        return text
    sep = "\r\n" if sample.get("line_ending", "crlf") == "crlf" else "\n"
    links = [expand_line(line.strip()) for line in text.splitlines() if line.strip()]
    return base64.b64encode((sep.join(links) + sep).encode()).decode()


def names_text(sample, base_dir):
    """核对 expect_nodes 用的可读文本：base64 样本做 URL 解码（链接里的 #名字 是编码过的）。"""
    text = (Path(base_dir) / sample["file"]).read_text(encoding="utf-8")
    return urllib.parse.unquote(text) if sample["format"] == "base64" else text


# ---------- 判定 ----------

def output_nodes(config):
    """生成配置里的节点：出站中不是分组、direct、block、dns 的那些，按 tag。"""
    return [o.get("tag") for o in config.get("outbounds") or [] if o.get("type") not in NON_NODE_TYPES]


def _get_path(obj, dotted):
    cur = obj
    for part in dotted.split("."):
        if not isinstance(cur, dict) or cur.get(part) is None:
            return ABSENT
        cur = cur[part]
    return cur


def _show(value):
    return ABSENT if value == ABSENT else json.dumps(value, ensure_ascii=False)


def _renamed(name, tags):
    """输出里名字只多了空白或 \\r 的那个 tag（如 Base64 订阅用 \\r\\n 换行时的 "TJ-A\\r"），没有返回 None。"""
    return next((t for t in tags if isinstance(t, str) and t != name and t.strip() == name.strip()), None)


def field_mismatches(expect_fields, config):
    """expect_fields 与生成出站的差异，返回 [("节点 路径", 说明)]；节点不在输出里的跳过（已算丢节点），
    名字被改的照样比。null 与缺失都算「<无>」。"""
    outbounds = config.get("outbounds") or []
    by_tag = {o.get("tag"): o for o in outbounds}
    out = []
    for tag, fields in expect_fields.items():
        node = by_tag.get(tag)
        if node is None:
            node = by_tag.get(_renamed(tag, list(by_tag)))
        if node is None:
            continue
        for path, want in fields.items():
            got = _get_path(node, path)
            if not _same_value(got, want, path):
                out.append((f"{tag} {path}", f"{tag} 的 {path} 应为 {_show(want)}，实际 {_show(got)}"))
    return out


def _same_value(got, want, path):
    """相等才算相同；只有 HTTP header 的值写成 "h" 和 ["h"] 等价（sing-box 两种都收）。
    其它字段严格比较，<无>（缺失或 null）不参与等价。"""
    if got == want:
        return True
    if ".headers." not in f".{path}" or ABSENT in (got, want):
        return False
    if isinstance(got, list) and len(got) == 1 and not isinstance(want, list):
        return got[0] == want
    if isinstance(want, list) and len(want) == 1 and not isinstance(got, list):
        return want[0] == got
    return False


def _as_list(value):
    if value is None:
        return []
    return value if isinstance(value, list) else [value]


def provider_losses(provider, config):
    """原生订阅的分流与 DNS 是否保留：输入每条规则的 domain_suffix 都要在输出某条规则里，
    输入每个 DNS 服务器 tag 都要在输出里。返回丢失说明。"""
    losses = []
    out_rules = [set(_as_list(r.get("domain_suffix"))) for r in (config.get("route") or {}).get("rules") or []]
    for rule in (provider.get("route") or {}).get("rules") or []:
        want = set(_as_list(rule.get("domain_suffix")))
        if want and not any(want <= got for got in out_rules):
            losses.append(f"分流规则 {'、'.join(sorted(want))}")
    out_dns = {srv.get("tag") for srv in (config.get("dns") or {}).get("servers") or []}
    for srv in (provider.get("dns") or {}).get("servers") or []:
        if srv.get("tag") not in out_dns:
            losses.append(f"DNS 服务器 {srv.get('tag')}")
    return losses


def _items(value):
    return [v for v in value if isinstance(v, dict)] if isinstance(value, list) else []


def _obj(value):
    return value if isinstance(value, dict) else {}


def _detour_refs(config):
    """明确列出的出站引用字段（不递归扫描：inbound 的 detour 指向 inbound，请求头的名字可以随便取）。
    这里没列到的字段查不出来，见 README 的「已知边界」。"""
    for o in _items(config.get("outbounds")):
        yield f"{o.get('tag')}.detour", o.get("detour")
    for srv in _items(_obj(config.get("dns")).get("servers")):
        yield f"dns {srv.get('tag')}.detour", srv.get("detour")
    yield "ntp.detour", _obj(config.get("ntp")).get("detour")
    for i, inbound in enumerate(_items(config.get("inbounds"))):
        handshake = _obj(_obj(_obj(inbound.get("tls")).get("reality")).get("handshake"))
        yield f"inbounds[{i}].tls.reality.handshake.detour", handshake.get("detour")
    for i, rule_set in enumerate(_items(_obj(config.get("route")).get("rule_set"))):
        yield f"route.rule_set[{i}].download_detour", rule_set.get("download_detour")
    clash_api = _obj(_obj(config.get("experimental")).get("clash_api"))
    yield "experimental.clash_api.external_ui_download_detour", clash_api.get("external_ui_download_detour")


def dangling_refs(config):
    """分组、detour、路由引用了不存在或为空的出站。sing-box check 只做解码与构造、不启动，查不出这类问题，
    启动时才报 dependency not found（审查 2026-09-29 用 b64-noname 的输出实测过：check 通过，run 报错）。
    只核对字符串值；容器或值的类型不对是格式错误，由 sing-box check 判。"""
    outbounds = _items(config.get("outbounds"))
    tags = {o.get("tag") for o in outbounds + _items(config.get("endpoints"))
            if isinstance(o.get("tag"), str) and o.get("tag")}
    refs = []
    for o in outbounds:
        if o.get("type") in ("selector", "urltest"):
            members = o.get("outbounds")
            refs += [(o.get("tag"), t) for t in (members if isinstance(members, list) else [])]
            if o.get("default") is not None:
                refs.append((f"{o.get('tag')}.default", o["default"]))
    route = _obj(config.get("route"))
    if route.get("final") is not None:
        refs.append(("route.final", route["final"]))
    for i, rule in enumerate(route.get("rules") if isinstance(route.get("rules"), list) else []):
        if isinstance(rule, dict) and rule.get("outbound") is not None:
            refs.append((f"route.rules[{i}]", rule["outbound"]))
    refs += list(_detour_refs(config))
    return list(dict.fromkeys(f"{src} → {json.dumps(t, ensure_ascii=False)}" for src, t in refs
                              if isinstance(t, str) and t not in tags))


def judge(sample, driver_out, kernel_error=None, provider=None):
    """一个样本的发现列表（空 = 通过）。driver_out 是驱动写的 {ok, config | error}。"""
    if not driver_out.get("ok"):
        return [{"kind": "import_error", "detail": driver_out.get("error") or "驱动没有输出"}]
    config = driver_out.get("config") or {}
    findings = []
    nodes = output_nodes(config)
    if "expect_nodes" in sample:
        allow = set(sample.get("allow_drop", []))
        missing = [n for n in sample["expect_nodes"] if n not in nodes and n not in allow]
        renamed = {n: _renamed(n, nodes) for n in missing}
        lost = [n for n in missing if renamed[n] is None]
        if lost:
            findings.append({"kind": "nodes_missing", "detail": "丢了 " + "、".join(lost), "items": lost})
        moved = [n for n in missing if renamed[n] is not None]
        if moved:
            findings.append({"kind": "nodes_renamed", "items": moved,
                             "detail": "、".join(f"{n} → {json.dumps(renamed[n], ensure_ascii=False)}" for n in moved)})
    elif len(nodes) < sample["expect_node_count"]:
        # 条目按「少的第几个」记：少得更多时新条目包含旧条目，compare 才判得出变坏
        short = sample["expect_node_count"] - len(nodes)
        findings.append({"kind": "nodes_missing", "items": [f"少第 {i} 个" for i in range(1, short + 1)],
                         "detail": f"应有 {sample['expect_node_count']} 个，生成 {len(nodes)} 个"})
    mismatches = field_mismatches(sample.get("expect_fields", {}), config)
    if mismatches:
        findings.append({"kind": "field_mismatch", "detail": "；".join(t for _, t in mismatches),
                         "items": [a for a, _ in mismatches]})
    if kernel_error:
        findings.append({"kind": "kernel_rejected", "detail": kernel_error})
    dangling = dangling_refs(config)
    if dangling:
        findings.append({"kind": "start_error", "detail": "引用了不存在或为空的出站：" + "；".join(dangling),
                         "items": dangling})
    if sample.get("expect_provider_route") and provider is not None:
        losses = provider_losses(provider, config)
        if losses:
            findings.append({"kind": "provider_replaced", "detail": "没保留 " + "；".join(losses), "items": losses})
    return findings


def clean_kernel_error(text, config_path=None):
    """sing-box check 的报错取第一个非空行，去掉颜色控制符、FATAL[..] 前缀与配置文件路径。"""
    line = next((l for l in text.splitlines() if l.strip()), "")
    line = re.sub(r"\x1b\[[0-9;]*m", "", line)
    line = re.sub(r"^\s*FATAL\[\d+\]\s*", "", line)
    if config_path:
        line = line.replace(f" at {config_path}", "")
    line = re.sub(r"decode config at \S+?: ", "decode config: ", line)
    return line.strip() or "（内核没有输出报错）"


def kernel_tag(gradle_text):
    """插件 android/build.gradle.kts 里的 libbox 版本 → 内核 tag（如 v1.14.1）。"""
    version = _libbox_version(gradle_text or "")
    if not version:
        raise SubcheckError("没能从 android/build.gradle.kts 读出 libbox 版本，请用 --kernel 指定内核")
    return f"v{version}"


# ---------- 报告与对比 ----------

def _status(row):
    if not row["findings"]:
        return "通过"
    return "；".join(f"{KIND_LABEL[f['kind']]}：{f['detail']}" for f in row["findings"])


def _cell(text):
    return str(text).replace("|", "\\|").replace("\n", " ")


def _label(result):
    return f"{result['plugin_sha'][:7]}（{result.get('plugin_version') or '版本未知'}）"


def render_markdown(result):
    rows = result["samples"]
    passed = sum(1 for r in rows if not r["findings"])
    lines = [
        f"# 订阅样本库结果：flutter_sing_box {_label(result)}",
        "",
        f"- 提交：`{result['plugin_sha']}`；内核：sing-box {result['kernel']}；运行时间：{result['run_at']}",
        f"- 通过 {passed} / {len(rows)}",
        "- 判定口径见样本库的 README.md；样本全是构造的，期望值按理想情况写（节点不丢、字段写对、内核接受）",
        "",
        "| 样本 | 格式 | 被测写法 | 结果 | 关联 |",
        "|---|---|---|---|---|",
    ]
    for r in rows:
        lines.append(f"| {r['id']} | {r['format']} | {_cell(r['subject'])} | {_cell(_status(r))} | {'、'.join(r['issues'])} |")
    return "\n".join(lines) + "\n"


def _level(row):
    return max((LEVEL.get(f["kind"], 1) for f in row["findings"]), default=0)


def _atoms(row):
    """一个样本的发现拆成条目：有 items 的按条目（丢了哪个节点、哪个字段不对），没有的按整条说明。"""
    return {(f["kind"], str(it)) for f in row["findings"] for it in (f.get("items") or [f["detail"]])}


def compare(old, new):
    """按样本比较两份结果。先比严重度（整份用不了 > 丢节点 > 细节不对），同级再比条目：
    新结果多出条目算变坏，少了算变好，有多有少算有增有减，完全相同算不变。"""
    a = {r["id"]: r for r in old["samples"]}
    b = {r["id"]: r for r in new["samples"]}
    diff = {"better": [], "worse": [], "mixed": [], "same": [],
            "only_old": sorted(set(a) - set(b)), "only_new": sorted(set(b) - set(a))}
    for sid in [r["id"] for r in new["samples"] if r["id"] in a]:
        la, lb = _level(a[sid]), _level(b[sid])
        if la != lb:
            diff["worse" if lb > la else "better"].append(sid)
            continue
        aa, ab = _atoms(a[sid]), _atoms(b[sid])
        if aa == ab:
            diff["same"].append(sid)
        elif ab - aa and aa - ab:
            diff["mixed"].append(sid)
        else:
            diff["worse" if ab - aa else "better"].append(sid)
    return diff


def render_compare(old, new, diff):
    a = {r["id"]: r for r in old["samples"]}
    b = {r["id"]: r for r in new["samples"]}
    lines = [f"# 订阅样本库对比：{_label(old)} → {_label(new)}", "",
             f"- 旧：`{old['plugin_sha']}`，内核 {old['kernel']}；新：`{new['plugin_sha']}`，内核 {new['kernel']}",
             f"- 变坏 {len(diff['worse'])}，变好 {len(diff['better'])}，有增有减 {len(diff['mixed'])}，不变 {len(diff['same'])}",
             "- 先比严重度（整份用不了 > 丢节点 > 细节不对），同级再比具体条目（丢了哪个节点、哪个字段不对）", ""]
    for key, title in (("worse", "变坏"), ("better", "变好"), ("mixed", "有增有减")):
        lines += [f"## {title}", ""]
        if not diff[key]:
            lines += ["（无）", ""]
            continue
        lines += ["| 样本 | 旧 | 新 |", "|---|---|---|"]
        lines += [f"| {sid} | {_cell(_status(a[sid]))} | {_cell(_status(b[sid]))} |" for sid in diff[key]]
        lines.append("")
    lines += ["## 不变", "", "、".join(diff["same"]) or "（无）", ""]
    if diff["only_old"] or diff["only_new"]:
        lines += ["## 只在一边", "", f"- 只在旧结果：{'、'.join(diff['only_old']) or '无'}",
                  f"- 只在新结果：{'、'.join(diff['only_new']) or '无'}", ""]
    return "\n".join(lines)


# ---------- 运行 ----------

def _cmd(args, *, cwd=None, env=None, timeout=None, check=True):
    """跑一条命令。超时时连它的子进程一起结束（flutter test 会起 dart 子进程），不留着继续改缓存。"""
    args = [str(a) for a in args]
    group = hasattr(os, "killpg")
    try:
        proc = subprocess.Popen(args, cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                text=True, start_new_session=group)
    except FileNotFoundError:
        raise SubcheckError(f"找不到命令：{args[0]}") from None
    try:
        out, err = proc.communicate(timeout=timeout)
    except BaseException as e:
        # 超时，或被 Ctrl+C 等中断：子进程在独立进程组里收不到终端的信号，要整组结束
        if group:
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
        else:
            proc.kill()
        proc.communicate()
        if isinstance(e, subprocess.TimeoutExpired):
            raise SubcheckError(f"命令超时（{timeout} 秒）：{' '.join(args)}") from None
        raise
    p = subprocess.CompletedProcess(args, proc.returncode, out, err)
    if check and p.returncode != 0:
        tail = "\n".join((p.stdout + p.stderr).strip().splitlines()[-20:])
        raise SubcheckError(f"命令失败：{' '.join(args)}\n{tail}")
    return p


def git_env(root=ROOT):
    """读私有镜像时，用 config.toml 里 gh_account 指定账号的 token：
    只注入本进程的子命令，不切换 gh 的全局账号。没有 config.toml 时原样使用当前环境。"""
    env = dict(os.environ)
    cfg_path = Path(root) / "config.toml"
    if "GH_TOKEN" not in env and cfg_path.exists():
        account = tomllib.loads(cfg_path.read_text(encoding="utf-8")).get("gh_account")
        if account and shutil.which("gh"):
            p = subprocess.run(["gh", "auth", "token", "--user", account], capture_output=True, text=True)
            if p.returncode == 0 and p.stdout.strip():
                env["GH_TOKEN"] = p.stdout.strip()
    return env


def mirror_dir(root):
    return Path(root) / ".cache" / "repos" / "flutter_sing_box.git"


def repo_dir(root, repo=None):
    return Path(repo).expanduser().resolve() if repo else mirror_dir(root)


def resolve_ref(root, ref, env, repo=None):
    where = repo_dir(root, repo)
    if not where.exists():
        if repo:
            raise SubcheckError(f"--repo 指定的目录不存在：{where}")
        raise SubcheckError("没有指定 --repo：用 --repo 指向本机的 flutter_sing_box 仓库")
    if _cmd(["git", "-C", where, "rev-parse", "--git-dir"], env=env, check=False).returncode != 0:
        raise SubcheckError(f"{where} 不是 git 仓库")
    p = _cmd(["git", "-C", where, "rev-parse", "--verify", "--quiet", f"{ref}^{{commit}}"],
             env=env, check=False)
    if p.returncode != 0 or not p.stdout.strip():
        if repo:
            raise SubcheckError(f"{repo_dir(root, repo)} 里找不到 {ref}")
        raise SubcheckError(f"镜像里找不到 {ref}：先刷新镜像，或用 --repo 指定本机的 flutter_sing_box 仓库")
    return p.stdout.strip()


def strip_codegen_deps(pubspec_text):
    """去掉代码生成依赖（build_runner 等）。.g.dart 已随仓库提交，跑测试用不到它们。"""
    return re.sub(rf"^[ \t]+({'|'.join(CODEGEN_DEPS)}):.*\n?", "", pubspec_text, flags=re.M)


def prepare_plugin(root, sha, flutter, env, repo=None):
    """把插件导出到 .cache/subcheck/fsb-<sha>/ 并 pub get；已就绪（有 .subcheck-ready）就复用。"""
    dest = Path(root) / ".cache" / "subcheck" / f"fsb-{sha}"
    if (dest / ".subcheck-ready").exists():
        return dest
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    tar = dest.parent / f"fsb-{sha}.tar"
    _cmd(["git", "-C", repo_dir(root, repo), "archive", "--format=tar", "-o", tar, sha], env=env, timeout=900)
    _cmd(["tar", "-xf", tar, "-C", dest])
    tar.unlink()
    if _cmd([flutter, "pub", "get"], cwd=dest, env=env, timeout=900, check=False).returncode != 0:
        pubspec = dest / "pubspec.yaml"
        pubspec.write_text(strip_codegen_deps(pubspec.read_text(encoding="utf-8")), encoding="utf-8")
        _cmd([flutter, "pub", "get"], cwd=dest, env=env, timeout=900)
    (dest / ".subcheck-ready").write_text(sha, encoding="utf-8")
    return dest


def kernel_for(root, plugin_dir, override=None):
    if override:
        path = Path(override)
        if not path.exists():
            raise SubcheckError(f"--kernel 指定的内核不存在：{path}")
        return path, CUSTOM_KERNEL
    gradle = Path(plugin_dir) / "android" / "build.gradle.kts"
    tag = kernel_tag(gradle.read_text(encoding="utf-8") if gradle.exists() else "")
    path = Path(root) / ".cache" / "sing-box" / tag / "sing-box"
    if not path.exists():
        raise SubcheckError(f"没有 sing-box {tag}：先运行 verify/subs/build-singbox.sh {tag}")
    return path, tag


def run_driver(root, plugin_dir, flutter, entries, env):
    """entries: [(id, 订阅原文)]。返回 {id: 驱动输出}；flutter test 本身失败就报错。"""
    work = Path(plugin_dir) / ".subcheck-run"
    if work.exists():
        shutil.rmtree(work)
    (work / "in").mkdir(parents=True)
    (work / "out").mkdir()
    listing = []
    for sid, text in entries:
        f = work / "in" / sid
        f.write_text(text, encoding="utf-8")
        listing.append({"id": sid, "path": str(f)})
    (work / "input.json").write_text(json.dumps(listing, ensure_ascii=False))
    test_dir = Path(plugin_dir) / "test"
    test_dir.mkdir(exist_ok=True)
    shutil.copy(subs_dir(root) / "driver" / "subcheck_driver_test.dart", test_dir / "subcheck_driver_test.dart")
    denv = dict(env, SUBCHECK_INPUT=str(work / "input.json"), SUBCHECK_OUT=str(work / "out"))
    _cmd([flutter, "test", "test/subcheck_driver_test.dart"], cwd=plugin_dir, env=denv, timeout=1800)
    outs = {}
    for sid, _ in entries:
        f = work / "out" / f"{sid}.json"
        outs[sid] = json.loads(f.read_text(encoding="utf-8")) if f.exists() else {"ok": False, "error": "驱动没有输出"}
    return outs


def kernel_check(kernel, config, path):
    """交给 sing-box check：通过返回 None，否则返回清洗过的报错；超时也记为拒收，不中断整次运行。"""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(config, ensure_ascii=False), encoding="utf-8")
    try:
        p = subprocess.run([str(kernel), "check", "-c", str(path)], capture_output=True, text=True,
                           timeout=CHECK_TIMEOUT)
    except subprocess.TimeoutExpired:
        return f"check 超时（{CHECK_TIMEOUT} 秒）"
    return None if p.returncode == 0 else clean_kernel_error(p.stderr or p.stdout, str(path))


def manifest_digest(root):
    """清单、样本文件与驱动的指纹：结果是按当时的这些东西得出的，变了就不能拿旧结果比。"""
    base = subs_dir(root)
    h = hashlib.sha256()
    for path in [base / "samples.toml", base / "driver" / "subcheck_driver_test.dart",
                 *sorted((base / "samples").glob("*"))]:
        if path.is_file():
            h.update(path.relative_to(base).as_posix().encode() + b"\0" + path.read_bytes() + b"\0")
    return h.hexdigest()[:16]


def _prepare(root, ref, flutter, kernel, repo=None):
    env = git_env(root)
    flutter = Path(flutter or os.environ.get("FLUTTER") or shutil.which("flutter") or DEFAULT_FLUTTER)
    sha = resolve_ref(root, ref, env, repo)
    plugin = prepare_plugin(root, sha, flutter, env, repo)
    kpath, ktag = kernel_for(root, plugin, kernel)
    return env, flutter, sha, plugin, kpath, ktag


def run(ref, *, root=ROOT, only=None, flutter=None, kernel=None, repo=None):
    """跑样本库；完整运行写 results/<sha7>.json 与 .md，--only 只返回结果不落盘。"""
    root = Path(root).resolve()
    base = subs_dir(root)
    samples = load_manifest(base / "samples.toml")
    if only:
        unknown = set(only) - {s["id"] for s in samples}
        if unknown:
            raise SubcheckError("清单里没有这些样本：" + "、".join(sorted(unknown)))
        samples = [s for s in samples if s["id"] in set(only)]
    env, flutter, sha, plugin, kpath, ktag = _prepare(root, ref, flutter, kernel, repo)
    outs = run_driver(root, plugin, flutter, [(s["id"], subscription_text(s, base)) for s in samples], env)
    rows = []
    for s in samples:
        out = outs[s["id"]]
        kerr = kernel_check(kpath, out["config"], plugin / ".subcheck-run" / "check" / f"{s['id']}.json") \
            if out.get("ok") else None
        provider = json.loads((base / s["file"]).read_text(encoding="utf-8")) if s.get("expect_provider_route") else None
        rows.append({"id": s["id"], "format": s["format"], "subject": s["subject"], "issues": s.get("issues", []),
                     "findings": judge(s, out, kerr, provider),
                     "nodes": output_nodes(out["config"]) if out.get("ok") else []})
    result = {
        "plugin_sha": sha,
        "plugin_version": _pubspec_version((plugin / "pubspec.yaml").read_text(encoding="utf-8")),
        "kernel": ktag,
        "run_at": dt.datetime.now().astimezone().isoformat(timespec="seconds"),
        "manifest_digest": manifest_digest(root),
        "judge_version": JUDGE_VERSION,
        "samples": rows,
    }
    if not only:
        results = base / "results"
        _atomic_write(results / f"{sha[:7]}.json", json.dumps(result, ensure_ascii=False, indent=1) + "\n")
        _atomic_write(results / f"{sha[:7]}.md", render_markdown(result))
    return result


# ---------- 本地真实订阅 ----------

LOCAL_SUFFIXES = (".yaml", ".yml", ".txt", ".json")


def estimate_input_nodes(text):
    """真实订阅的输入节点数估计：JSON 数出站；Clash 数 proxies 下的 name；其余按 base64 解码后数 :// 行。"""
    t = text.strip()
    if t.startswith("{"):
        try:
            return len(output_nodes(json.loads(t)))
        except json.JSONDecodeError:
            return None
    m = re.search(r"^proxies:\s*\n(.*?)(?=^\S|\Z)", t + "\n", re.M | re.S)
    if m:
        return len(re.findall(r"^\s*-\s*\{?\s*name:", m[1], re.M))
    try:
        decoded = base64.b64decode(t + "=" * (-len(t) % 4)).decode("utf-8", "replace")
    except (binascii.Error, ValueError):
        return None
    return sum(1 for line in decoded.splitlines() if "://" in line)


def run_local(ref, *, root=ROOT, flutter=None, kernel=None, out=print, repo=None):
    """跑 verify/subs/local/ 下的真实订阅：只打印统计，不打印、不保存节点名、报错原文与订阅内容。"""
    root = Path(root).resolve()
    local = subs_dir(root) / "local"
    files = sorted(p for p in local.glob("*") if p.is_file() and p.suffix in LOCAL_SUFFIXES) if local.exists() else []
    if not files:
        raise SubcheckError(f"{local} 下没有订阅文件（支持 {' / '.join(LOCAL_SUFFIXES)}）；把面板返回的原文存进去，这个目录不进 git")
    env, flutter, sha, plugin, kpath, ktag = _prepare(root, ref, flutter, kernel, repo)
    texts = {f"local-{i}": f.read_text(encoding="utf-8", errors="replace") for i, f in enumerate(files, 1)}
    work = plugin / ".subcheck-run"
    try:
        try:
            outs = run_driver(root, plugin, flutter, list(texts.items()), env)
        except SubcheckError:
            # 驱动失败时的输出里有插件打印的节点名与异常原文，不带出来
            raise SubcheckError("跑本地订阅时驱动失败；为保护订阅内容，不显示驱动输出。"
                                "可以先用样本库确认工装正常，再把订阅拆小重试") from None
        out(f"flutter_sing_box {sha[:7]}，内核 {ktag}；只报统计，不输出节点名、报错原文与订阅内容")
        for (sid, text), f in zip(texts.items(), files):
            o = outs[sid]
            est = estimate_input_nodes(text)
            est_s = "?" if est is None else str(est)
            if not o.get("ok"):
                out(f"{f.name}：导入报错；输入约 {est_s} 个节点")
                continue
            kerr = kernel_check(kpath, o["config"], work / "check" / f"{sid}.json")
            n = len(output_nodes(o["config"]))
            out(f"{f.name}：输入约 {est_s} 个节点，生成 {n} 个；内核{'接受' if kerr is None else '拒收'}")
    finally:
        # 工作目录里有真实订阅原文与生成的配置（服务器、密码），跑完就删
        shutil.rmtree(work, ignore_errors=True)


# ---------- 命令行 ----------

def _load_or_run(ref, *, root, flutter, kernel, repo=None):
    sha = resolve_ref(root, ref, git_env(root), repo)
    path = subs_dir(root) / "results" / f"{sha[:7]}.json"
    # 指定了内核就重跑；默认运行也不复用指定内核跑出来的结果（两者用的内核可能不同）
    if path.exists() and kernel is None:
        saved = json.loads(path.read_text(encoding="utf-8"))
        if (saved.get("manifest_digest") == manifest_digest(root) and saved.get("judge_version") == JUDGE_VERSION
                and saved.get("kernel") != CUSTOM_KERNEL):
            return saved
        print(f"subcheck：{sha[:7]} 的结果是按旧的清单或判定得出的，重跑", file=sys.stderr)
    return run(sha, root=root, flutter=flutter, kernel=kernel, repo=repo)


def _on_sigterm(signum, frame):
    raise SystemExit(128 + signum)


def _exit_on_sigterm():
    """SIGTERM（CI 取消、kill）默认直接结束进程、不走 finally：改成抛 SystemExit，
    _cmd 才会结束子进程组，--local 才会删掉放着真实订阅的工作目录。"""
    signal.signal(signal.SIGTERM, _on_sigterm)


def main(argv=None, root=ROOT):
    ap = argparse.ArgumentParser(description="订阅样本库：对 flutter_sing_box 的提交跑样本，判定节点、字段与内核校验")
    sub = ap.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("run", help="跑样本库（--local 跑本地真实订阅）")
    r.add_argument("ref")
    r.add_argument("--only", help="只跑这些样本，逗号分隔；不写结果文件")
    r.add_argument("--local", action="store_true")
    c = sub.add_parser("compare", help="比较两个提交的结果（缺结果先跑）")
    c.add_argument("old")
    c.add_argument("new")
    c.add_argument("--fail-on-worse", action="store_true", help="有样本变坏时返回 2（CI 用来挡发版）")
    for p in (r, c):
        p.add_argument("--flutter")
        p.add_argument("--kernel")
        p.add_argument("--repo", help="本机的 flutter_sing_box 仓库；不写时读 .cache/repos/ 下的镜像")
    sub.add_parser("check-manifest", help="只校验样本清单")
    args = ap.parse_args(argv)
    _exit_on_sigterm()
    root = Path(root).resolve()
    try:
        if args.cmd == "check-manifest":
            print(f"样本清单合格：{len(load_manifest(subs_dir(root) / 'samples.toml'))} 个样本")
        elif args.cmd == "run" and args.local:
            run_local(args.ref, root=root, flutter=args.flutter, kernel=args.kernel, repo=args.repo)
        elif args.cmd == "run":
            only = [x.strip() for x in args.only.split(",") if x.strip()] if args.only else None
            print(render_markdown(run(args.ref, root=root, only=only, flutter=args.flutter, kernel=args.kernel,
                                      repo=args.repo)))
        else:
            kw = {"root": root, "flutter": args.flutter, "kernel": args.kernel, "repo": args.repo}
            old, new = _load_or_run(args.old, **kw), _load_or_run(args.new, **kw)
            diff = compare(old, new)
            text = render_compare(old, new, diff)
            name = f"compare-{old['plugin_sha'][:7]}-{new['plugin_sha'][:7]}.md"
            _atomic_write(subs_dir(root) / "results" / name, text)
            print(text)
            if args.fail_on_worse and diff["worse"]:
                return 2
    except SubcheckError as e:
        print(f"subcheck：{e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
