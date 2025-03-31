// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dpk_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DpkConfig {

 DpkMode get mode;
/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DpkConfigCopyWith<DpkConfig> get copyWith => _$DpkConfigCopyWithImpl<DpkConfig>(this as DpkConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DpkConfig&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,mode);

@override
String toString() {
  return 'DpkConfig(mode: $mode)';
}


}

/// @nodoc
abstract mixin class $DpkConfigCopyWith<$Res>  {
  factory $DpkConfigCopyWith(DpkConfig value, $Res Function(DpkConfig) _then) = _$DpkConfigCopyWithImpl;
@useResult
$Res call({
 DpkMode mode
});




}
/// @nodoc
class _$DpkConfigCopyWithImpl<$Res>
    implements $DpkConfigCopyWith<$Res> {
  _$DpkConfigCopyWithImpl(this._self, this._then);

  final DpkConfig _self;
  final $Res Function(DpkConfig) _then;

/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DpkMode,
  ));
}

}


/// @nodoc


class _DpkConfig implements DpkConfig {
  const _DpkConfig({this.mode = DpkMode.global});
  

@override@JsonKey() final  DpkMode mode;

/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DpkConfigCopyWith<_DpkConfig> get copyWith => __$DpkConfigCopyWithImpl<_DpkConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DpkConfig&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,mode);

@override
String toString() {
  return 'DpkConfig(mode: $mode)';
}


}

/// @nodoc
abstract mixin class _$DpkConfigCopyWith<$Res> implements $DpkConfigCopyWith<$Res> {
  factory _$DpkConfigCopyWith(_DpkConfig value, $Res Function(_DpkConfig) _then) = __$DpkConfigCopyWithImpl;
@override @useResult
$Res call({
 DpkMode mode
});




}
/// @nodoc
class __$DpkConfigCopyWithImpl<$Res>
    implements _$DpkConfigCopyWith<$Res> {
  __$DpkConfigCopyWithImpl(this._self, this._then);

  final _DpkConfig _self;
  final $Res Function(_DpkConfig) _then;

/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,}) {
  return _then(_DpkConfig(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DpkMode,
  ));
}


}

// dart format on
