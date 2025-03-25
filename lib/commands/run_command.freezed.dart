// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RunOptions {

 GlobalOptions get globalOptions; String get script;
/// Create a copy of RunOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunOptionsCopyWith<RunOptions> get copyWith => _$RunOptionsCopyWithImpl<RunOptions>(this as RunOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunOptions&&(identical(other.globalOptions, globalOptions) || other.globalOptions == globalOptions)&&(identical(other.script, script) || other.script == script));
}


@override
int get hashCode => Object.hash(runtimeType,globalOptions,script);

@override
String toString() {
  return 'RunOptions(globalOptions: $globalOptions, script: $script)';
}


}

/// @nodoc
abstract mixin class $RunOptionsCopyWith<$Res>  {
  factory $RunOptionsCopyWith(RunOptions value, $Res Function(RunOptions) _then) = _$RunOptionsCopyWithImpl;
@useResult
$Res call({
 GlobalOptions globalOptions, String script
});


$GlobalOptionsCopyWith<$Res> get globalOptions;

}
/// @nodoc
class _$RunOptionsCopyWithImpl<$Res>
    implements $RunOptionsCopyWith<$Res> {
  _$RunOptionsCopyWithImpl(this._self, this._then);

  final RunOptions _self;
  final $Res Function(RunOptions) _then;

/// Create a copy of RunOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? globalOptions = null,Object? script = null,}) {
  return _then(_self.copyWith(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,script: null == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of RunOptions
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


class _RunOptions implements RunOptions {
  const _RunOptions({required this.globalOptions, required this.script});
  

@override final  GlobalOptions globalOptions;
@override final  String script;

/// Create a copy of RunOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunOptionsCopyWith<_RunOptions> get copyWith => __$RunOptionsCopyWithImpl<_RunOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunOptions&&(identical(other.globalOptions, globalOptions) || other.globalOptions == globalOptions)&&(identical(other.script, script) || other.script == script));
}


@override
int get hashCode => Object.hash(runtimeType,globalOptions,script);

@override
String toString() {
  return 'RunOptions(globalOptions: $globalOptions, script: $script)';
}


}

/// @nodoc
abstract mixin class _$RunOptionsCopyWith<$Res> implements $RunOptionsCopyWith<$Res> {
  factory _$RunOptionsCopyWith(_RunOptions value, $Res Function(_RunOptions) _then) = __$RunOptionsCopyWithImpl;
@override @useResult
$Res call({
 GlobalOptions globalOptions, String script
});


@override $GlobalOptionsCopyWith<$Res> get globalOptions;

}
/// @nodoc
class __$RunOptionsCopyWithImpl<$Res>
    implements _$RunOptionsCopyWith<$Res> {
  __$RunOptionsCopyWithImpl(this._self, this._then);

  final _RunOptions _self;
  final $Res Function(_RunOptions) _then;

/// Create a copy of RunOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? globalOptions = null,Object? script = null,}) {
  return _then(_RunOptions(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,script: null == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of RunOptions
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
