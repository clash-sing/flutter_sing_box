// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clash_dns.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClashDns _$ClashDnsFromJson(Map<String, dynamic> json) => ClashDns(
  nameserverPolicy: (json['nameserver-policy'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
);

Map<String, dynamic> _$ClashDnsToJson(ClashDns instance) => <String, dynamic>{
  'nameserver-policy': ?instance.nameserverPolicy,
};
