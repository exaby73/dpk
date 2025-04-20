// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catelog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Catelog {
  Map<String, VersionConstraint?>? get environment;
  String? get publishTo;
  Uri? get repository;
  Uri? get issueTracker;
  List<String>? get topics;
  String? get documentation;
  String? get resolution;
  Map<String, Dependency>? get dependencies;
  Map<String, Dependency>? get devDependencies;
  Map<String, Dependency>? get dependencyOverrides;

  /// Create a copy of Catelog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CatelogCopyWith<Catelog> get copyWith =>
      _$CatelogCopyWithImpl<Catelog>(this as Catelog, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Catelog &&
            const DeepCollectionEquality()
                .equals(other.environment, environment) &&
            (identical(other.publishTo, publishTo) ||
                other.publishTo == publishTo) &&
            (identical(other.repository, repository) ||
                other.repository == repository) &&
            (identical(other.issueTracker, issueTracker) ||
                other.issueTracker == issueTracker) &&
            const DeepCollectionEquality().equals(other.topics, topics) &&
            (identical(other.documentation, documentation) ||
                other.documentation == documentation) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            const DeepCollectionEquality()
                .equals(other.dependencies, dependencies) &&
            const DeepCollectionEquality()
                .equals(other.devDependencies, devDependencies) &&
            const DeepCollectionEquality()
                .equals(other.dependencyOverrides, dependencyOverrides));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(environment),
      publishTo,
      repository,
      issueTracker,
      const DeepCollectionEquality().hash(topics),
      documentation,
      resolution,
      const DeepCollectionEquality().hash(dependencies),
      const DeepCollectionEquality().hash(devDependencies),
      const DeepCollectionEquality().hash(dependencyOverrides));

  @override
  String toString() {
    return 'Catelog(environment: $environment, publishTo: $publishTo, repository: $repository, issueTracker: $issueTracker, topics: $topics, documentation: $documentation, resolution: $resolution, dependencies: $dependencies, devDependencies: $devDependencies, dependencyOverrides: $dependencyOverrides)';
  }
}

/// @nodoc
abstract mixin class $CatelogCopyWith<$Res> {
  factory $CatelogCopyWith(Catelog value, $Res Function(Catelog) _then) =
      _$CatelogCopyWithImpl;
  @useResult
  $Res call(
      {Map<String, VersionConstraint?>? environment,
      String? publishTo,
      Uri? repository,
      Uri? issueTracker,
      List<String>? topics,
      String? documentation,
      String? resolution,
      Map<String, Dependency>? dependencies,
      Map<String, Dependency>? devDependencies,
      Map<String, Dependency>? dependencyOverrides});
}

/// @nodoc
class _$CatelogCopyWithImpl<$Res> implements $CatelogCopyWith<$Res> {
  _$CatelogCopyWithImpl(this._self, this._then);

  final Catelog _self;
  final $Res Function(Catelog) _then;

  /// Create a copy of Catelog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? environment = freezed,
    Object? publishTo = freezed,
    Object? repository = freezed,
    Object? issueTracker = freezed,
    Object? topics = freezed,
    Object? documentation = freezed,
    Object? resolution = freezed,
    Object? dependencies = freezed,
    Object? devDependencies = freezed,
    Object? dependencyOverrides = freezed,
  }) {
    return _then(_self.copyWith(
      environment: freezed == environment
          ? _self.environment
          : environment // ignore: cast_nullable_to_non_nullable
              as Map<String, VersionConstraint?>?,
      publishTo: freezed == publishTo
          ? _self.publishTo
          : publishTo // ignore: cast_nullable_to_non_nullable
              as String?,
      repository: freezed == repository
          ? _self.repository
          : repository // ignore: cast_nullable_to_non_nullable
              as Uri?,
      issueTracker: freezed == issueTracker
          ? _self.issueTracker
          : issueTracker // ignore: cast_nullable_to_non_nullable
              as Uri?,
      topics: freezed == topics
          ? _self.topics
          : topics // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      documentation: freezed == documentation
          ? _self.documentation
          : documentation // ignore: cast_nullable_to_non_nullable
              as String?,
      resolution: freezed == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      dependencies: freezed == dependencies
          ? _self.dependencies
          : dependencies // ignore: cast_nullable_to_non_nullable
              as Map<String, Dependency>?,
      devDependencies: freezed == devDependencies
          ? _self.devDependencies
          : devDependencies // ignore: cast_nullable_to_non_nullable
              as Map<String, Dependency>?,
      dependencyOverrides: freezed == dependencyOverrides
          ? _self.dependencyOverrides
          : dependencyOverrides // ignore: cast_nullable_to_non_nullable
              as Map<String, Dependency>?,
    ));
  }
}

/// @nodoc

class _Catelog implements Catelog {
  const _Catelog(
      {final Map<String, VersionConstraint?>? environment,
      this.publishTo,
      this.repository,
      this.issueTracker,
      final List<String>? topics,
      this.documentation,
      this.resolution,
      final Map<String, Dependency>? dependencies,
      final Map<String, Dependency>? devDependencies,
      final Map<String, Dependency>? dependencyOverrides})
      : _environment = environment,
        _topics = topics,
        _dependencies = dependencies,
        _devDependencies = devDependencies,
        _dependencyOverrides = dependencyOverrides;

