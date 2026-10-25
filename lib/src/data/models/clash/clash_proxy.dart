import 'package:json_annotation/json_annotation.dart';

part 'clash_proxy.g.dart';

/// Clash 代理节点模型（各协议字段并集，未启用字段为 `null`）。
@JsonSerializable(explicitToJson: true)
class ClashProxy {
  /// 节点名（展示与选择器标识）。
  String name;
  /// 协议类型（见 [ClashProxyType]）。
  String type;
  /// 服务器地址。
  String? server;
  /// 服务器端口。
  int? port;
  /// 多端口写法（部分协议支持的端口段/列表）。
  String? ports;
  /// 用户名。
  String? username;
  /// 密码。
  String? password;
  /// 是否跳过证书校验（对应 JSON 键 `skip-cert-verify`）。
  @JsonKey(name: "skip-cert-verify")
  bool? skipCertVerify;
  /// TLS 客户端指纹（对应 JSON 键 `client-fingerprint`）。
  @JsonKey(name: "client-fingerprint")
  String? clientFingerprint;
  /// 是否支持 UDP。
  bool? udp;
  /// 是否启用 TCP Fast Open。
  bool? tfo;
  /// TLS SNI。
  String? sni;

  /// TLS SNI：mihomo 中 vmess/vless 的字段名为 servername，其余协议为 sni；互为兼容别名
  String? servername;

  /// 代理隧道自身用什么传输层连到服务器。
  /// tcp（默认）、ws、grpc、h2、http、xhttp（vless）、mkcp 等。
  String? network;
  /// 上行带宽（Mbps，hysteria / hysteria2）。
  int? up;
  /// 下行带宽（Mbps，hysteria / hysteria2）。
  int? down;
  /// 认证字符串（对应 JSON 键 `auth_str`）。
  @JsonKey(name: "auth_str")
  String? authStr;
  /// TLS ALPN 列表。
  List<String>? alpn;
  /// 子协议名（如 Shadowsocks 的 origin 等）。
  String? protocol;
  /// 是否启用 fast-open（对应 JSON 键 `fast-open`）。
  @JsonKey(name: "fast-open")
  bool? fastOpen;
  /// 是否禁用 MTU 探测（对应 JSON 键 `disable_mtu_discovery`）。
  @JsonKey(name: "disable_mtu_discovery")
  bool? disableMtuDiscovery;

  /// 用于 TUIC V5 的用户唯一识别码,使用TUIC V4时不可书写
  String? uuid;

  /// 是否在客户端启用 QUIC 的 0-RTT 握手这可以减少连接建立时间，但可能增加重放攻击的风险
  @JsonKey(name: "reduce-rtt")
  bool? reduceRtt;

  /// QUIC 拥塞控制算法，可选项为 cubic/new_reno/bbr
  @JsonKey(name: "congestion-controller")
  String? congestionController;

  /// UDP数据包中继模式，可以是 native/quic
  @JsonKey(name: "udp-relay-mode")
  String? udpRelayMode;
  /// BBR 拥塞控制参数（对应 JSON 键 `bbr-profile`）。
  @JsonKey(name: "bbr-profile")
  String? bbrProfile;

  /// QUIC 流量混淆器类型，可选 salamander gecko。如果为空则禁用。
  String? obfs;
  @JsonKey(name: "obfs-password")
  /// 混淆密码（对应 JSON 键 `obfs-password`）。
  String? obfsPassword;
  /// 混淆包长下限（对应 JSON 键 `obfs-min-packet-size`）。
  @JsonKey(name: "obfs-min-packet-size")
  int? obfsMinPacketSize;
  /// 混淆包长上限（对应 JSON 键 `obfs-max-packet-size`）。
  @JsonKey(name: "obfs-max-packet-size")
  int? obfsMaxPacketSize;
  /// 证书指纹。
  String? fingerprint;

  /// 检查空闲会话的时间间隔。默认值：30 秒。
  /// 空闲会话检查间隔（秒）。
  @JsonKey(name: "idle-session-check-interval")
  int? idleSessionCheckInterval;

  /// 在检查中，关闭闲置时间超过此值的会话。默认值：30 秒。
  /// 闲置会话超时（秒，超时关闭）。
  @JsonKey(name: "idle-session-timeout")
  int? idleSessionTimeout;
  /// 最小保留空闲会话数（对应 JSON 键 `min-idle-session`）。
  @JsonKey(name: "min-idle-session")
  int? minIdleSession;
  /// 客户端元数据（对应 JSON 键 `client-metadata`）。
  @JsonKey(name: "client-metadata")
  String? clientMetadata;
  /// 是否禁用 SNI（对应 JSON 键 `disable-sni`）。
  @JsonKey(name: "disable-sni")
  bool? disableSni;

