// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upgrade_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PubUpgradeOptions {
  GlobalPubOptions get globalPubOptions;
  bool get offline;
  bool get dryRun;
  bool get precompile;
  bool get tighten;
  bool get unlockTransitive;
  bool get majorVersions;

  /// Create a copy of PubUpgradeOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PubUpgradeOptionsCopyWith<PubUpgradeOptions> get copyWith =>
      _$PubUpgradeOptionsCopyWithImpl<PubUpgradeOptions>(
          this as PubUpgradeOptions, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PubUpgradeOptions &&
            (identical(other.globalPubOptions, globalPubOptions) ||
                other.globalPubOptions == globalPubOptions) &&
            (identical(other.offline, offline) || other.offline == offline) &&
            (identical(other.dryRun, dryRun) || other.dryRun == dryRun) &&
            (identical(other.precompile, precompile) ||
                other.precompile == precompile) &&
            (identical(other.tighten, tighten) || other.tighten == tighten) &&
            (identical(other.unlockTransitive, unlockTransitive) ||
                other.unlockTransitive == unlockTransitive) &&
            (identical(other.majorVersions, majorVersions) ||
                other.majorVersions == majorVersions));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalPubOptions, offline,
      dryRun, precompile, tighten, unlockTransitive, majorVersions);

  @override
  String toString() {
    return 'PubUpgradeOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, precompile: $precompile, tighten: $tighten, unlockTransitive: $unlockTransitive, majorVersions: $majorVersions)';
  }
}

/// @nodoc
abstract mixin class $PubUpgradeOptionsCopyWith<$Res> {
  factory $PubUpgradeOptionsCopyWith(
          PubUpgradeOptions value, $Res Function(PubUpgradeOptions) _then) =
      _$PubUpgradeOptionsCopyWithImpl;
  @useResult
  $Res call(
      {GlobalPubOptions globalPubOptions,
      bool offline,
      bool dryRun,
      bool precompile,
      bool tighten,
      bool unlockTransitive,
      bool majorVersions});

  $GlobalPubOptionsCopyWith<$Res> get globalPubOptions;
}

/// @nodoc
class _$PubUpgradeOptionsCopyWithImpl<$Res>
    implements $PubUpgradeOptionsCopyWith<$Res> {
  _$PubUpgradeOptionsCopyWithImpl(this._self, this._then);

  final PubUpgradeOptions _self;
  final $Res Function(PubUpgradeOptions) _then;

  /// Create a copy of PubUpgradeOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalPubOptions = null,
    Object? offline = null,
    Object? dryRun = null,
    Object? precompile = null,
    Object? tighten = null,
    Object? unlockTransitive = null,
    Object? majorVersions = null,
  }) {
    return _then(_self.copyWith(
      globalPubOptions: null == globalPubOptions
          ? _self.globalPubOptions
          : globalPubOptions // ignore: cast_nullable_to_non_nullable
              as GlobalPubOptions,
      offline: null == offline
          ? _self.offline
          : offline // ignore: cast_nullable_to_non_nullable
              as bool,
      dryRun: null == dryRun
          ? _self.dryRun
          : dryRun // ignore: cast_nullable_to_non_nullable
              as bool,
      precompile: null == precompile
          ? _self.precompile
          : precompile // ignore: cast_nullable_to_non_nullable
              as bool,
      tighten: null == tighten
          ? _self.tighten
          : tighten // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockTransitive: null == unlockTransitive
          ? _self.unlockTransitive
          : unlockTransitive // ignore: cast_nullable_to_non_nullable
              as bool,
      majorVersions: null == majorVersions
          ? _self.majorVersions
          : majorVersions // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of PubUpgradeOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GlobalPubOptionsCopyWith<$Res> get globalPubOptions {
    return $GlobalPubOptionsCopyWith<$Res>(_self.globalPubOptions, (value) {
      return _then(_self.copyWith(globalPubOptions: value));
    });
  }
}

/// @nodoc

class _PubUpgradeOptions implements PubUpgradeOptions {
  const _PubUpgradeOptions(
      {required this.globalPubOptions,
      required this.offline,
      required this.dryRun,
      required this.precompile,
      required this.tighten,
      required this.unlockTransitive,
      required this.majorVersions});

  @override
  final GlobalPubOptions globalPubOptions;
  @override
  final bool offline;
  @override
  final bool dryRun;
  @override
  final bool precompile;
  @override
  final bool tighten;
  @override
  final bool unlockTransitive;
  @override
  final bool majorVersions;

  /// Create a copy of PubUpgradeOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PubUpgradeOptionsCopyWith<_PubUpgradeOptions> get copyWith =>
      __$PubUpgradeOptionsCopyWithImpl<_PubUpgradeOptions>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PubUpgradeOptions &&
            (identical(other.globalPubOptions, globalPubOptions) ||
                other.globalPubOptions == globalPubOptions) &&
            (identical(other.offline, offline) || other.offline == offline) &&
            (identical(other.dryRun, dryRun) || other.dryRun == dryRun) &&
            (identical(other.precompile, precompile) ||
                other.precompile == precompile) &&
            (identical(other.tighten, tighten) || other.tighten == tighten) &&
            (identical(other.unlockTransitive, unlockTransitive) ||
                other.unlockTransitive == unlockTransitive) &&
            (identical(other.majorVersions, majorVersions) ||
                other.majorVersions == majorVersions));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalPubOptions, offline,
      dryRun, precompile, tighten, unlockTransitive, majorVersions);

  @override
  String toString() {
    return 'PubUpgradeOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, precompile: $precompile, tighten: $tighten, unlockTransitive: $unlockTransitive, majorVersions: $majorVersions)';
  }
}

