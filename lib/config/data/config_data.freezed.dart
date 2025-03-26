// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConfigData {

 Pubspec? get pubspec; Scripts get scripts;
/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigDataCopyWith<ConfigData> get copyWith => _$ConfigDataCopyWithImpl<ConfigData>(this as ConfigData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfigData&&(identical(other.pubspec, pubspec) || other.pubspec == pubspec)&&(identical(other.scripts, scripts) || other.scripts == scripts));
}


@override
int get hashCode => Object.hash(runtimeType,pubspec,scripts);

@override
String toString() {
  return 'ConfigData(pubspec: $pubspec, scripts: $scripts)';
}


}

/// @nodoc
abstract mixin class $ConfigDataCopyWith<$Res>  {
  factory $ConfigDataCopyWith(ConfigData value, $Res Function(ConfigData) _then) = _$ConfigDataCopyWithImpl;
@useResult
$Res call({
 Pubspec? pubspec, Scripts scripts
});


$ScriptsCopyWith<$Res> get scripts;

}
/// @nodoc
class _$ConfigDataCopyWithImpl<$Res>
    implements $ConfigDataCopyWith<$Res> {
  _$ConfigDataCopyWithImpl(this._self, this._then);

  final ConfigData _self;
  final $Res Function(ConfigData) _then;

/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pubspec = freezed,Object? scripts = null,}) {
  return _then(_self.copyWith(
pubspec: freezed == pubspec ? _self.pubspec : pubspec // ignore: cast_nullable_to_non_nullable
as Pubspec?,scripts: null == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as Scripts,
  ));
}
/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptsCopyWith<$Res> get scripts {
  
  return $ScriptsCopyWith<$Res>(_self.scripts, (value) {
    return _then(_self.copyWith(scripts: value));
  });
}
}


/// @nodoc


class _ConfigData implements ConfigData {
  const _ConfigData({this.pubspec, required this.scripts});
  

@override final  Pubspec? pubspec;
@override final  Scripts scripts;

/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigDataCopyWith<_ConfigData> get copyWith => __$ConfigDataCopyWithImpl<_ConfigData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfigData&&(identical(other.pubspec, pubspec) || other.pubspec == pubspec)&&(identical(other.scripts, scripts) || other.scripts == scripts));
}


@override
int get hashCode => Object.hash(runtimeType,pubspec,scripts);

@override
String toString() {
  return 'ConfigData(pubspec: $pubspec, scripts: $scripts)';
}


}

/// @nodoc
abstract mixin class _$ConfigDataCopyWith<$Res> implements $ConfigDataCopyWith<$Res> {
  factory _$ConfigDataCopyWith(_ConfigData value, $Res Function(_ConfigData) _then) = __$ConfigDataCopyWithImpl;
@override @useResult
$Res call({
 Pubspec? pubspec, Scripts scripts
});


@override $ScriptsCopyWith<$Res> get scripts;

}
/// @nodoc
class __$ConfigDataCopyWithImpl<$Res>
    implements _$ConfigDataCopyWith<$Res> {
  __$ConfigDataCopyWithImpl(this._self, this._then);

  final _ConfigData _self;
  final $Res Function(_ConfigData) _then;

/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pubspec = freezed,Object? scripts = null,}) {
  return _then(_ConfigData(
pubspec: freezed == pubspec ? _self.pubspec : pubspec // ignore: cast_nullable_to_non_nullable
as Pubspec?,scripts: null == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as Scripts,
  ));
}

/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptsCopyWith<$Res> get scripts {
  
  return $ScriptsCopyWith<$Res>(_self.scripts, (value) {
    return _then(_self.copyWith(scripts: value));
  });
}
}

// dart format on
