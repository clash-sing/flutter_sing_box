import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../constants/flutter_sing_box_constants.dart';

// 错误类型随校验器一并暴露，调用方无需直接依赖 json_schema_builder
export 'package:json_schema_builder/json_schema_builder.dart'
    show ValidationError;

/// 校验 sing-box 配置是否符合官方 JSON Schema（draft 2020-12）。
///
/// schema 约 470KB，[fromMap] 构建有解析开销，构建一次后应复用实例；
/// 正式环境经 [instance] 获取缓存实例。
class SingBoxSchemaValidator {
  final Schema _schema;

  /// 缓存已构建的实例：schema 约 470KB，重复构建纯浪费
  static SingBoxSchemaValidator? _cachedInstance;

  const SingBoxSchemaValidator._(this._schema);

  /// 从插件 asset 加载 schema 并缓存，后续调用零开销。
  ///
  /// [assetLoader] 仅供测试注入（纯 dart 测试无 asset bundle，传文件
  /// 读取）；注入的 loader 同样会填充缓存，测试隔离用 [resetCache]。
  static Future<SingBoxSchemaValidator> instance({
    Future<String> Function(String assetPath)? assetLoader,
  }) async {
    final cached = _cachedInstance;
    if (cached != null) return cached;
    final loader = assetLoader ?? rootBundle.loadString;
    final raw = await loader(FlutterSingBoxConstants.schemaConfig);
    return _cachedInstance = SingBoxSchemaValidator.fromMap(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  /// 重置 [instance] 缓存，仅供测试隔离使用。
  @visibleForTesting
  static void resetCache() => _cachedInstance = null;

  /// 从已解码的 schema JSON 构建。
  ///
  /// 顶层 `$schema` 声明指向远程元模式（json-schema.org），保留它会让
  /// [validateSync] 尝试联网抓取该元模式（离线环境直接抛异常）；本包固定
  /// 按 2020-12 规则校验，该声明无实际作用，这里剥掉以保证纯离线校验。
  /// 顶层 `$id` 则保留：注册表靠它建立 `#/$defs/...` 内部引用的解析基准。
  factory SingBoxSchemaValidator.fromMap(Map<String, dynamic> schemaMap) {
    final map = Map<String, dynamic>.from(schemaMap);
    map.remove(r'$schema');
    return SingBoxSchemaValidator._(Schema.fromMap(map));
  }

  /// 校验配置（通常为 SingBox.toJson() 的输出）。
  ///
  /// 返回错误列表，空列表即合法；每项可用 [ValidationError.toErrorString]
  /// 直接输出带路径的可读信息。
  List<ValidationError> validateSync(Map<String, dynamic> config) =>
      _schema.validateSync(config);
}
