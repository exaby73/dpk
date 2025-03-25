// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remove_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PubRemoveOptions {

 GlobalPubOptions get globalPubOptions; bool get offline; bool get dryRun; bool get precompile;
/// Create a copy of PubRemoveOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PubRemoveOptionsCopyWith<PubRemoveOptions> get copyWith => _$PubRemoveOptionsCopyWithImpl<PubRemoveOptions>(this as PubRemoveOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PubRemoveOptions&&(identical(other.globalPubOptions, globalPubOptions) || other.globalPubOptions == globalPubOptions)&&(identical(other.offline, offline) || other.offline == offline)&&(identical(other.dryRun, dryRun) || other.dryRun == dryRun)&&(identical(other.precompile, precompile) || other.precompile == precompile));
}


@override
int get hashCode => Object.hash(runtimeType,globalPubOptions,offline,dryRun,precompile);

@override
String toString() {
  return 'PubRemoveOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, precompile: $precompile)';
}


}

/// @nodoc
abstract mixin class $PubRemoveOptionsCopyWith<$Res>  {
  factory $PubRemoveOptionsCopyWith(PubRemoveOptions value, $Res Function(PubRemoveOptions) _then) = _$PubRemoveOptionsCopyWithImpl;
@useResult
$Res call({
 GlobalPubOptions globalPubOptions, bool offline, bool dryRun, bool precompile
});


$GlobalPubOptionsCopyWith<$Res> get globalPubOptions;

}
/// @nodoc
class _$PubRemoveOptionsCopyWithImpl<$Res>
    implements $PubRemoveOptionsCopyWith<$Res> {
  _$PubRemoveOptionsCopyWithImpl(this._self, this._then);

  final PubRemoveOptions _self;
  final $Res Function(PubRemoveOptions) _then;

/// Create a copy of PubRemoveOptions
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
/// Create a copy of PubRemoveOptions
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


class _PubRemoveOptions implements PubRemoveOptions {
  const _PubRemoveOptions({required this.globalPubOptions, required this.offline, required this.dryRun, required this.precompile});
  

@override final  GlobalPubOptions globalPubOptions;
@override final  bool offline;
@override final  bool dryRun;
@override final  bool precompile;

/// Create a copy of PubRemoveOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PubRemoveOptionsCopyWith<_PubRemoveOptions> get copyWith => __$PubRemoveOptionsCopyWithImpl<_PubRemoveOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PubRemoveOptions&&(identical(other.globalPubOptions, globalPubOptions) || other.globalPubOptions == globalPubOptions)&&(identical(other.offline, offline) || other.offline == offline)&&(identical(other.dryRun, dryRun) || other.dryRun == dryRun)&&(identical(other.precompile, precompile) || other.precompile == precompile));
}


@override
int get hashCode => Object.hash(runtimeType,globalPubOptions,offline,dryRun,precompile);

@override
String toString() {
  return 'PubRemoveOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, precompile: $precompile)';
}


}

/// @nodoc
abstract mixin class _$PubRemoveOptionsCopyWith<$Res> implements $PubRemoveOptionsCopyWith<$Res> {
  factory _$PubRemoveOptionsCopyWith(_PubRemoveOptions value, $Res Function(_PubRemoveOptions) _then) = __$PubRemoveOptionsCopyWithImpl;
@override @useResult
$Res call({
 GlobalPubOptions globalPubOptions, bool offline, bool dryRun, bool precompile
});


@override $GlobalPubOptionsCopyWith<$Res> get globalPubOptions;

}
/// @nodoc
class __$PubRemoveOptionsCopyWithImpl<$Res>
    implements _$PubRemoveOptionsCopyWith<$Res> {
  __$PubRemoveOptionsCopyWithImpl(this._self, this._then);

  final _PubRemoveOptions _self;
  final $Res Function(_PubRemoveOptions) _then;

/// Create a copy of PubRemoveOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? globalPubOptions = null,Object? offline = null,Object? dryRun = null,Object? precompile = null,}) {
  return _then(_PubRemoveOptions(
globalPubOptions: null == globalPubOptions ? _self.globalPubOptions : globalPubOptions // ignore: cast_nullable_to_non_nullable
as GlobalPubOptions,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,dryRun: null == dryRun ? _self.dryRun : dryRun // ignore: cast_nullable_to_non_nullable
as bool,precompile: null == precompile ? _self.precompile : precompile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PubRemoveOptions
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
