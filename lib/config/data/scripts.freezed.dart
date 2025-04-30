// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scripts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Scripts {
  Map<String, Script> get scriptsMap;

  /// Create a copy of Scripts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScriptsCopyWith<Scripts> get copyWith =>
      _$ScriptsCopyWithImpl<Scripts>(this as Scripts, _$identity);

  /// Serializes this Scripts to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Scripts &&
            const DeepCollectionEquality()
                .equals(other.scriptsMap, scriptsMap));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(scriptsMap));

  @override
  String toString() {
    return 'Scripts(scriptsMap: $scriptsMap)';
  }
}

/// @nodoc
abstract mixin class $ScriptsCopyWith<$Res> {
  factory $ScriptsCopyWith(Scripts value, $Res Function(Scripts) _then) =
      _$ScriptsCopyWithImpl;
  @useResult
  $Res call({Map<String, Script> scriptsMap});
}

/// @nodoc
class _$ScriptsCopyWithImpl<$Res> implements $ScriptsCopyWith<$Res> {
  _$ScriptsCopyWithImpl(this._self, this._then);

  final Scripts _self;
  final $Res Function(Scripts) _then;

  /// Create a copy of Scripts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scriptsMap = null,
  }) {
    return _then(_self.copyWith(
      scriptsMap: null == scriptsMap
          ? _self.scriptsMap
          : scriptsMap // ignore: cast_nullable_to_non_nullable
              as Map<String, Script>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Scripts implements Scripts {
  const _Scripts({required final Map<String, Script> scriptsMap})
      : _scriptsMap = scriptsMap;
  factory _Scripts.fromJson(Map<String, dynamic> json) =>
      _$ScriptsFromJson(json);

  final Map<String, Script> _scriptsMap;
  @override
  Map<String, Script> get scriptsMap {
    if (_scriptsMap is EqualUnmodifiableMapView) return _scriptsMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scriptsMap);
  }

  /// Create a copy of Scripts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScriptsCopyWith<_Scripts> get copyWith =>
      __$ScriptsCopyWithImpl<_Scripts>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScriptsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Scripts &&
            const DeepCollectionEquality()
                .equals(other._scriptsMap, _scriptsMap));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_scriptsMap));

  @override
  String toString() {
    return 'Scripts(scriptsMap: $scriptsMap)';
  }
}

/// @nodoc
abstract mixin class _$ScriptsCopyWith<$Res> implements $ScriptsCopyWith<$Res> {
  factory _$ScriptsCopyWith(_Scripts value, $Res Function(_Scripts) _then) =
      __$ScriptsCopyWithImpl;
  @override
  @useResult
  $Res call({Map<String, Script> scriptsMap});
}

/// @nodoc
class __$ScriptsCopyWithImpl<$Res> implements _$ScriptsCopyWith<$Res> {
  __$ScriptsCopyWithImpl(this._self, this._then);

  final _Scripts _self;
  final $Res Function(_Scripts) _then;

  /// Create a copy of Scripts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? scriptsMap = null,
  }) {
    return _then(_Scripts(
      scriptsMap: null == scriptsMap
          ? _self._scriptsMap
          : scriptsMap // ignore: cast_nullable_to_non_nullable
              as Map<String, Script>,
    ));
  }
}

/// @nodoc
mixin _$Script {
  String get name;
  String get command;
  List<String>? get runInPackages;
  HookType get hookType;
  String? get runHooksFrom;
  Map<String, String>? get env;

  /// Create a copy of Script
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScriptCopyWith<Script> get copyWith =>
      _$ScriptCopyWithImpl<Script>(this as Script, _$identity);

  /// Serializes this Script to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Script &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.command, command) || other.command == command) &&
            const DeepCollectionEquality()
                .equals(other.runInPackages, runInPackages) &&
            (identical(other.hookType, hookType) ||
                other.hookType == hookType) &&
            (identical(other.runHooksFrom, runHooksFrom) ||
                other.runHooksFrom == runHooksFrom) &&
            const DeepCollectionEquality().equals(other.env, env));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      command,
      const DeepCollectionEquality().hash(runInPackages),
      hookType,
      runHooksFrom,
      const DeepCollectionEquality().hash(env));

  @override
  String toString() {
    return 'Script(name: $name, command: $command, runInPackages: $runInPackages, hookType: $hookType, runHooksFrom: $runHooksFrom, env: $env)';
  }
}

