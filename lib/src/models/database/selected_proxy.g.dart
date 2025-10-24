// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_proxy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectedProxy _$SelectedProxyFromJson(Map<String, dynamic> json) =>
    SelectedProxy(
      profileId: (json['profileId'] as num).toInt(),
      selector: json['selector'] as String,
      outbound: json['outbound'] as String,
    );

Map<String, dynamic> _$SelectedProxyToJson(SelectedProxy instance) =>
    <String, dynamic>{
      'profileId': instance.profileId,
      'selector': instance.selector,
      'outbound': instance.outbound,
    };
