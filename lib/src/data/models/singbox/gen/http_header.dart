// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'http_header.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class HTTPHeader {

  HTTPHeader();

  factory HTTPHeader.fromJson(Map<String, dynamic> json) =>
      _$HTTPHeaderFromJson(json);

  Map<String, dynamic> toJson() => _$HTTPHeaderToJson(this);
}
