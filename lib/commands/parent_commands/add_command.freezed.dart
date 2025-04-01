// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PubAddOptions {

 GlobalPubOptions get globalPubOptions; bool get offline; bool get dryRun; bool get precompile;
/// Create a copy of PubAddOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PubAddOptionsCopyWith<PubAddOptions> get copyWith => _$PubAddOptionsCopyWithImpl<PubAddOptions>(this as PubAddOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PubAddOptions&&(identical(other.globalPubOptions, globalPubOptions) || other.globalPubOptions == globalPubOptions)&&(identical(other.offline, offline) || other.offline == offline)&&(identical(other.dryRun, dryRun) || other.dryRun == dryRun)&&(identical(other.precompile, precompile) || other.precompile == precompile));
}


@override
int get hashCode => Object.hash(runtimeType,globalPubOptions,offline,dryRun,precompile);

@override
String toString() {
  return 'PubAddOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, precompile: $precompile)';
}


}

/// @nodoc
abstract mixin class $PubAddOptionsCopyWith<$Res>  {
  factory $PubAddOptionsCopyWith(PubAddOptions value, $Res Function(PubAddOptions) _then) = _$PubAddOptionsCopyWithImpl;
@useResult
$Res call({
 GlobalPubOptions globalPubOptions, bool offline, bool dryRun, bool precompile
});


$GlobalPubOptionsCopyWith<$Res> get globalPubOptions;

}
/// @nodoc
class _$PubAddOptionsCopyWithImpl<$Res>
    implements $PubAddOptionsCopyWith<$Res> {
  _$PubAddOptionsCopyWithImpl(this._self, this._then);

  final PubAddOptions _self;
  final $Res Function(PubAddOptions) _then;

/// Create a copy of PubAddOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? globalPubOptions = null,Object? offline = null,Object? dryRun = null,Object? precompile = null,}) {
  return _then(_self.copyWith(
globalPubOptions: null == globalPubOptions ? _self.globalPubOptions : globalPubOptions // ignore: cast_nullable_to_non_nullable
as GlobalPubOptions,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,dryRun: null == dryRun ? _self.dryRun : dryRun // ignore: cast_nullable_to_non_nullable
as bool,precompile: null == precompile ? _self.precompile : precompile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PubAddOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalPubOptionsCopyWith<$Res> get globalPubOptions {
  
  return $GlobalPubOptionsCopyWith<$Res>(_self.globalPubOptions, (value) {
    return _then(_self.copyWith(globalPubOptions: value));
  });
}
}


/// @nodoc


class _PubAddOptions implements PubAddOptions {
  const _PubAddOptions({required this.globalPubOptions, required this.offline, required this.dryRun, required this.precompile});
  

@override final  GlobalPubOptions globalPubOptions;
@override final  bool offline;
@override final  bool dryRun;
@override final  bool precompile;

/// Create a copy of PubAddOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PubAddOptionsCopyWith<_PubAddOptions> get copyWith => __$PubAddOptionsCopyWithImpl<_PubAddOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PubAddOptions&&(identical(other.globalPubOptions, globalPubOptions) || other.globalPubOptions == globalPubOptions)&&(identical(other.offline, offline) || other.offline == offline)&&(identical(other.dryRun, dryRun) || other.dryRun == dryRun)&&(identical(other.precompile, precompile) || other.precompile == precompile));
}


@override
int get hashCode => Object.hash(runtimeType,globalPubOptions,offline,dryRun,precompile);

@override
String toString() {
  return 'PubAddOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, precompile: $precompile)';
}


}

/// @nodoc
abstract mixin class _$PubAddOptionsCopyWith<$Res> implements $PubAddOptionsCopyWith<$Res> {
  factory _$PubAddOptionsCopyWith(_PubAddOptions value, $Res Function(_PubAddOptions) _then) = __$PubAddOptionsCopyWithImpl;
@override @useResult
$Res call({
 GlobalPubOptions globalPubOptions, bool offline, bool dryRun, bool precompile
});


@override $GlobalPubOptionsCopyWith<$Res> get globalPubOptions;

}
/// @nodoc
class __$PubAddOptionsCopyWithImpl<$Res>
    implements _$PubAddOptionsCopyWith<$Res> {
  __$PubAddOptionsCopyWithImpl(this._self, this._then);

  final _PubAddOptions _self;
  final $Res Function(_PubAddOptions) _then;

/// Create a copy of PubAddOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? globalPubOptions = null,Object? offline = null,Object? dryRun = null,Object? precompile = null,}) {
  return _then(_PubAddOptions(
globalPubOptions: null == globalPubOptions ? _self.globalPubOptions : globalPubOptions // ignore: cast_nullable_to_non_nullable
as GlobalPubOptions,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,dryRun: null == dryRun ? _self.dryRun : dryRun // ignore: cast_nullable_to_non_nullable
as bool,precompile: null == precompile ? _self.precompile : precompile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PubAddOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalPubOptionsCopyWith<$Res> get globalPubOptions {
  
  return $GlobalPubOptionsCopyWith<$Res>(_self.globalPubOptions, (value) {
    return _then(_self.copyWith(globalPubOptions: value));
  });
}
}

// dart format on
