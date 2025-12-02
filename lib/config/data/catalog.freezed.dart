// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Catalog {

 Map<String, VersionConstraint?>? get environment; String? get publishTo; Uri? get repository; Uri? get issueTracker; List<String>? get topics; String? get documentation; String? get resolution; Map<String, Dependency>? get dependencies;
/// Create a copy of Catalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogCopyWith<Catalog> get copyWith => _$CatalogCopyWithImpl<Catalog>(this as Catalog, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Catalog&&const DeepCollectionEquality().equals(other.environment, environment)&&(identical(other.publishTo, publishTo) || other.publishTo == publishTo)&&(identical(other.repository, repository) || other.repository == repository)&&(identical(other.issueTracker, issueTracker) || other.issueTracker == issueTracker)&&const DeepCollectionEquality().equals(other.topics, topics)&&(identical(other.documentation, documentation) || other.documentation == documentation)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&const DeepCollectionEquality().equals(other.dependencies, dependencies));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(environment),publishTo,repository,issueTracker,const DeepCollectionEquality().hash(topics),documentation,resolution,const DeepCollectionEquality().hash(dependencies));

@override
String toString() {
  return 'Catalog(environment: $environment, publishTo: $publishTo, repository: $repository, issueTracker: $issueTracker, topics: $topics, documentation: $documentation, resolution: $resolution, dependencies: $dependencies)';
}


}

