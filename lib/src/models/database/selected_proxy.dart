import 'package:json_annotation/json_annotation.dart';


part 'selected_proxy.g.dart';

@JsonSerializable()
class SelectedProxy {
  final int profileId;
  final String selector;
  final String outbound;

  SelectedProxy({
    required this.profileId,
    required this.selector,
    required this.outbound,
  });

  factory SelectedProxy.fromJson(Map<String, dynamic> json) => _$SelectedProxyFromJson(json);

  Map<String, dynamic> toJson() => _$SelectedProxyToJson(this);
}
