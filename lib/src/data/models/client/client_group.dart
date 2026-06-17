import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_group.freezed.dart';
part 'client_group.g.dart';

/// Represents a proxy group in the sing-box client.
@JsonSerializable(explicitToJson: true)
class ClientGroup {
  /// The tag of the group.
  final String tag;

  /// The type of the group (e.g., 'selector', 'urltest').
  String type;

  /// Whether the group allows selecting a specific proxy.
  bool selectable;

  /// The tag of the currently selected proxy in this group.
  String selected;

  /// Whether the group is expanded in the UI.
  bool isExpand;

  /// The list of items (proxies or other groups) in this group.
  List<ClientGroupItem>? items;

  /// Creates a new [ClientGroup] instance.
  ClientGroup({
    required this.tag,
    required this.type,
    required this.selectable,
    required this.selected,
    required this.isExpand,
    this.items,
  });

  /// Creates a new [ClientGroup] instance from a JSON map.
  factory ClientGroup.fromJson(Map<String, dynamic> json) => _$ClientGroupFromJson(json);

  /// Converts this [ClientGroup] instance to a JSON map.
  Map<String, dynamic> toJson() => _$ClientGroupToJson(this);
}

/// Represents an item within a proxy group.
@unfreezed
abstract class ClientGroupItem with _$ClientGroupItem {
  factory ClientGroupItem({
    required final String tag,
    required final String type,

    /// The timestamp of the last URL test.
    required int urlTestTime,

    /// The latency result of the last URL test in milliseconds.
    required int urlTestDelay,
  }) = _ClientGroupItem;

  /// Creates a new [ClientGroupItem] instance from a JSON map.
  factory ClientGroupItem.fromJson(Map<String, dynamic> json) => _$ClientGroupItemFromJson(json);

  /// Converts this [ClientGroupItem] instance to a JSON map.
  // Map<String, dynamic> toJson() => _$ClientGroupItemToJson(this);
}
