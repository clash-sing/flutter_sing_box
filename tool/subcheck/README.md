# 订阅样本库

用一组构造的订阅，检查 flutter_sing_box 的订阅转换：节点有没有丢、字段写没写对、生成的配置 sing-box 内核收不收、sing-box 原生订阅的分流和 DNS 有没有被换掉。

**样本全是构造的，没有一份来自真实机场。** 写法照 Xboard 源码里的生成逻辑（读源码所见，没有抓过真实订阅），服务器都是 `*.example.com`，密码是 `pw`，uuid 和 REALITY 公钥是随手生成的测试值。

## 在这个仓库里

- **发版 CI**：推 `v*` tag 时，`.github/workflows/ci.yml` 的 `subcheck` 任务运行 `tool/subcheck/ci-compare.sh`，对比上一个 `v*` tag 和这次的 tag。「变坏」不为空，这个任务就失败，`publish` 和 `release` 不会运行。对比结果在这次运行的 Summary 页面。
- **打 tag 之前，本机先跑一遍**（默认对比 HEAD 和上一个 `v*` tag）：

      tool/subcheck/ci-compare.sh

  脚本按每个提交里 libbox 的版本自动下载 sing-box 官方发布的内核，不用装 Go。也可以指定两个提交：`tool/subcheck/ci-compare.sh <新> <旧>`。
- 「有增有减」不挡发布，也要看一眼：「内核拒收」变成「导入报错」这类变化会归到这一栏。
- 某个「变坏」是有意的（比如决定不再支持某种写法）：改 `verify/subs/samples.toml` 里这个样本的期望，和代码改动一起提交。对比时两边都按当前的期望判定。
- 下面「用法」里的命令都在 `tool/subcheck/` 目录下运行，`--repo` 写 `../..`。

## 需要的东西

- Flutter（能在 flutter_sing_box 目录里跑 `flutter test`）
- Go（编译 sing-box 内核用）
- git、bash、Python 3.11 以上

只在 macOS 上跑过。Linux 应该也能用；Windows 没试过，建议在 WSL 里跑。

## 用法

1. 编译插件对应版本的 sing-box 内核（每个版本编一次，产物在 `.cache/sing-box/<tag>/`）：

       verify/subs/build-singbox.sh v1.14.2

   版本取插件 `android/build.gradle.kts` 里 libbox 的版本。缺哪个版本，下一步会提示该编哪个。`compare` 的两个提交如果用的 libbox 版本不同，两个内核都要编。

2. 对插件的某个提交跑一遍（`--repo` 指向你本机的 flutter_sing_box 仓库，提交可以是 tag、分支或 SHA）：

       python3 tools/subcheck.py run v2.1.1 --repo ~/code/flutter_sing_box

   结果写在 `verify/subs/results/<sha前7位>.md`。Flutter 不在 PATH 里时，加 `--flutter <flutter 可执行文件路径>`。

3. **发版前**，对比上一个发布版本和这次要发的提交：

       python3 tools/subcheck.py compare v2.1.1 HEAD --repo ~/code/flutter_sing_box

   「变坏」一栏不是空的，就是这次改动让原来能用的订阅变差了，建议先修再发。加 `--fail-on-worse` 时有变坏退出码是 2，CI 可以靠它挡发版。

只跑几个样本（不写结果文件）：

    python3 tools/subcheck.py run HEAD --repo ~/code/flutter_sing_box --only clash-anytls,sb-no-dns-rules

## 怎么判定

每个样本走 `SingBoxConfigProvider.provide()`（App 导入订阅时调用的就是它），生成的整份配置交给对应版本的 `sing-box check`，另外静态检查分组、路由、DNS 有没有引用不存在的出站。发现分七类，没有发现就算通过：

| 类别 | 意思 |
|---|---|
| 导入报错 | `provide()` 抛异常 |
| 丢了节点 | 期望的节点不在生成的配置里（sing-box 本身不支持的写法，如 xhttp、kcp，允许丢） |
| 名字被改 | 节点在，但名字多了空白或 `\r` |
| 字段不符 | 期望的字段值不同、缺了，或不该出现的字段出现了 |
| 内核拒收 | `sing-box check` 不通过 |
| 启动会失败 | 分组、`route.final`、路由规则、DNS detour 引用了不存在或为空的出站：`check` 查不出，启动时会报错 |
| 分流 / DNS 被换 | 原生 sing-box 订阅里，提供方分流规则的 `domain_suffix` 或 DNS 服务器的 `tag` 在生成的配置里找不到（只核对这两项，见「已知边界」） |

期望值按理想情况写，不按插件现状写。每个样本的期望写在 `verify/subs/samples.toml`。「关联」一列是对应的 GitHub issue，写成「仓库#编号」，比如 `clash_sing_app#8` 指 clash-sing/clash_sing_app 的 #8。

对比先比严重度（整份用不了：导入报错、内核拒收、启动会失败 > 丢了节点 > 细节不对），同一级再比具体条目。

## 已知边界

- 只测插件这一层，不经过 App 界面。
- 期望里没写到的字段，丢了也查不出来。
- 规则改走了哪个出站、DNS 服务器的地址变了、DNS 规则被删了，「分流 / DNS 被换」查不出来：它只核对分流规则的 `domain_suffix` 和 DNS 服务器的 `tag` 还在不在。
- 允许丢的节点（`allow_drop`，如 sing-box 不支持的 xhttp、kcp）如果没被丢、而是保留成了别的传输（比如裸 TCP），查不出来：这类节点只写了「丢掉算合格」，没写保留时该是什么样。
- 「启动会失败」只查这些引用出站的地方：分组的成员与默认值、`route.final`、路由规则的 `outbound`，以及出站、DNS 服务器、`ntp`、REALITY 握手、规则集下载、面板下载的 `detour`。sing-box 别处新增的引用字段查不出来。
- 不测真实连接：`sing-box check` 只做解码和构造，不启动。
- 编译内核时没带 naive 等编译标签，含这些协议的订阅会被误判为内核拒收；样本里没有这些协议。

## 加样本

1. 样本文件放 `verify/subs/samples/<id>.yaml|txt|json`，id 和文件名相同。
2. Clash 和 Base64 样本用「两个 trojan 垫底（TJ-A、TJ-B）+ 一个被测节点」，和对照组只差一个变量。
3. Base64 样本存的是解码后的链接，一行一条；运行时按 `line_ending`（默认 `crlf`）拼起来再整体 base64。vmess 链接写成 `vmess-json {...}`，运行时展开成 `vmess://<base64>`。
4. 在 `samples.toml` 里加一条，`python3 tools/subcheck.py check-manifest` 校验格式。