/// @nodoc
abstract mixin class _$PubUpgradeOptionsCopyWith<$Res>
    implements $PubUpgradeOptionsCopyWith<$Res> {
  factory _$PubUpgradeOptionsCopyWith(
          _PubUpgradeOptions value, $Res Function(_PubUpgradeOptions) _then) =
      __$PubUpgradeOptionsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {GlobalPubOptions globalPubOptions,
      bool offline,
      bool dryRun,
      bool precompile,
      bool tighten,
      bool unlockTransitive,
      bool majorVersions});

  @override
  $GlobalPubOptionsCopyWith<$Res> get globalPubOptions;
}

/// @nodoc
class __$PubUpgradeOptionsCopyWithImpl<$Res>
    implements _$PubUpgradeOptionsCopyWith<$Res> {
  __$PubUpgradeOptionsCopyWithImpl(this._self, this._then);

  final _PubUpgradeOptions _self;
  final $Res Function(_PubUpgradeOptions) _then;

  /// Create a copy of PubUpgradeOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? globalPubOptions = null,
    Object? offline = null,
    Object? dryRun = null,
    Object? precompile = null,
    Object? tighten = null,
    Object? unlockTransitive = null,
    Object? majorVersions = null,
  }) {
    return _then(_PubUpgradeOptions(
      globalPubOptions: null == globalPubOptions
          ? _self.globalPubOptions
          : globalPubOptions // ignore: cast_nullable_to_non_nullable
              as GlobalPubOptions,
      offline: null == offline
          ? _self.offline
          : offline // ignore: cast_nullable_to_non_nullable
              as bool,
      dryRun: null == dryRun
          ? _self.dryRun
          : dryRun // ignore: cast_nullable_to_non_nullable
              as bool,
      precompile: null == precompile
          ? _self.precompile
          : precompile // ignore: cast_nullable_to_non_nullable
              as bool,
      tighten: null == tighten
          ? _self.tighten
          : tighten // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockTransitive: null == unlockTransitive
          ? _self.unlockTransitive
          : unlockTransitive // ignore: cast_nullable_to_non_nullable
              as bool,
      majorVersions: null == majorVersions
          ? _self.majorVersions
          : majorVersions // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of PubUpgradeOptions
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
