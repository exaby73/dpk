// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_patch_args.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GlobalPatchOptions {

 GlobalOptions get globalOptions; String get cacheDir; String get patchDir;
/// Create a copy of GlobalPatchOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GlobalPatchOptionsCopyWith<GlobalPatchOptions> get copyWith => _$GlobalPatchOptionsCopyWithImpl<GlobalPatchOptions>(this as GlobalPatchOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GlobalPatchOptions&&(identical(other.globalOptions, globalOptions) || other.globalOptions == globalOptions)&&(identical(other.cacheDir, cacheDir) || other.cacheDir == cacheDir)&&(identical(other.patchDir, patchDir) || other.patchDir == patchDir));
}


@override
int get hashCode => Object.hash(runtimeType,globalOptions,cacheDir,patchDir);

@override
String toString() {
  return 'GlobalPatchOptions(globalOptions: $globalOptions, cacheDir: $cacheDir, patchDir: $patchDir)';
}


}

/// @nodoc
abstract mixin class $GlobalPatchOptionsCopyWith<$Res>  {
  factory $GlobalPatchOptionsCopyWith(GlobalPatchOptions value, $Res Function(GlobalPatchOptions) _then) = _$GlobalPatchOptionsCopyWithImpl;
@useResult
$Res call({
 GlobalOptions globalOptions, String cacheDir, String patchDir
});


$GlobalOptionsCopyWith<$Res> get globalOptions;

}
/// @nodoc
class _$GlobalPatchOptionsCopyWithImpl<$Res>
    implements $GlobalPatchOptionsCopyWith<$Res> {
  _$GlobalPatchOptionsCopyWithImpl(this._self, this._then);

  final GlobalPatchOptions _self;
  final $Res Function(GlobalPatchOptions) _then;

/// Create a copy of GlobalPatchOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? globalOptions = null,Object? cacheDir = null,Object? patchDir = null,}) {
  return _then(_self.copyWith(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,cacheDir: null == cacheDir ? _self.cacheDir : cacheDir // ignore: cast_nullable_to_non_nullable
as String,patchDir: null == patchDir ? _self.patchDir : patchDir // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of GlobalPatchOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalOptionsCopyWith<$Res> get globalOptions {
  
  return $GlobalOptionsCopyWith<$Res>(_self.globalOptions, (value) {
    return _then(_self.copyWith(globalOptions: value));
  });
}
}


/// @nodoc


class _GlobalPatchOptions implements GlobalPatchOptions {
  const _GlobalPatchOptions({required this.globalOptions, required this.cacheDir, required this.patchDir});
  

@override final  GlobalOptions globalOptions;
@override final  String cacheDir;
@override final  String patchDir;

/// Create a copy of GlobalPatchOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GlobalPatchOptionsCopyWith<_GlobalPatchOptions> get copyWith => __$GlobalPatchOptionsCopyWithImpl<_GlobalPatchOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GlobalPatchOptions&&(identical(other.globalOptions, globalOptions) || other.globalOptions == globalOptions)&&(identical(other.cacheDir, cacheDir) || other.cacheDir == cacheDir)&&(identical(other.patchDir, patchDir) || other.patchDir == patchDir));
}


@override
int get hashCode => Object.hash(runtimeType,globalOptions,cacheDir,patchDir);

@override
String toString() {
  return 'GlobalPatchOptions._internal(globalOptions: $globalOptions, cacheDir: $cacheDir, patchDir: $patchDir)';
}


}

/// @nodoc
abstract mixin class _$GlobalPatchOptionsCopyWith<$Res> implements $GlobalPatchOptionsCopyWith<$Res> {
  factory _$GlobalPatchOptionsCopyWith(_GlobalPatchOptions value, $Res Function(_GlobalPatchOptions) _then) = __$GlobalPatchOptionsCopyWithImpl;
@override @useResult
$Res call({
 GlobalOptions globalOptions, String cacheDir, String patchDir
});


@override $GlobalOptionsCopyWith<$Res> get globalOptions;

}
/// @nodoc
class __$GlobalPatchOptionsCopyWithImpl<$Res>
    implements _$GlobalPatchOptionsCopyWith<$Res> {
  __$GlobalPatchOptionsCopyWithImpl(this._self, this._then);

  final _GlobalPatchOptions _self;
  final $Res Function(_GlobalPatchOptions) _then;

/// Create a copy of GlobalPatchOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? globalOptions = null,Object? cacheDir = null,Object? patchDir = null,}) {
  return _then(_GlobalPatchOptions(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,cacheDir: null == cacheDir ? _self.cacheDir : cacheDir // ignore: cast_nullable_to_non_nullable
as String,patchDir: null == patchDir ? _self.patchDir : patchDir // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of GlobalPatchOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalOptionsCopyWith<$Res> get globalOptions {
  
  return $GlobalOptionsCopyWith<$Res>(_self.globalOptions, (value) {
    return _then(_self.copyWith(globalOptions: value));
  });
}
}

// dart format on