/// @nodoc
abstract mixin class $ScriptCopyWith<$Res> {
  factory $ScriptCopyWith(Script value, $Res Function(Script) _then) =
      _$ScriptCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      String command,
      List<String>? runInPackages,
      HookType hookType,
      String? runHooksFrom,
      Map<String, String>? env});
}

/// @nodoc
class _$ScriptCopyWithImpl<$Res> implements $ScriptCopyWith<$Res> {
  _$ScriptCopyWithImpl(this._self, this._then);

  final Script _self;
  final $Res Function(Script) _then;

  /// Create a copy of Script
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? command = null,
    Object? runInPackages = freezed,
    Object? hookType = null,
    Object? runHooksFrom = freezed,
    Object? env = freezed,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      command: null == command
          ? _self.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      runInPackages: freezed == runInPackages
          ? _self.runInPackages
          : runInPackages // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      hookType: null == hookType
          ? _self.hookType
          : hookType // ignore: cast_nullable_to_non_nullable
              as HookType,
      runHooksFrom: freezed == runHooksFrom
          ? _self.runHooksFrom
          : runHooksFrom // ignore: cast_nullable_to_non_nullable
              as String?,
      env: freezed == env
          ? _self.env
          : env // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Script implements Script {
  const _Script(
      {required this.name,
      required this.command,
      final List<String>? runInPackages,
      required this.hookType,
      required this.runHooksFrom,
      final Map<String, String>? env})
      : _runInPackages = runInPackages,
        _env = env;
  factory _Script.fromJson(Map<String, dynamic> json) => _$ScriptFromJson(json);

  @override
  final String name;
  @override
  final String command;
  final List<String>? _runInPackages;
  @override
  List<String>? get runInPackages {
    final value = _runInPackages;
    if (value == null) return null;
    if (_runInPackages is EqualUnmodifiableListView) return _runInPackages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final HookType hookType;
  @override
  final String? runHooksFrom;
  final Map<String, String>? _env;
  @override
  Map<String, String>? get env {
    final value = _env;
    if (value == null) return null;
    if (_env is EqualUnmodifiableMapView) return _env;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of Script
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScriptCopyWith<_Script> get copyWith =>
      __$ScriptCopyWithImpl<_Script>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScriptToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Script &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.command, command) || other.command == command) &&
            const DeepCollectionEquality()
                .equals(other._runInPackages, _runInPackages) &&
            (identical(other.hookType, hookType) ||
                other.hookType == hookType) &&
            (identical(other.runHooksFrom, runHooksFrom) ||
                other.runHooksFrom == runHooksFrom) &&
            const DeepCollectionEquality().equals(other._env, _env));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      command,
      const DeepCollectionEquality().hash(_runInPackages),
      hookType,
      runHooksFrom,
      const DeepCollectionEquality().hash(_env));

  @override
  String toString() {
    return 'Script._(name: $name, command: $command, runInPackages: $runInPackages, hookType: $hookType, runHooksFrom: $runHooksFrom, env: $env)';
  }
}

/// @nodoc
abstract mixin class _$ScriptCopyWith<$Res> implements $ScriptCopyWith<$Res> {
  factory _$ScriptCopyWith(_Script value, $Res Function(_Script) _then) =
      __$ScriptCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      String command,
      List<String>? runInPackages,
      HookType hookType,
      String? runHooksFrom,
      Map<String, String>? env});
}

/// @nodoc
class __$ScriptCopyWithImpl<$Res> implements _$ScriptCopyWith<$Res> {
  __$ScriptCopyWithImpl(this._self, this._then);

  final _Script _self;
  final $Res Function(_Script) _then;

  /// Create a copy of Script
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? command = null,
    Object? runInPackages = freezed,
    Object? hookType = null,
    Object? runHooksFrom = freezed,
    Object? env = freezed,
  }) {
    return _then(_Script(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      command: null == command
          ? _self.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      runInPackages: freezed == runInPackages
          ? _self._runInPackages
          : runInPackages // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      hookType: null == hookType
          ? _self.hookType
          : hookType // ignore: cast_nullable_to_non_nullable
              as HookType,
      runHooksFrom: freezed == runHooksFrom
          ? _self.runHooksFrom
          : runHooksFrom // ignore: cast_nullable_to_non_nullable
              as String?,
      env: freezed == env
          ? _self._env
          : env // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

// dart format on
