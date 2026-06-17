// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientGroupItem {

 String get tag; String get type;/// The timestamp of the last URL test.
 int get urlTestTime;/// The timestamp of the last URL test.
 set urlTestTime(int value);/// The latency result of the last URL test in milliseconds.
 int get urlTestDelay;/// The latency result of the last URL test in milliseconds.
 set urlTestDelay(int value);
/// Create a copy of ClientGroupItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientGroupItemCopyWith<ClientGroupItem> get copyWith => _$ClientGroupItemCopyWithImpl<ClientGroupItem>(this as ClientGroupItem, _$identity);

  /// Serializes this ClientGroupItem to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  return 'ClientGroupItem(tag: $tag, type: $type, urlTestTime: $urlTestTime, urlTestDelay: $urlTestDelay)';
}


}

/// @nodoc
abstract mixin class $ClientGroupItemCopyWith<$Res>  {
  factory $ClientGroupItemCopyWith(ClientGroupItem value, $Res Function(ClientGroupItem) _then) = _$ClientGroupItemCopyWithImpl;
@useResult
$Res call({
 String tag, String type, int urlTestTime, int urlTestDelay
});




}
/// @nodoc
class _$ClientGroupItemCopyWithImpl<$Res>
    implements $ClientGroupItemCopyWith<$Res> {
  _$ClientGroupItemCopyWithImpl(this._self, this._then);

  final ClientGroupItem _self;
  final $Res Function(ClientGroupItem) _then;

/// Create a copy of ClientGroupItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tag = null,Object? type = null,Object? urlTestTime = null,Object? urlTestDelay = null,}) {
  return _then(_self.copyWith(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,urlTestTime: null == urlTestTime ? _self.urlTestTime : urlTestTime // ignore: cast_nullable_to_non_nullable
as int,urlTestDelay: null == urlTestDelay ? _self.urlTestDelay : urlTestDelay // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientGroupItem].
extension ClientGroupItemPatterns on ClientGroupItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientGroupItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientGroupItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientGroupItem value)  $default,){
final _that = this;
switch (_that) {
case _ClientGroupItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientGroupItem value)?  $default,){
final _that = this;
switch (_that) {
case _ClientGroupItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tag,  String type,  int urlTestTime,  int urlTestDelay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientGroupItem() when $default != null:
return $default(_that.tag,_that.type,_that.urlTestTime,_that.urlTestDelay);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tag,  String type,  int urlTestTime,  int urlTestDelay)  $default,) {final _that = this;
switch (_that) {
case _ClientGroupItem():
return $default(_that.tag,_that.type,_that.urlTestTime,_that.urlTestDelay);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tag,  String type,  int urlTestTime,  int urlTestDelay)?  $default,) {final _that = this;
switch (_that) {
case _ClientGroupItem() when $default != null:
return $default(_that.tag,_that.type,_that.urlTestTime,_that.urlTestDelay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientGroupItem implements ClientGroupItem {
   _ClientGroupItem({required this.tag, required this.type, required this.urlTestTime, required this.urlTestDelay});
  factory _ClientGroupItem.fromJson(Map<String, dynamic> json) => _$ClientGroupItemFromJson(json);

@override final  String tag;
@override final  String type;
/// The timestamp of the last URL test.
@override  int urlTestTime;
/// The latency result of the last URL test in milliseconds.
@override  int urlTestDelay;

/// Create a copy of ClientGroupItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientGroupItemCopyWith<_ClientGroupItem> get copyWith => __$ClientGroupItemCopyWithImpl<_ClientGroupItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientGroupItemToJson(this, );
}



@override
String toString() {
  return 'ClientGroupItem(tag: $tag, type: $type, urlTestTime: $urlTestTime, urlTestDelay: $urlTestDelay)';
}


}

/// @nodoc
abstract mixin class _$ClientGroupItemCopyWith<$Res> implements $ClientGroupItemCopyWith<$Res> {
  factory _$ClientGroupItemCopyWith(_ClientGroupItem value, $Res Function(_ClientGroupItem) _then) = __$ClientGroupItemCopyWithImpl;
@override @useResult
$Res call({
 String tag, String type, int urlTestTime, int urlTestDelay
});




}
/// @nodoc
class __$ClientGroupItemCopyWithImpl<$Res>
    implements _$ClientGroupItemCopyWith<$Res> {
  __$ClientGroupItemCopyWithImpl(this._self, this._then);

  final _ClientGroupItem _self;
  final $Res Function(_ClientGroupItem) _then;

/// Create a copy of ClientGroupItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? type = null,Object? urlTestTime = null,Object? urlTestDelay = null,}) {
  return _then(_ClientGroupItem(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,urlTestTime: null == urlTestTime ? _self.urlTestTime : urlTestTime // ignore: cast_nullable_to_non_nullable
as int,urlTestDelay: null == urlTestDelay ? _self.urlTestDelay : urlTestDelay // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