  final Map<String, VersionConstraint?>? _environment;
  @override
  Map<String, VersionConstraint?>? get environment {
    final value = _environment;
    if (value == null) return null;
    if (_environment is EqualUnmodifiableMapView) return _environment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? publishTo;
  @override
  final Uri? repository;
  @override
  final Uri? issueTracker;
  final List<String>? _topics;
  @override
  List<String>? get topics {
    final value = _topics;
    if (value == null) return null;
    if (_topics is EqualUnmodifiableListView) return _topics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? documentation;
  @override
  final String? resolution;
  final Map<String, Dependency>? _dependencies;
  @override
  Map<String, Dependency>? get dependencies {
    final value = _dependencies;
    if (value == null) return null;
    if (_dependencies is EqualUnmodifiableMapView) return _dependencies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, Dependency>? _devDependencies;
  @override
  Map<String, Dependency>? get devDependencies {
    final value = _devDependencies;
    if (value == null) return null;
    if (_devDependencies is EqualUnmodifiableMapView) return _devDependencies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, Dependency>? _dependencyOverrides;
  @override
  Map<String, Dependency>? get dependencyOverrides {
    final value = _dependencyOverrides;
    if (value == null) return null;
    if (_dependencyOverrides is EqualUnmodifiableMapView)
      return _dependencyOverrides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of Catelog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CatelogCopyWith<_Catelog> get copyWith =>
      __$CatelogCopyWithImpl<_Catelog>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Catelog &&
            const DeepCollectionEquality()
                .equals(other._environment, _environment) &&
            (identical(other.publishTo, publishTo) ||
                other.publishTo == publishTo) &&
            (identical(other.repository, repository) ||
                other.repository == repository) &&
            (identical(other.issueTracker, issueTracker) ||
                other.issueTracker == issueTracker) &&
            const DeepCollectionEquality().equals(other._topics, _topics) &&
            (identical(other.documentation, documentation) ||
                other.documentation == documentation) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            const DeepCollectionEquality()
                .equals(other._dependencies, _dependencies) &&
            const DeepCollectionEquality()
                .equals(other._devDependencies, _devDependencies) &&
            const DeepCollectionEquality()
                .equals(other._dependencyOverrides, _dependencyOverrides));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_environment),
      publishTo,
      repository,
      issueTracker,
      const DeepCollectionEquality().hash(_topics),
      documentation,
      resolution,
      const DeepCollectionEquality().hash(_dependencies),
      const DeepCollectionEquality().hash(_devDependencies),
      const DeepCollectionEquality().hash(_dependencyOverrides));

  @override
  String toString() {
    return 'Catelog(environment: $environment, publishTo: $publishTo, repository: $repository, issueTracker: $issueTracker, topics: $topics, documentation: $documentation, resolution: $resolution, dependencies: $dependencies, devDependencies: $devDependencies, dependencyOverrides: $dependencyOverrides)';
  }
}

/// @nodoc
abstract mixin class _$CatelogCopyWith<$Res> implements $CatelogCopyWith<$Res> {
  factory _$CatelogCopyWith(_Catelog value, $Res Function(_Catelog) _then) =
      __$CatelogCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Map<String, VersionConstraint?>? environment,
      String? publishTo,
      Uri? repository,
      Uri? issueTracker,
      List<String>? topics,
      String? documentation,
      String? resolution,
      Map<String, Dependency>? dependencies,
      Map<String, Dependency>? devDependencies,
      Map<String, Dependency>? dependencyOverrides});
}

/// @nodoc
class __$CatelogCopyWithImpl<$Res> implements _$CatelogCopyWith<$Res> {
  __$CatelogCopyWithImpl(this._self, this._then);

  final _Catelog _self;
  final $Res Function(_Catelog) _then;

  /// Create a copy of Catelog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? environment = freezed,
    Object? publishTo = freezed,
    Object? repository = freezed,
    Object? issueTracker = freezed,
    Object? topics = freezed,
    Object? documentation = freezed,
    Object? resolution = freezed,
    Object? dependencies = freezed,
    Object? devDependencies = freezed,
    Object? dependencyOverrides = freezed,
  }) {
    return _then(_Catelog(
      environment: freezed == environment
          ? _self._environment
          : environment // ignore: cast_nullable_to_non_nullable
              as Map<String, VersionConstraint?>?,
      publishTo: freezed == publishTo
          ? _self.publishTo
          : publishTo // ignore: cast_nullable_to_non_nullable
              as String?,
      repository: freezed == repository
          ? _self.repository
          : repository // ignore: cast_nullable_to_non_nullable
              as Uri?,
      issueTracker: freezed == issueTracker
          ? _self.issueTracker
          : issueTracker // ignore: cast_nullable_to_non_nullable
              as Uri?,
      topics: freezed == topics
          ? _self._topics
          : topics // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      documentation: freezed == documentation
          ? _self.documentation
          : documentation // ignore: cast_nullable_to_non_nullable
              as String?,
      resolution: freezed == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      dependencies: freezed == dependencies
          ? _self._dependencies
          : dependencies // ignore: cast_nullable_to_non_nullable
              as Map<String, Dependency>?,
      devDependencies: freezed == devDependencies
          ? _self._devDependencies
          : devDependencies // ignore: cast_nullable_to_non_nullable
              as Map<String, Dependency>?,
      dependencyOverrides: freezed == dependencyOverrides
          ? _self._dependencyOverrides
          : dependencyOverrides // ignore: cast_nullable_to_non_nullable
              as Map<String, Dependency>?,
    ));
  }
}

// dart format on
