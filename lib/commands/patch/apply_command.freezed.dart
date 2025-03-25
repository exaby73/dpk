// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'apply_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApplyOptions {

 GlobalPatchOptions get globalPatchOptions; bool get force;
/// Create a copy of ApplyOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplyOptionsCopyWith<ApplyOptions> get copyWith => _$ApplyOptionsCopyWithImpl<ApplyOptions>(this as ApplyOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplyOptions&&(identical(other.globalPatchOptions, globalPatchOptions) || other.globalPatchOptions == globalPatchOptions)&&(identical(other.force, force) || other.force == force));
}


@override
int get hashCode => Object.hash(runtimeType,globalPatchOptions,force);

@override
String toString() {
  return 'ApplyOptions(globalPatchOptions: $globalPatchOptions, force: $force)';
}


}

/// @nodoc
abstract mixin class $ApplyOptionsCopyWith<$Res>  {
  factory $ApplyOptionsCopyWith(ApplyOptions value, $Res Function(ApplyOptions) _then) = _$ApplyOptionsCopyWithImpl;
@useResult
$Res call({
 GlobalPatchOptions globalPatchOptions, bool force
});


$GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions;

}
/// @nodoc
class _$ApplyOptionsCopyWithImpl<$Res>
    implements $ApplyOptionsCopyWith<$Res> {
  _$ApplyOptionsCopyWithImpl(this._self, this._then);

  final ApplyOptions _self;
  final $Res Function(ApplyOptions) _then;

/// Create a copy of ApplyOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? globalPatchOptions = null,Object? force = null,}) {
  return _then(_self.copyWith(
globalPatchOptions: null == globalPatchOptions ? _self.globalPatchOptions : globalPatchOptions // ignore: cast_nullable_to_non_nullable
as GlobalPatchOptions,force: null == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ApplyOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions {
  
  return $GlobalPatchOptionsCopyWith<$Res>(_self.globalPatchOptions, (value) {
    return _then(_self.copyWith(globalPatchOptions: value));
  });
}
}


/// @nodoc


class _ApplyOptions implements ApplyOptions {
  const _ApplyOptions({required this.globalPatchOptions, required this.force});
  

@override final  GlobalPatchOptions globalPatchOptions;
@override final  bool force;

/// Create a copy of ApplyOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplyOptionsCopyWith<_ApplyOptions> get copyWith => __$ApplyOptionsCopyWithImpl<_ApplyOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApplyOptions&&(identical(other.globalPatchOptions, globalPatchOptions) || other.globalPatchOptions == globalPatchOptions)&&(identical(other.force, force) || other.force == force));
}


@override
int get hashCode => Object.hash(runtimeType,globalPatchOptions,force);

@override
String toString() {
  return 'ApplyOptions(globalPatchOptions: $globalPatchOptions, force: $force)';
}


}

/// @nodoc
abstract mixin class _$ApplyOptionsCopyWith<$Res> implements $ApplyOptionsCopyWith<$Res> {
  factory _$ApplyOptionsCopyWith(_ApplyOptions value, $Res Function(_ApplyOptions) _then) = __$ApplyOptionsCopyWithImpl;
@override @useResult
$Res call({
 GlobalPatchOptions globalPatchOptions, bool force
});


@override $GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions;

}
/// @nodoc
class __$ApplyOptionsCopyWithImpl<$Res>
    implements _$ApplyOptionsCopyWith<$Res> {
  __$ApplyOptionsCopyWithImpl(this._self, this._then);

  final _ApplyOptions _self;
  final $Res Function(_ApplyOptions) _then;

/// Create a copy of ApplyOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? globalPatchOptions = null,Object? force = null,}) {
  return _then(_ApplyOptions(
globalPatchOptions: null == globalPatchOptions ? _self.globalPatchOptions : globalPatchOptions // ignore: cast_nullable_to_non_nullable
as GlobalPatchOptions,force: null == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ApplyOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions {
  
  return $GlobalPatchOptionsCopyWith<$Res>(_self.globalPatchOptions, (value) {
    return _then(_self.copyWith(globalPatchOptions: value));
  });
}
}

// dart format on
