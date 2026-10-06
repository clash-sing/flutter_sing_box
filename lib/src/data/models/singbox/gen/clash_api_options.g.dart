// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clash_api_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClashAPIOptions _$ClashAPIOptionsFromJson(Map<String, dynamic> json) =>
    ClashAPIOptions()
      ..externalController = json['external_controller'] as String?
      ..externalUi = json['external_ui'] as String?
      ..externalUiDownloadUrl = json['external_ui_download_url'] as String?
      ..externalUiDownloadDetour =
          json['external_ui_download_detour'] as String?
      ..secret = json['secret'] as String?
      ..defaultMode = json['default_mode'] as String?
      ..accessControlAllowOrigin = json['access_control_allow_origin']
      ..accessControlAllowPrivateNetwork =
          json['access_control_allow_private_network'] as bool?;

Map<String, dynamic> _$ClashAPIOptionsToJson(ClashAPIOptions instance) =>
    <String, dynamic>{
      'external_controller': ?instance.externalController,
      'external_ui': ?instance.externalUi,
      'external_ui_download_url': ?instance.externalUiDownloadUrl,
      'external_ui_download_detour': ?instance.externalUiDownloadDetour,
      'secret': ?instance.secret,
      'default_mode': ?instance.defaultMode,
      'access_control_allow_origin': ?instance.accessControlAllowOrigin,
      'access_control_allow_private_network':
          ?instance.accessControlAllowPrivateNetwork,
    };