  /// 发送保持连接活动的心跳包的间隔时间，单位为毫秒
  /// 心跳间隔（毫秒）。
  @JsonKey(name: "heartbeat-interval")
  int? heartbeatInterval;
  /// 是否启用 TLS。
  bool? tls;
  /// 加密方式。
  String? cipher;
  /// VMess alterId。
  int? alterId;
  /// 是否启用全局填充（对应 JSON 键 `global-padding`）。
  @JsonKey(name: "global-padding")
  bool? globalPadding;
  /// 是否启用认证长度扩展（对应 JSON 键 `authenticated-length`）。
  @JsonKey(name: "authenticated-length")
  bool? authenticatedLength;
  /// 包编码方式（对应 JSON 键 `packet-encoding`）。
  @JsonKey(name: "packet-encoding")
  String? packetEncoding;
  /// 流控（vless 的 xtls-rprx-vision 等）。
  String? flow;
  /// SIP003 插件名。
  String? plugin;

  /// sing-box 仅支持 obfs-local 和 v2ray-plugin。
  @JsonKey(name: "plugin-opts")
  PluginOpts? pluginOpts;
  /// 是否启用 UDP over TCP（对应 JSON 键 `udp-over-tcp`）。
  @JsonKey(name: "udp-over-tcp")
  bool? udpOverTcp;

  /// 协议版本，1 或 2，默认为 1。
  @JsonKey(name: "udp-over-tcp-version")
  int? udpOverTcpVersion;
  /// realm 传输参数（对应 JSON 键 `realm-opts`）。
  @JsonKey(name: "realm-opts")
  RealmOpts? realmOpts;
  /// REALITY 传输参数（对应 JSON 键 `reality-opts`）。
  @JsonKey(name: "reality-opts")
  RealityOpts? realityOpts;

  /// network: ws 的传输参数（v2ray-http-upgrade 组合出 httpupgrade 形态）
  @JsonKey(name: "ws-opts")
  WsOpts? wsOpts;

  /// network: grpc 的传输参数
  @JsonKey(name: "grpc-opts")
  GrpcOpts? grpcOpts;

  /// network: http 的传输参数
  @JsonKey(name: "http-opts")
  HttpOpts? httpOpts;

  /// network: h2 的传输参数
  @JsonKey(name: "h2-opts")
  H2Opts? h2Opts;

  /// snell 预共享密钥（mihomo 文档：必填）。
  String? psk;

  /// 协议版本（snell 为 1-5，tuic 亦有此字段）。YAML 中 int 与字符串两种
  /// 写法并存，建模为 Object? 由转换层归一，避免某一写法反序列化失败丢节点。
  @JsonKey(name: "version")
  Object? version;

  /// snell 连接复用（仅 v4/5 支持，默认 false）。
  bool? reuse;

  /// obfs-opts：snell 混淆参数。
  @JsonKey(name: "obfs-opts")
  ObfsOpts? obfsOpts;

  /// 构造节点；除 [name] / [type] 外均可空。
  ClashProxy({
    required this.name,
    required this.type,
    this.server,
    this.port,
    this.ports,
    this.username,
    this.password,
    this.skipCertVerify,
    this.clientFingerprint,
    this.udp,
    this.tfo,
    this.sni,
    this.servername,
    this.network,
    this.up,
    this.down,
    this.authStr,
    this.alpn,
    this.protocol,
    this.fastOpen,
    this.disableMtuDiscovery,
    this.uuid,
    this.reduceRtt,
    this.congestionController,
    this.udpRelayMode,
    this.bbrProfile,
    this.obfs,
    this.obfsPassword,
    this.obfsMinPacketSize,
    this.obfsMaxPacketSize,
    this.fingerprint,
    this.idleSessionCheckInterval,
    this.idleSessionTimeout,
    this.minIdleSession,
    this.clientMetadata,
    this.disableSni,
    this.heartbeatInterval,
    this.tls,
    this.cipher,
    this.alterId,
    this.globalPadding,
    this.authenticatedLength,
    this.flow,
    this.plugin,
    this.pluginOpts,
    this.udpOverTcp,
    this.udpOverTcpVersion,
    this.realmOpts,
    this.realityOpts,
    this.wsOpts,
    this.grpcOpts,
    this.httpOpts,
    this.h2Opts,
    this.psk,
    this.version,
    this.reuse,
    this.obfsOpts,
  });

  /// 从 JSON 反序列化。
  factory ClashProxy.fromJson(Map<String, dynamic> json) => _$ClashProxyFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ClashProxyToJson(this);
}

/// plugin-opts：SIP003 插件参数（对应 JSON 键 `plugin-opts`）。
@JsonSerializable(explicitToJson: true)
final class PluginOpts {
  /// 插件模式。
  final String? mode;
  /// 插件 host。
  final String? host;

  /// 构造插件参数。
  PluginOpts({this.mode, this.host});

  /// 从 JSON 反序列化。
  factory PluginOpts.fromJson(Map<String, dynamic> json) => _$PluginOptsFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$PluginOptsToJson(this);
}

/// obfs-opts：snell 混淆参数（mihomo 文档：mode 支持 http/tls）。
@JsonSerializable(explicitToJson: true)
final class ObfsOpts {
  /// 混淆模式（http / tls）。
  final String? mode;
  /// 混淆 host。
  final String? host;

