// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_pub_args.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GlobalPubOptions {

 GlobalOptions get globalOptions; String get cacheDir; bool? get color;
/// Create a copy of GlobalPubOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GlobalPubOptionsCopyWith<GlobalPubOptions> get copyWith => _$GlobalPubOptionsCopyWithImpl<GlobalPubOptions>(this as GlobalPubOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GlobalPubOptions&&(identical(other.globalOptions, globalOptions) || other.globalOptions == globalOptions)&&(identical(other.cacheDir, cacheDir) || other.cacheDir == cacheDir)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,globalOptions,cacheDir,color);

@override
String toString() {
  return 'GlobalPubOptions(globalOptions: $globalOptions, cacheDir: $cacheDir, color: $color)';
}


}

/// @nodoc
abstract mixin class $GlobalPubOptionsCopyWith<$Res>  {
  factory $GlobalPubOptionsCopyWith(GlobalPubOptions value, $Res Function(GlobalPubOptions) _then) = _$GlobalPubOptionsCopyWithImpl;
@useResult
$Res call({
 GlobalOptions globalOptions, String cacheDir, bool? color
});


$GlobalOptionsCopyWith<$Res> get globalOptions;

}
/// @nodoc
class _$GlobalPubOptionsCopyWithImpl<$Res>
    implements $GlobalPubOptionsCopyWith<$Res> {
  _$GlobalPubOptionsCopyWithImpl(this._self, this._then);

  final GlobalPubOptions _self;
  final $Res Function(GlobalPubOptions) _then;

/// Create a copy of GlobalPubOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? globalOptions = null,Object? cacheDir = null,Object? color = freezed,}) {
  return _then(_self.copyWith(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,cacheDir: null == cacheDir ? _self.cacheDir : cacheDir // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of GlobalPubOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalOptionsCopyWith<$Res> get globalOptions {
  
  return $GlobalOptionsCopyWith<$Res>(_self.globalOptions, (value) {
    return _then(_self.copyWith(globalOptions: value));
  });
}
}


/// Adds pattern-matching-related methods to [GlobalPubOptions].
extension GlobalPubOptionsPatterns on GlobalPubOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GlobalPubOptions value)?  internal,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GlobalPubOptions() when internal != null:
return internal(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GlobalPubOptions value)  internal,}){
final _that = this;
switch (_that) {
case _GlobalPubOptions():
return internal(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GlobalPubOptions value)?  internal,}){
final _that = this;
switch (_that) {
case _GlobalPubOptions() when internal != null:
return internal(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( GlobalOptions globalOptions,  String cacheDir,  bool? color)?  internal,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GlobalPubOptions() when internal != null:
return internal(_that.globalOptions,_that.cacheDir,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( GlobalOptions globalOptions,  String cacheDir,  bool? color)  internal,}) {final _that = this;
switch (_that) {
case _GlobalPubOptions():
return internal(_that.globalOptions,_that.cacheDir,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( GlobalOptions globalOptions,  String cacheDir,  bool? color)?  internal,}) {final _that = this;
switch (_that) {
case _GlobalPubOptions() when internal != null:
return internal(_that.globalOptions,_that.cacheDir,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _GlobalPubOptions extends GlobalPubOptions {
  const _GlobalPubOptions({required this.globalOptions, required this.cacheDir, required this.color}): super._();
  

@override final  GlobalOptions globalOptions;
@override final  String cacheDir;
@override final  bool? color;

/// Create a copy of GlobalPubOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GlobalPubOptionsCopyWith<_GlobalPubOptions> get copyWith => __$GlobalPubOptionsCopyWithImpl<_GlobalPubOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GlobalPubOptions&&(identical(other.globalOptions, globalOptions) || other.globalOptions == globalOptions)&&(identical(other.cacheDir, cacheDir) || other.cacheDir == cacheDir)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,globalOptions,cacheDir,color);

@override
String toString() {
  return 'GlobalPubOptions.internal(globalOptions: $globalOptions, cacheDir: $cacheDir, color: $color)';
}


}

/// @nodoc
abstract mixin class _$GlobalPubOptionsCopyWith<$Res> implements $GlobalPubOptionsCopyWith<$Res> {
  factory _$GlobalPubOptionsCopyWith(_GlobalPubOptions value, $Res Function(_GlobalPubOptions) _then) = __$GlobalPubOptionsCopyWithImpl;
@override @useResult
$Res call({
 GlobalOptions globalOptions, String cacheDir, bool? color
});


@override $GlobalOptionsCopyWith<$Res> get globalOptions;

}
/// @nodoc
class __$GlobalPubOptionsCopyWithImpl<$Res>
    implements _$GlobalPubOptionsCopyWith<$Res> {
  __$GlobalPubOptionsCopyWithImpl(this._self, this._then);

  final _GlobalPubOptions _self;
  final $Res Function(_GlobalPubOptions) _then;

/// Create a copy of GlobalPubOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? globalOptions = null,Object? cacheDir = null,Object? color = freezed,}) {
  return _then(_GlobalPubOptions(
globalOptions: null == globalOptions ? _self.globalOptions : globalOptions // ignore: cast_nullable_to_non_nullable
as GlobalOptions,cacheDir: null == cacheDir ? _self.cacheDir : cacheDir // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of GlobalPubOptions
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
