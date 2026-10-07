import 'package:json_annotation/json_annotation.dart';

part 'clash_proxy.g.dart';

@JsonSerializable(explicitToJson: true)
class ClashProxy {
  String name;
  String type;
  String? server;
  int? port;
  String? ports;
  String? password;
  @JsonKey(name: "skip-cert-verify")
  bool? skipCertVerify;
  @JsonKey(name: "client-fingerprint")
  String? clientFingerprint;
  bool? udp;
  bool? tfo;
  String? sni;

  /// TLS SNI：mihomo 中 vmess/vless 的字段名为 servername，其余协议为 sni；互为兼容别名
  String? servername;

  /// 代理隧道自身用什么传输层连到服务器。
  /// tcp（默认）、ws、grpc、h2、http、xhttp（vless）、mkcp 等。
  String? network;
  int? up;
  int? down;
  @JsonKey(name: "auth_str")
  String? authStr;
  List<String>? alpn;
  String? protocol;
  @JsonKey(name: "fast-open")
  bool? fastOpen;
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
  @JsonKey(name: "bbr-profile")
  String? bbrProfile;

  /// QUIC 流量混淆器类型，可选 salamander gecko。如果为空则禁用。
  String? obfs;
  @JsonKey(name: "obfs-password")
  String? obfsPassword;
  @JsonKey(name: "obfs-min-packet-size")
  int? obfsMinPacketSize;
  @JsonKey(name: "obfs-max-packet-size")
  int? obfsMaxPacketSize;
  String? fingerprint;

  /// 检查空闲会话的时间间隔。默认值：30 秒。
  @JsonKey(name: "idle-session-check-interval")
  int? idleSessionCheckInterval;

  /// 在检查中，关闭闲置时间超过此值的会话。默认值：30 秒。
  @JsonKey(name: "idle-session-timeout")
  int? idleSessionTimeout;
  @JsonKey(name: "min-idle-session")
  int? minIdleSession;
  @JsonKey(name: "client-metadata")
  String? clientMetadata;
  @JsonKey(name: "disable-sni")
  bool? disableSni;

  /// 发送保持连接活动的心跳包的间隔时间，单位为毫秒
  @JsonKey(name: "heartbeat-interval")
  int? heartbeatInterval;
  bool? tls;
  String? cipher;
  int? alterId;
  @JsonKey(name: "global-padding")
  bool? globalPadding;
  @JsonKey(name: "authenticated-length")
  bool? authenticatedLength;
  @JsonKey(name: "packet-encoding")
  String? packetEncoding;
  String? flow;
  String? plugin;

  /// sing-box 仅支持 obfs-local 和 v2ray-plugin。
  @JsonKey(name: "plugin-opts")
  PluginOpts? pluginOpts;
  @JsonKey(name: "udp-over-tcp")
  bool? udpOverTcp;

  /// 协议版本，1 或 2，默认为 1。
  @JsonKey(name: "udp-over-tcp-version")
  int? udpOverTcpVersion;
  @JsonKey(name: "realm-opts")
  RealmOpts? realmOpts;
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

  ClashProxy({
    required this.name,
    required this.type,
    this.server,
    this.port,
    this.ports,
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
  });

  factory ClashProxy.fromJson(Map<String, dynamic> json) => _$ClashProxyFromJson(json);

  Map<String, dynamic> toJson() => _$ClashProxyToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class PluginOpts {
  final String? mode;
  final String? host;

  PluginOpts({this.mode, this.host});

  factory PluginOpts.fromJson(Map<String, dynamic> json) => _$PluginOptsFromJson(json);

  Map<String, dynamic> toJson() => _$PluginOptsToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class RealmOpts {
  final bool? enable;
  @JsonKey(name: "server-url")
  final String? serverUrl;
  final String? token;
  @JsonKey(name: "realm-id")
  final String? realmId;
  @JsonKey(name: "stun-servers")
  final List<String>? stunServers;

  RealmOpts({this.enable, this.serverUrl, this.token, this.realmId, this.stunServers});

  factory RealmOpts.fromJson(Map<String, dynamic> json) => _$RealmOptsFromJson(json);

  Map<String, dynamic> toJson() => _$RealmOptsToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class RealityOpts {
  @JsonKey(name: "public-key")
  final String? publicKey;
  @JsonKey(name: "short-id")
  final String? shortId;

  RealityOpts({this.publicKey, this.shortId});

  factory RealityOpts.fromJson(Map<String, dynamic> json) => _$RealityOptsFromJson(json);

  Map<String, dynamic> toJson() => _$RealityOptsToJson(this);
}

/// ws-opts：network: ws 的传输参数。headers 值 mihomo 常见标量写法，
/// 转换层归一为 `List<String>`。
@JsonSerializable(explicitToJson: true)
final class WsOpts {
  final String? path;
  final Map<String, Object?>? headers;
  @JsonKey(name: "max-early-data")
  final int? maxEarlyData;
  @JsonKey(name: "early-data-header-name")
  final String? earlyDataHeaderName;
  @JsonKey(name: "v2ray-http-upgrade")
  final bool? v2rayHttpUpgrade;

  WsOpts({
    this.path,
    this.headers,
    this.maxEarlyData,
    this.earlyDataHeaderName,
    this.v2rayHttpUpgrade,
  });

  factory WsOpts.fromJson(Map<String, dynamic> json) => _$WsOptsFromJson(json);

  Map<String, dynamic> toJson() => _$WsOptsToJson(this);
}

/// grpc-opts：network: grpc 的传输参数。
@JsonSerializable(explicitToJson: true)
final class GrpcOpts {
  @JsonKey(name: "grpc-service-name")
  final String? grpcServiceName;

  GrpcOpts({this.grpcServiceName});

  factory GrpcOpts.fromJson(Map<String, dynamic> json) => _$GrpcOptsFromJson(json);

  Map<String, dynamic> toJson() => _$GrpcOptsToJson(this);
}

/// http-opts：network: http 的传输参数。path 为多路径列表
/// （mihomo 每连接随机轮换，转换取首个非空）。
@JsonSerializable(explicitToJson: true)
final class HttpOpts {
  final String? method;
  final List<String>? path;
  final Map<String, Object?>? headers;

  HttpOpts({this.method, this.path, this.headers});

  factory HttpOpts.fromJson(Map<String, dynamic> json) => _$HttpOptsFromJson(json);

  Map<String, dynamic> toJson() => _$HttpOptsToJson(this);
}

/// h2-opts：network: h2 的传输参数；host 与 path 均为数组。
@JsonSerializable(explicitToJson: true)
final class H2Opts {
  final List<String>? host;
  final List<String>? path;

  H2Opts({this.host, this.path});

  factory H2Opts.fromJson(Map<String, dynamic> json) => _$H2OptsFromJson(json);

  Map<String, dynamic> toJson() => _$H2OptsToJson(this);
}
