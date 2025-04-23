// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'downgrade_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PubDowngradeOptions {
  GlobalPubOptions get globalPubOptions;
  bool get offline;
  bool get dryRun;
  bool get tighten;

  /// Create a copy of PubDowngradeOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PubDowngradeOptionsCopyWith<PubDowngradeOptions> get copyWith =>
      _$PubDowngradeOptionsCopyWithImpl<PubDowngradeOptions>(
          this as PubDowngradeOptions, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PubDowngradeOptions &&
            (identical(other.globalPubOptions, globalPubOptions) ||
                other.globalPubOptions == globalPubOptions) &&
            (identical(other.offline, offline) || other.offline == offline) &&
            (identical(other.dryRun, dryRun) || other.dryRun == dryRun) &&
            (identical(other.tighten, tighten) || other.tighten == tighten));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, globalPubOptions, offline, dryRun, tighten);

  @override
  String toString() {
    return 'PubDowngradeOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, tighten: $tighten)';
  }
}

/// @nodoc
abstract mixin class $PubDowngradeOptionsCopyWith<$Res> {
  factory $PubDowngradeOptionsCopyWith(
          PubDowngradeOptions value, $Res Function(PubDowngradeOptions) _then) =
      _$PubDowngradeOptionsCopyWithImpl;
  @useResult
  $Res call(
      {GlobalPubOptions globalPubOptions,
      bool offline,
      bool dryRun,
      bool tighten});

  $GlobalPubOptionsCopyWith<$Res> get globalPubOptions;
}

/// @nodoc
class _$PubDowngradeOptionsCopyWithImpl<$Res>
    implements $PubDowngradeOptionsCopyWith<$Res> {
  _$PubDowngradeOptionsCopyWithImpl(this._self, this._then);

  final PubDowngradeOptions _self;
  final $Res Function(PubDowngradeOptions) _then;

  /// Create a copy of PubDowngradeOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalPubOptions = null,
    Object? offline = null,
    Object? dryRun = null,
    Object? tighten = null,
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
      tighten: null == tighten
          ? _self.tighten
          : tighten // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of PubDowngradeOptions
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

class _PubDowngradeOptions implements PubDowngradeOptions {
  const _PubDowngradeOptions(
      {required this.globalPubOptions,
      required this.offline,
      required this.dryRun,
      required this.tighten});

  @override
  final GlobalPubOptions globalPubOptions;
  @override
  final bool offline;
  @override
  final bool dryRun;
  @override
  final bool tighten;

  /// Create a copy of PubDowngradeOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PubDowngradeOptionsCopyWith<_PubDowngradeOptions> get copyWith =>
      __$PubDowngradeOptionsCopyWithImpl<_PubDowngradeOptions>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PubDowngradeOptions &&
            (identical(other.globalPubOptions, globalPubOptions) ||
                other.globalPubOptions == globalPubOptions) &&
            (identical(other.offline, offline) || other.offline == offline) &&
            (identical(other.dryRun, dryRun) || other.dryRun == dryRun) &&
            (identical(other.tighten, tighten) || other.tighten == tighten));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, globalPubOptions, offline, dryRun, tighten);

  @override
  String toString() {
    return 'PubDowngradeOptions(globalPubOptions: $globalPubOptions, offline: $offline, dryRun: $dryRun, tighten: $tighten)';
  }
}

/// @nodoc
abstract mixin class _$PubDowngradeOptionsCopyWith<$Res>
    implements $PubDowngradeOptionsCopyWith<$Res> {
  factory _$PubDowngradeOptionsCopyWith(_PubDowngradeOptions value,
          $Res Function(_PubDowngradeOptions) _then) =
      __$PubDowngradeOptionsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {GlobalPubOptions globalPubOptions,
      bool offline,
      bool dryRun,
      bool tighten});

  @override
  $GlobalPubOptionsCopyWith<$Res> get globalPubOptions;
}

/// @nodoc
class __$PubDowngradeOptionsCopyWithImpl<$Res>
    implements _$PubDowngradeOptionsCopyWith<$Res> {
  __$PubDowngradeOptionsCopyWithImpl(this._self, this._then);

  final _PubDowngradeOptions _self;
  final $Res Function(_PubDowngradeOptions) _then;

  /// Create a copy of PubDowngradeOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? globalPubOptions = null,
    Object? offline = null,
    Object? dryRun = null,
    Object? tighten = null,
  }) {
    return _then(_PubDowngradeOptions(
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
      tighten: null == tighten
          ? _self.tighten
          : tighten // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of PubDowngradeOptions
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
