// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tun_platform_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TunPlatformOptions _$TunPlatformOptionsFromJson(Map<String, dynamic> json) =>
    TunPlatformOptions()
      ..httpProxy = json['http_proxy'] == null
          ? null
          : HTTPProxyOptions.fromJson(
              json['http_proxy'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$TunPlatformOptionsToJson(TunPlatformOptions instance) =>
    <String, dynamic>{'http_proxy': ?instance.httpProxy?.toJson()};
