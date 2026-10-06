// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sing_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingBox _$SingBoxFromJson(Map<String, dynamic> json) => SingBox(
  log: json['log'] == null
      ? null
      : LogOptions.fromJson(json['log'] as Map<String, dynamic>),
  dns: DNS.fromJson(json['dns'] as Map<String, dynamic>),
  inbounds: (json['inbounds'] as List<dynamic>)
      .map((e) => Inbound.fromJson(e as Map<String, dynamic>))
      .toList(),
  outbounds: (json['outbounds'] as List<dynamic>)
      .map((e) => Outbound.fromJson(e as Map<String, dynamic>))
      .toList(),
  route: RouteOptions.fromJson(json['route'] as Map<String, dynamic>),
  experimental: json['experimental'] == null
      ? null
      : ExperimentalOptions.fromJson(
          json['experimental'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SingBoxToJson(SingBox instance) => <String, dynamic>{
  'log': ?instance.log?.toJson(),
  'dns': instance.dns.toJson(),
  'inbounds': instance.inbounds.map((e) => e.toJson()).toList(),
  'outbounds': instance.outbounds.map((e) => e.toJson()).toList(),
  'route': instance.route.toJson(),
  'experimental': ?instance.experimental?.toJson(),
};
