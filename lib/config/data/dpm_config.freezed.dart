// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dpm_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DpmConfig {

 DpmMode get mode;
/// Create a copy of DpmConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DpmConfigCopyWith<DpmConfig> get copyWith => _$DpmConfigCopyWithImpl<DpmConfig>(this as DpmConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DpmConfig&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,mode);

@override
String toString() {
  return 'DpmConfig(mode: $mode)';
}


}

/// @nodoc
abstract mixin class $DpmConfigCopyWith<$Res>  {
  factory $DpmConfigCopyWith(DpmConfig value, $Res Function(DpmConfig) _then) = _$DpmConfigCopyWithImpl;
@useResult
$Res call({
 DpmMode mode
});




}
/// @nodoc
class _$DpmConfigCopyWithImpl<$Res>
    implements $DpmConfigCopyWith<$Res> {
  _$DpmConfigCopyWithImpl(this._self, this._then);

  final DpmConfig _self;
  final $Res Function(DpmConfig) _then;

/// Create a copy of DpmConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DpmMode,
  ));
}

}


/// @nodoc


class _DpmConfig implements DpmConfig {
  const _DpmConfig({this.mode = DpmMode.global});
  

@override@JsonKey() final  DpmMode mode;

/// Create a copy of DpmConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DpmConfigCopyWith<_DpmConfig> get copyWith => __$DpmConfigCopyWithImpl<_DpmConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DpmConfig&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,mode);

@override
String toString() {
  return 'DpmConfig(mode: $mode)';
}


}

/// @nodoc
abstract mixin class _$DpmConfigCopyWith<$Res> implements $DpmConfigCopyWith<$Res> {
  factory _$DpmConfigCopyWith(_DpmConfig value, $Res Function(_DpmConfig) _then) = __$DpmConfigCopyWithImpl;
@override @useResult
$Res call({
 DpmMode mode
});




}
/// @nodoc
class __$DpmConfigCopyWithImpl<$Res>
    implements _$DpmConfigCopyWith<$Res> {
  __$DpmConfigCopyWithImpl(this._self, this._then);

  final _DpmConfig _self;
  final $Res Function(_DpmConfig) _then;

/// Create a copy of DpmConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,}) {
  return _then(_DpmConfig(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DpmMode,
  ));
}


}

// dart format on
