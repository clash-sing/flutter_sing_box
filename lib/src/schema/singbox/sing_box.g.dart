// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sing_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingBox _$SingBoxFromJson(Map<String, dynamic> json) => SingBox(
  dns: Dns.fromJson(json['dns'] as Map<String, dynamic>),
  inbounds: (json['inbounds'] as List<dynamic>)
      .map((e) => Inbound.fromJson(e as Map<String, dynamic>))
      .toList(),
  route: Route.fromJson(json['route'] as Map<String, dynamic>),
  experimental: Experimental.fromJson(
    json['experimental'] as Map<String, dynamic>,
  ),
  outbounds: (json['outbounds'] as List<dynamic>)
      .map((e) => Outbound.fromJson(e as Map<String, dynamic>))
      .toList(),
  log: Log.fromJson(json['log'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SingBoxToJson(SingBox instance) => <String, dynamic>{
  'dns': instance.dns.toJson(),
  'inbounds': instance.inbounds.map((e) => e.toJson()).toList(),
  'route': instance.route.toJson(),
  'experimental': instance.experimental.toJson(),
  'outbounds': instance.outbounds.map((e) => e.toJson()).toList(),
  'log': instance.log.toJson(),
};
