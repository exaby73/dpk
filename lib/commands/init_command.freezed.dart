// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'init_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InitOptions {

 GlobalOptions get globalOptions; String get mode; String get versionConstraint; bool get force;
/// Create a copy of InitOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitOptionsCopyWith<InitOptions> get copyWith => _$InitOptionsCopyWithImpl<InitOptions>(this as InitOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitOptions&&(identical(other.globalOptions, globalOptions) || other.globalOptions == globalOptions)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.versionConstraint, versionConstraint) || other.versionConstraint == versionConstraint)&&(identical(other.force, force) || other.force == force));
}


@override
int get hashCode => Object.hash(runtimeType,globalOptions,mode,versionConstraint,force);

@override
String toString() {
  return 'InitOptions(globalOptions: $globalOptions, mode: $mode, versionConstraint: $versionConstraint, force: $force)';
}


}

/// @nodoc
abstract mixin class $InitOptionsCopyWith<$Res>  {
  factory $InitOptionsCopyWith(InitOptions value, $Res Function(InitOptions) _then) = _$InitOptionsCopyWithImpl;
@useResult
$Res call({
 GlobalOptions globalOptions, String mode, String versionConstraint, bool force
});


$GlobalOptionsCopyWith<$Res> get globalOptions;

}
/// @nodoc
class _$InitOptionsCopyWithImpl<$Res>
    implements $InitOptionsCopyWith<$Res> {
  _$InitOptionsCopyWithImpl(this._self, this._then);

  final InitOptions _self;
  final $Res Function(InitOptions) _then;

/// Create a copy of InitOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? globalOptions = null,Object? mode = null,Object? versionConstraint = null,Object? force = null,}) {
  return _then(_self.copyWith(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,versionConstraint: null == versionConstraint ? _self.versionConstraint : versionConstraint // ignore: cast_nullable_to_non_nullable
as String,force: null == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of InitOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalOptionsCopyWith<$Res> get globalOptions {
  
  return $GlobalOptionsCopyWith<$Res>(_self.globalOptions, (value) {
    return _then(_self.copyWith(globalOptions: value));
  });
}
}


/// Adds pattern-matching-related methods to [InitOptions].
extension InitOptionsPatterns on InitOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitOptions value)  $default,){
final _that = this;
switch (_that) {
case _InitOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitOptions value)?  $default,){
final _that = this;
switch (_that) {
case _InitOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GlobalOptions globalOptions,  String mode,  String versionConstraint,  bool force)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitOptions() when $default != null:
return $default(_that.globalOptions,_that.mode,_that.versionConstraint,_that.force);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GlobalOptions globalOptions,  String mode,  String versionConstraint,  bool force)  $default,) {final _that = this;
switch (_that) {
case _InitOptions():
return $default(_that.globalOptions,_that.mode,_that.versionConstraint,_that.force);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GlobalOptions globalOptions,  String mode,  String versionConstraint,  bool force)?  $default,) {final _that = this;
switch (_that) {
case _InitOptions() when $default != null:
return $default(_that.globalOptions,_that.mode,_that.versionConstraint,_that.force);case _:
  return null;

}
}

}

/// @nodoc


class _InitOptions implements InitOptions {
  const _InitOptions({required this.globalOptions, required this.mode, required this.versionConstraint, required this.force});
  

@override final  GlobalOptions globalOptions;
@override final  String mode;
@override final  String versionConstraint;
@override final  bool force;

/// Create a copy of InitOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitOptionsCopyWith<_InitOptions> get copyWith => __$InitOptionsCopyWithImpl<_InitOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitOptions&&(identical(other.globalOptions, globalOptions) || other.globalOptions == globalOptions)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.versionConstraint, versionConstraint) || other.versionConstraint == versionConstraint)&&(identical(other.force, force) || other.force == force));
}


@override
int get hashCode => Object.hash(runtimeType,globalOptions,mode,versionConstraint,force);

@override
String toString() {
  return 'InitOptions(globalOptions: $globalOptions, mode: $mode, versionConstraint: $versionConstraint, force: $force)';
}


}

/// @nodoc
abstract mixin class _$InitOptionsCopyWith<$Res> implements $InitOptionsCopyWith<$Res> {
  factory _$InitOptionsCopyWith(_InitOptions value, $Res Function(_InitOptions) _then) = __$InitOptionsCopyWithImpl;
@override @useResult
$Res call({
 GlobalOptions globalOptions, String mode, String versionConstraint, bool force
});


@override $GlobalOptionsCopyWith<$Res> get globalOptions;

}
/// @nodoc
class __$InitOptionsCopyWithImpl<$Res>
    implements _$InitOptionsCopyWith<$Res> {
  __$InitOptionsCopyWithImpl(this._self, this._then);

  final _InitOptions _self;
  final $Res Function(_InitOptions) _then;

/// Create a copy of InitOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? globalOptions = null,Object? mode = null,Object? versionConstraint = null,Object? force = null,}) {
  return _then(_InitOptions(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,versionConstraint: null == versionConstraint ? _self.versionConstraint : versionConstraint // ignore: cast_nullable_to_non_nullable
as String,force: null == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of InitOptions
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