  /// 构造混淆参数。
  ObfsOpts({this.mode, this.host});

  /// 从 JSON 反序列化。
  factory ObfsOpts.fromJson(Map<String, dynamic> json) => _$ObfsOptsFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ObfsOptsToJson(this);
}

/// realm-opts：realm 传输参数。
@JsonSerializable(explicitToJson: true)
final class RealmOpts {
  /// 是否启用。
  final bool? enable;
  /// 服务端 URL（对应 JSON 键 `server-url`）。
  @JsonKey(name: "server-url")
  final String? serverUrl;
  /// 认证 token。
  final String? token;
  /// realm 标识（对应 JSON 键 `realm-id`）。
  @JsonKey(name: "realm-id")
  final String? realmId;
  /// STUN 服务器列表（对应 JSON 键 `stun-servers`）。
  @JsonKey(name: "stun-servers")
  final List<String>? stunServers;

  /// 构造 realm 参数。
  RealmOpts({this.enable, this.serverUrl, this.token, this.realmId, this.stunServers});

  /// 从 JSON 反序列化。
  factory RealmOpts.fromJson(Map<String, dynamic> json) => _$RealmOptsFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$RealmOptsToJson(this);
}

/// reality-opts：REALITY 传输参数。
@JsonSerializable(explicitToJson: true)
final class RealityOpts {
  /// REALITY 公钥（对应 JSON 键 `public-key`）。
  @JsonKey(name: "public-key")
  final String? publicKey;
  /// REALITY short ID（对应 JSON 键 `short-id`）。
  @JsonKey(name: "short-id")
  final String? shortId;

  /// 构造 REALITY 参数。
  RealityOpts({this.publicKey, this.shortId});

  /// 从 JSON 反序列化。
  factory RealityOpts.fromJson(Map<String, dynamic> json) => _$RealityOptsFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$RealityOptsToJson(this);
}

/// ws-opts：network: ws 的传输参数。headers 值 mihomo 常见标量写法，
/// 转换层归一为 `List<String>`。
@JsonSerializable(explicitToJson: true)
final class WsOpts {
  /// WebSocket 路径。
  final String? path;
  /// 自定义请求头表。
  final Map<String, Object?>? headers;
  /// 0-RTT 早期数据上限（对应 JSON 键 `max-early-data`）。
  @JsonKey(name: "max-early-data")
  final int? maxEarlyData;
  /// 早期数据承载头名（对应 JSON 键 `early-data-header-name`）。
  @JsonKey(name: "early-data-header-name")
  final String? earlyDataHeaderName;
  /// 是否启用 httpupgrade 形态（对应 JSON 键 `v2ray-http-upgrade`）。
  @JsonKey(name: "v2ray-http-upgrade")
  final bool? v2rayHttpUpgrade;

  /// 构造 WebSocket 传输参数。
  WsOpts({
    this.path,
    this.headers,
    this.maxEarlyData,
    this.earlyDataHeaderName,
    this.v2rayHttpUpgrade,
  });

  /// 从 JSON 反序列化。
  factory WsOpts.fromJson(Map<String, dynamic> json) => _$WsOptsFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$WsOptsToJson(this);
}

/// grpc-opts：network: grpc 的传输参数。
@JsonSerializable(explicitToJson: true)
final class GrpcOpts {
  /// gRPC 服务名（对应 JSON 键 `grpc-service-name`）。
  @JsonKey(name: "grpc-service-name")
  final String? grpcServiceName;

  /// 构造 gRPC 传输参数。
  GrpcOpts({this.grpcServiceName});

  /// 从 JSON 反序列化。
  factory GrpcOpts.fromJson(Map<String, dynamic> json) => _$GrpcOptsFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$GrpcOptsToJson(this);
}

/// http-opts：network: http 的传输参数。path 为多路径列表
/// （mihomo 每连接随机轮换，转换取首个非空）。
@JsonSerializable(explicitToJson: true)
final class HttpOpts {
  /// HTTP 方法。
  final String? method;
  /// 请求路径列表（每连接轮换）。
  final List<String>? path;
  /// 自定义请求头表。
  final Map<String, Object?>? headers;

  /// 构造 HTTP 传输参数。
  HttpOpts({this.method, this.path, this.headers});

  /// 从 JSON 反序列化。
  factory HttpOpts.fromJson(Map<String, dynamic> json) => _$HttpOptsFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$HttpOptsToJson(this);
}

/// h2-opts：network: h2 的传输参数；host 为数组，path 为标量字符串
/// （mihomo 规范：Path string，数组形态会被 mihomo 拒收；与 http-opts
/// 的多路径列表不同，勿混淆）。
@JsonSerializable(explicitToJson: true)
final class H2Opts {
  /// host 列表（SNI 候选）。
  final List<String>? host;
  /// HTTP/2 路径。
  final String? path;

  /// 构造 HTTP/2 传输参数。
  H2Opts({this.host, this.path});

  /// 从 JSON 反序列化。
  factory H2Opts.fromJson(Map<String, dynamic> json) => _$H2OptsFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$H2OptsToJson(this);
}