/// @nodoc
abstract mixin class $CatalogCopyWith<$Res>  {
  factory $CatalogCopyWith(Catalog value, $Res Function(Catalog) _then) = _$CatalogCopyWithImpl;
@useResult
$Res call({
 Map<String, VersionConstraint?>? environment, String? publishTo, Uri? repository, Uri? issueTracker, List<String>? topics, String? documentation, String? resolution, Map<String, Dependency>? dependencies
});




}
/// @nodoc
class _$CatalogCopyWithImpl<$Res>
    implements $CatalogCopyWith<$Res> {
  _$CatalogCopyWithImpl(this._self, this._then);

  final Catalog _self;
  final $Res Function(Catalog) _then;

/// Create a copy of Catalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? environment = freezed,Object? publishTo = freezed,Object? repository = freezed,Object? issueTracker = freezed,Object? topics = freezed,Object? documentation = freezed,Object? resolution = freezed,Object? dependencies = freezed,}) {
  return _then(_self.copyWith(
environment: freezed == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as Map<String, VersionConstraint?>?,publishTo: freezed == publishTo ? _self.publishTo : publishTo // ignore: cast_nullable_to_non_nullable
as String?,repository: freezed == repository ? _self.repository : repository // ignore: cast_nullable_to_non_nullable
as Uri?,issueTracker: freezed == issueTracker ? _self.issueTracker : issueTracker // ignore: cast_nullable_to_non_nullable
as Uri?,topics: freezed == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as List<String>?,documentation: freezed == documentation ? _self.documentation : documentation // ignore: cast_nullable_to_non_nullable
as String?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,dependencies: freezed == dependencies ? _self.dependencies : dependencies // ignore: cast_nullable_to_non_nullable
as Map<String, Dependency>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Catalog].
extension CatalogPatterns on Catalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Catalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Catalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Catalog value)  $default,){
final _that = this;
switch (_that) {
case _Catalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Catalog value)?  $default,){
final _that = this;
switch (_that) {
case _Catalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, VersionConstraint?>? environment,  String? publishTo,  Uri? repository,  Uri? issueTracker,  List<String>? topics,  String? documentation,  String? resolution,  Map<String, Dependency>? dependencies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Catalog() when $default != null:
return $default(_that.environment,_that.publishTo,_that.repository,_that.issueTracker,_that.topics,_that.documentation,_that.resolution,_that.dependencies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, VersionConstraint?>? environment,  String? publishTo,  Uri? repository,  Uri? issueTracker,  List<String>? topics,  String? documentation,  String? resolution,  Map<String, Dependency>? dependencies)  $default,) {final _that = this;
switch (_that) {
case _Catalog():
return $default(_that.environment,_that.publishTo,_that.repository,_that.issueTracker,_that.topics,_that.documentation,_that.resolution,_that.dependencies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, VersionConstraint?>? environment,  String? publishTo,  Uri? repository,  Uri? issueTracker,  List<String>? topics,  String? documentation,  String? resolution,  Map<String, Dependency>? dependencies)?  $default,) {final _that = this;
switch (_that) {
case _Catalog() when $default != null:
return $default(_that.environment,_that.publishTo,_that.repository,_that.issueTracker,_that.topics,_that.documentation,_that.resolution,_that.dependencies);case _:
  return null;

}
}

}

/// @nodoc


class _Catalog implements Catalog {
  const _Catalog({final  Map<String, VersionConstraint?>? environment, this.publishTo, this.repository, this.issueTracker, final  List<String>? topics, this.documentation, this.resolution, final  Map<String, Dependency>? dependencies}): _environment = environment,_topics = topics,_dependencies = dependencies;
  

 final  Map<String, VersionConstraint?>? _environment;
@override Map<String, VersionConstraint?>? get environment {
  final value = _environment;
  if (value == null) return null;
  if (_environment is EqualUnmodifiableMapView) return _environment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? publishTo;
@override final  Uri? repository;
@override final  Uri? issueTracker;
 final  List<String>? _topics;
@override List<String>? get topics {
  final value = _topics;
  if (value == null) return null;
  if (_topics is EqualUnmodifiableListView) return _topics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? documentation;
@override final  String? resolution;
 final  Map<String, Dependency>? _dependencies;
@override Map<String, Dependency>? get dependencies {
  final value = _dependencies;
  if (value == null) return null;
  if (_dependencies is EqualUnmodifiableMapView) return _dependencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of Catalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogCopyWith<_Catalog> get copyWith => __$CatalogCopyWithImpl<_Catalog>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Catalog&&const DeepCollectionEquality().equals(other._environment, _environment)&&(identical(other.publishTo, publishTo) || other.publishTo == publishTo)&&(identical(other.repository, repository) || other.repository == repository)&&(identical(other.issueTracker, issueTracker) || other.issueTracker == issueTracker)&&const DeepCollectionEquality().equals(other._topics, _topics)&&(identical(other.documentation, documentation) || other.documentation == documentation)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&const DeepCollectionEquality().equals(other._dependencies, _dependencies));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_environment),publishTo,repository,issueTracker,const DeepCollectionEquality().hash(_topics),documentation,resolution,const DeepCollectionEquality().hash(_dependencies));

@override
String toString() {
  return 'Catalog(environment: $environment, publishTo: $publishTo, repository: $repository, issueTracker: $issueTracker, topics: $topics, documentation: $documentation, resolution: $resolution, dependencies: $dependencies)';
}


}

/// @nodoc
abstract mixin class _$CatalogCopyWith<$Res> implements $CatalogCopyWith<$Res> {
  factory _$CatalogCopyWith(_Catalog value, $Res Function(_Catalog) _then) = __$CatalogCopyWithImpl;
@override @useResult
$Res call({
 Map<String, VersionConstraint?>? environment, String? publishTo, Uri? repository, Uri? issueTracker, List<String>? topics, String? documentation, String? resolution, Map<String, Dependency>? dependencies
});




}
/// @nodoc
class __$CatalogCopyWithImpl<$Res>
    implements _$CatalogCopyWith<$Res> {
  __$CatalogCopyWithImpl(this._self, this._then);

  final _Catalog _self;
  final $Res Function(_Catalog) _then;

/// Create a copy of Catalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? environment = freezed,Object? publishTo = freezed,Object? repository = freezed,Object? issueTracker = freezed,Object? topics = freezed,Object? documentation = freezed,Object? resolution = freezed,Object? dependencies = freezed,}) {
  return _then(_Catalog(
environment: freezed == environment ? _self._environment : environment // ignore: cast_nullable_to_non_nullable
as Map<String, VersionConstraint?>?,publishTo: freezed == publishTo ? _self.publishTo : publishTo // ignore: cast_nullable_to_non_nullable
as String?,repository: freezed == repository ? _self.repository : repository // ignore: cast_nullable_to_non_nullable
as Uri?,issueTracker: freezed == issueTracker ? _self.issueTracker : issueTracker // ignore: cast_nullable_to_non_nullable
as Uri?,topics: freezed == topics ? _self._topics : topics // ignore: cast_nullable_to_non_nullable
as List<String>?,documentation: freezed == documentation ? _self.documentation : documentation // ignore: cast_nullable_to_non_nullable
as String?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,dependencies: freezed == dependencies ? _self._dependencies : dependencies // ignore: cast_nullable_to_non_nullable
as Map<String, Dependency>?,
  ));
}


}

// dart format on
