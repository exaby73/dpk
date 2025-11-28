// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
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

 GlobalOptions get globalOptions; set globalOptions(GlobalOptions value); String? get script; set script(String? value);
/// Create a copy of RunOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunOptionsCopyWith<RunOptions> get copyWith => _$RunOptionsCopyWithImpl<RunOptions>(this as RunOptions, _$identity);





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
 GlobalOptions globalOptions, String? script
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
@pragma('vm:prefer-inline') @override $Res call({Object? globalOptions = null,Object? script = freezed,}) {
  return _then(_self.copyWith(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,script: freezed == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as String?,
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


/// Adds pattern-matching-related methods to [RunOptions].
extension RunOptionsPatterns on RunOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunOptions value)  $default,){
final _that = this;
switch (_that) {
case _RunOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunOptions value)?  $default,){
final _that = this;
switch (_that) {
case _RunOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GlobalOptions globalOptions,  String? script)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunOptions() when $default != null:
return $default(_that.globalOptions,_that.script);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GlobalOptions globalOptions,  String? script)  $default,) {final _that = this;
switch (_that) {
case _RunOptions():
return $default(_that.globalOptions,_that.script);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GlobalOptions globalOptions,  String? script)?  $default,) {final _that = this;
switch (_that) {
case _RunOptions() when $default != null:
return $default(_that.globalOptions,_that.script);case _:
  return null;

}
}

}

/// @nodoc


class _RunOptions implements RunOptions {
   _RunOptions({required this.globalOptions, required this.script});
  

@override  GlobalOptions globalOptions;
@override  String? script;

/// Create a copy of RunOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunOptionsCopyWith<_RunOptions> get copyWith => __$RunOptionsCopyWithImpl<_RunOptions>(this, _$identity);





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
 GlobalOptions globalOptions, String? script
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
@override @pragma('vm:prefer-inline') $Res call({Object? globalOptions = null,Object? script = freezed,}) {
  return _then(_RunOptions(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,script: freezed == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as String?,
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
