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
mixin _$PatchOptions {

 GlobalPatchOptions get globalPatchOptions; bool get force;
/// Create a copy of PatchOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatchOptionsCopyWith<PatchOptions> get copyWith => _$PatchOptionsCopyWithImpl<PatchOptions>(this as PatchOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatchOptions&&(identical(other.globalPatchOptions, globalPatchOptions) || other.globalPatchOptions == globalPatchOptions)&&(identical(other.force, force) || other.force == force));
}


@override
int get hashCode => Object.hash(runtimeType,globalPatchOptions,force);

@override
String toString() {
  return 'PatchOptions(globalPatchOptions: $globalPatchOptions, force: $force)';
}


}

/// @nodoc
abstract mixin class $PatchOptionsCopyWith<$Res>  {
  factory $PatchOptionsCopyWith(PatchOptions value, $Res Function(PatchOptions) _then) = _$PatchOptionsCopyWithImpl;
@useResult
$Res call({
 GlobalPatchOptions globalPatchOptions, bool force
});


$GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions;

}
/// @nodoc
class _$PatchOptionsCopyWithImpl<$Res>
    implements $PatchOptionsCopyWith<$Res> {
  _$PatchOptionsCopyWithImpl(this._self, this._then);

  final PatchOptions _self;
  final $Res Function(PatchOptions) _then;

/// Create a copy of PatchOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? globalPatchOptions = null,Object? force = null,}) {
  return _then(_self.copyWith(
globalPatchOptions: null == globalPatchOptions ? _self.globalPatchOptions : globalPatchOptions // ignore: cast_nullable_to_non_nullable
as GlobalPatchOptions,force: null == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PatchOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions {
  
  return $GlobalPatchOptionsCopyWith<$Res>(_self.globalPatchOptions, (value) {
    return _then(_self.copyWith(globalPatchOptions: value));
  });
}
}


/// Adds pattern-matching-related methods to [PatchOptions].
extension PatchOptionsPatterns on PatchOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatchOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatchOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatchOptions value)  $default,){
final _that = this;
switch (_that) {
case _PatchOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatchOptions value)?  $default,){
final _that = this;
switch (_that) {
case _PatchOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GlobalPatchOptions globalPatchOptions,  bool force)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatchOptions() when $default != null:
return $default(_that.globalPatchOptions,_that.force);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GlobalPatchOptions globalPatchOptions,  bool force)  $default,) {final _that = this;
switch (_that) {
case _PatchOptions():
return $default(_that.globalPatchOptions,_that.force);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GlobalPatchOptions globalPatchOptions,  bool force)?  $default,) {final _that = this;
switch (_that) {
case _PatchOptions() when $default != null:
return $default(_that.globalPatchOptions,_that.force);case _:
  return null;

}
}

}

/// @nodoc


class _PatchOptions implements PatchOptions {
  const _PatchOptions({required this.globalPatchOptions, required this.force});
  

@override final  GlobalPatchOptions globalPatchOptions;
@override final  bool force;

/// Create a copy of PatchOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatchOptionsCopyWith<_PatchOptions> get copyWith => __$PatchOptionsCopyWithImpl<_PatchOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatchOptions&&(identical(other.globalPatchOptions, globalPatchOptions) || other.globalPatchOptions == globalPatchOptions)&&(identical(other.force, force) || other.force == force));
}


@override
int get hashCode => Object.hash(runtimeType,globalPatchOptions,force);

@override
String toString() {
  return 'PatchOptions(globalPatchOptions: $globalPatchOptions, force: $force)';
}


}

/// @nodoc
abstract mixin class _$PatchOptionsCopyWith<$Res> implements $PatchOptionsCopyWith<$Res> {
  factory _$PatchOptionsCopyWith(_PatchOptions value, $Res Function(_PatchOptions) _then) = __$PatchOptionsCopyWithImpl;
@override @useResult
$Res call({
 GlobalPatchOptions globalPatchOptions, bool force
});


@override $GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions;

}
/// @nodoc
class __$PatchOptionsCopyWithImpl<$Res>
    implements _$PatchOptionsCopyWith<$Res> {
  __$PatchOptionsCopyWithImpl(this._self, this._then);

  final _PatchOptions _self;
  final $Res Function(_PatchOptions) _then;

/// Create a copy of PatchOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? globalPatchOptions = null,Object? force = null,}) {
  return _then(_PatchOptions(
globalPatchOptions: null == globalPatchOptions ? _self.globalPatchOptions : globalPatchOptions // ignore: cast_nullable_to_non_nullable
as GlobalPatchOptions,force: null == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PatchOptions
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
