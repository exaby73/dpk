// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PubGetOptions {

 GlobalPubOptions get globalPubOptions; bool get offline; bool get dryRun; bool get enforceLockfile; bool get precompile;
/// Create a copy of PubGetOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PubGetOptionsCopyWith<PubGetOptions> get copyWith => _$PubGetOptionsCopyWithImpl<PubGetOptions>(this as PubGetOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PubGetOptions&&(identical(other.globalPubOptions, globalPubOptions) || other.globalPubOptions == globalPubOptions)&&(identical(other.offline, offline) || other.offline == offline)&&(identical(other.dryRun, dryRun) || other.dryRun == dryRun)&&(identical(other.enforceLockfile, enforceLockfile) || other.enforceLockfile == enforceLockfile)&&(identical(other.precompile, precompile) || other.precompile == precompile));
}


@override
int get hashCode => Object.hash(runtimeType,globalPubOptions,offline,dryRun,enforceLockfile,precompile);

@override
String toString() {
  return 'PubGetOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, enforceLockfile: $enforceLockfile, precompile: $precompile)';
}


}

/// @nodoc
abstract mixin class $PubGetOptionsCopyWith<$Res>  {
  factory $PubGetOptionsCopyWith(PubGetOptions value, $Res Function(PubGetOptions) _then) = _$PubGetOptionsCopyWithImpl;
@useResult
$Res call({
 GlobalPubOptions globalPubOptions, bool offline, bool dryRun, bool enforceLockfile, bool precompile
});


$GlobalPubOptionsCopyWith<$Res> get globalPubOptions;

}
/// @nodoc
class _$PubGetOptionsCopyWithImpl<$Res>
    implements $PubGetOptionsCopyWith<$Res> {
  _$PubGetOptionsCopyWithImpl(this._self, this._then);

  final PubGetOptions _self;
  final $Res Function(PubGetOptions) _then;

/// Create a copy of PubGetOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? globalPubOptions = null,Object? offline = null,Object? dryRun = null,Object? enforceLockfile = null,Object? precompile = null,}) {
  return _then(_self.copyWith(
globalPubOptions: null == globalPubOptions ? _self.globalPubOptions : globalPubOptions // ignore: cast_nullable_to_non_nullable
as GlobalPubOptions,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,dryRun: null == dryRun ? _self.dryRun : dryRun // ignore: cast_nullable_to_non_nullable
as bool,enforceLockfile: null == enforceLockfile ? _self.enforceLockfile : enforceLockfile // ignore: cast_nullable_to_non_nullable
as bool,precompile: null == precompile ? _self.precompile : precompile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PubGetOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalPubOptionsCopyWith<$Res> get globalPubOptions {
  
  return $GlobalPubOptionsCopyWith<$Res>(_self.globalPubOptions, (value) {
    return _then(_self.copyWith(globalPubOptions: value));
  });
}
}


/// Adds pattern-matching-related methods to [PubGetOptions].
extension PubGetOptionsPatterns on PubGetOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PubGetOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PubGetOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PubGetOptions value)  $default,){
final _that = this;
switch (_that) {
case _PubGetOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PubGetOptions value)?  $default,){
final _that = this;
switch (_that) {
case _PubGetOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GlobalPubOptions globalPubOptions,  bool offline,  bool dryRun,  bool enforceLockfile,  bool precompile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PubGetOptions() when $default != null:
return $default(_that.globalPubOptions,_that.offline,_that.dryRun,_that.enforceLockfile,_that.precompile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GlobalPubOptions globalPubOptions,  bool offline,  bool dryRun,  bool enforceLockfile,  bool precompile)  $default,) {final _that = this;
switch (_that) {
case _PubGetOptions():
return $default(_that.globalPubOptions,_that.offline,_that.dryRun,_that.enforceLockfile,_that.precompile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GlobalPubOptions globalPubOptions,  bool offline,  bool dryRun,  bool enforceLockfile,  bool precompile)?  $default,) {final _that = this;
switch (_that) {
case _PubGetOptions() when $default != null:
return $default(_that.globalPubOptions,_that.offline,_that.dryRun,_that.enforceLockfile,_that.precompile);case _:
  return null;

}
}

}

/// @nodoc


class _PubGetOptions implements PubGetOptions {
  const _PubGetOptions({required this.globalPubOptions, required this.offline, required this.dryRun, required this.enforceLockfile, required this.precompile});
  

@override final  GlobalPubOptions globalPubOptions;
@override final  bool offline;
@override final  bool dryRun;
@override final  bool enforceLockfile;
@override final  bool precompile;

/// Create a copy of PubGetOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PubGetOptionsCopyWith<_PubGetOptions> get copyWith => __$PubGetOptionsCopyWithImpl<_PubGetOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PubGetOptions&&(identical(other.globalPubOptions, globalPubOptions) || other.globalPubOptions == globalPubOptions)&&(identical(other.offline, offline) || other.offline == offline)&&(identical(other.dryRun, dryRun) || other.dryRun == dryRun)&&(identical(other.enforceLockfile, enforceLockfile) || other.enforceLockfile == enforceLockfile)&&(identical(other.precompile, precompile) || other.precompile == precompile));
}


@override
int get hashCode => Object.hash(runtimeType,globalPubOptions,offline,dryRun,enforceLockfile,precompile);

@override
String toString() {
  return 'PubGetOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, enforceLockfile: $enforceLockfile, precompile: $precompile)';
}


}

/// @nodoc
abstract mixin class _$PubGetOptionsCopyWith<$Res> implements $PubGetOptionsCopyWith<$Res> {
  factory _$PubGetOptionsCopyWith(_PubGetOptions value, $Res Function(_PubGetOptions) _then) = __$PubGetOptionsCopyWithImpl;
@override @useResult
$Res call({
 GlobalPubOptions globalPubOptions, bool offline, bool dryRun, bool enforceLockfile, bool precompile
});


@override $GlobalPubOptionsCopyWith<$Res> get globalPubOptions;

}
/// @nodoc
class __$PubGetOptionsCopyWithImpl<$Res>
    implements _$PubGetOptionsCopyWith<$Res> {
  __$PubGetOptionsCopyWithImpl(this._self, this._then);

  final _PubGetOptions _self;
  final $Res Function(_PubGetOptions) _then;

/// Create a copy of PubGetOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? globalPubOptions = null,Object? offline = null,Object? dryRun = null,Object? enforceLockfile = null,Object? precompile = null,}) {
  return _then(_PubGetOptions(
globalPubOptions: null == globalPubOptions ? _self.globalPubOptions : globalPubOptions // ignore: cast_nullable_to_non_nullable
as GlobalPubOptions,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,dryRun: null == dryRun ? _self.dryRun : dryRun // ignore: cast_nullable_to_non_nullable
as bool,enforceLockfile: null == enforceLockfile ? _self.enforceLockfile : enforceLockfile // ignore: cast_nullable_to_non_nullable
as bool,precompile: null == precompile ? _self.precompile : precompile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PubGetOptions
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
