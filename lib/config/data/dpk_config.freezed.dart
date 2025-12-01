// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dpk_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DpkConfig {

 DpkMode get mode; Catalog? get catalog; List<String>? get workspace; bool get sortPubspec;
/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DpkConfigCopyWith<DpkConfig> get copyWith => _$DpkConfigCopyWithImpl<DpkConfig>(this as DpkConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DpkConfig&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.catalog, catalog) || other.catalog == catalog)&&const DeepCollectionEquality().equals(other.workspace, workspace)&&(identical(other.sortPubspec, sortPubspec) || other.sortPubspec == sortPubspec));
}


@override
int get hashCode => Object.hash(runtimeType,mode,catalog,const DeepCollectionEquality().hash(workspace),sortPubspec);

@override
String toString() {
  return 'DpkConfig(mode: $mode, catalog: $catalog, workspace: $workspace, sortPubspec: $sortPubspec)';
}


}

/// @nodoc
abstract mixin class $DpkConfigCopyWith<$Res>  {
  factory $DpkConfigCopyWith(DpkConfig value, $Res Function(DpkConfig) _then) = _$DpkConfigCopyWithImpl;
@useResult
$Res call({
 DpkMode mode, Catalog? catalog, List<String>? workspace, bool sortPubspec
});


$CatalogCopyWith<$Res>? get catalog;

}
/// @nodoc
class _$DpkConfigCopyWithImpl<$Res>
    implements $DpkConfigCopyWith<$Res> {
  _$DpkConfigCopyWithImpl(this._self, this._then);

  final DpkConfig _self;
  final $Res Function(DpkConfig) _then;

/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? catalog = freezed,Object? workspace = freezed,Object? sortPubspec = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DpkMode,catalog: freezed == catalog ? _self.catalog : catalog // ignore: cast_nullable_to_non_nullable
as Catalog?,workspace: freezed == workspace ? _self.workspace : workspace // ignore: cast_nullable_to_non_nullable
as List<String>?,sortPubspec: null == sortPubspec ? _self.sortPubspec : sortPubspec // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CatalogCopyWith<$Res>? get catalog {
    if (_self.catalog == null) {
    return null;
  }

  return $CatalogCopyWith<$Res>(_self.catalog!, (value) {
    return _then(_self.copyWith(catalog: value));
  });
}
}


/// Adds pattern-matching-related methods to [DpkConfig].
extension DpkConfigPatterns on DpkConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DpkConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DpkConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DpkConfig value)  $default,){
final _that = this;
switch (_that) {
case _DpkConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DpkConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DpkConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DpkMode mode,  Catalog? catalog,  List<String>? workspace,  bool sortPubspec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DpkConfig() when $default != null:
return $default(_that.mode,_that.catalog,_that.workspace,_that.sortPubspec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DpkMode mode,  Catalog? catalog,  List<String>? workspace,  bool sortPubspec)  $default,) {final _that = this;
switch (_that) {
case _DpkConfig():
return $default(_that.mode,_that.catalog,_that.workspace,_that.sortPubspec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DpkMode mode,  Catalog? catalog,  List<String>? workspace,  bool sortPubspec)?  $default,) {final _that = this;
switch (_that) {
case _DpkConfig() when $default != null:
return $default(_that.mode,_that.catalog,_that.workspace,_that.sortPubspec);case _:
  return null;

}
}

}

/// @nodoc


class _DpkConfig implements DpkConfig {
  const _DpkConfig({this.mode = DpkMode.global, this.catalog, final  List<String>? workspace, this.sortPubspec = false}): _workspace = workspace;
  

@override@JsonKey() final  DpkMode mode;
@override final  Catalog? catalog;
 final  List<String>? _workspace;
@override List<String>? get workspace {
  final value = _workspace;
  if (value == null) return null;
  if (_workspace is EqualUnmodifiableListView) return _workspace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool sortPubspec;

/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DpkConfigCopyWith<_DpkConfig> get copyWith => __$DpkConfigCopyWithImpl<_DpkConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DpkConfig&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.catalog, catalog) || other.catalog == catalog)&&const DeepCollectionEquality().equals(other._workspace, _workspace)&&(identical(other.sortPubspec, sortPubspec) || other.sortPubspec == sortPubspec));
}


@override
int get hashCode => Object.hash(runtimeType,mode,catalog,const DeepCollectionEquality().hash(_workspace),sortPubspec);

@override
String toString() {
  return 'DpkConfig(mode: $mode, catalog: $catalog, workspace: $workspace, sortPubspec: $sortPubspec)';
}


}

/// @nodoc
abstract mixin class _$DpkConfigCopyWith<$Res> implements $DpkConfigCopyWith<$Res> {
  factory _$DpkConfigCopyWith(_DpkConfig value, $Res Function(_DpkConfig) _then) = __$DpkConfigCopyWithImpl;
@override @useResult
$Res call({
 DpkMode mode, Catalog? catalog, List<String>? workspace, bool sortPubspec
});


@override $CatalogCopyWith<$Res>? get catalog;

}
/// @nodoc
class __$DpkConfigCopyWithImpl<$Res>
    implements _$DpkConfigCopyWith<$Res> {
  __$DpkConfigCopyWithImpl(this._self, this._then);

  final _DpkConfig _self;
  final $Res Function(_DpkConfig) _then;

/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? catalog = freezed,Object? workspace = freezed,Object? sortPubspec = null,}) {
  return _then(_DpkConfig(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DpkMode,catalog: freezed == catalog ? _self.catalog : catalog // ignore: cast_nullable_to_non_nullable
as Catalog?,workspace: freezed == workspace ? _self._workspace : workspace // ignore: cast_nullable_to_non_nullable
as List<String>?,sortPubspec: null == sortPubspec ? _self.sortPubspec : sortPubspec // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of DpkConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CatalogCopyWith<$Res>? get catalog {
    if (_self.catalog == null) {
    return null;
  }

  return $CatalogCopyWith<$Res>(_self.catalog!, (value) {
    return _then(_self.copyWith(catalog: value));
  });
}
}

// dart format on
