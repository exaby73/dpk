// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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
  GlobalPatchOptions get globalPatchOptions;
  bool get force;

  /// Create a copy of PatchOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PatchOptionsCopyWith<PatchOptions> get copyWith =>
      _$PatchOptionsCopyWithImpl<PatchOptions>(
          this as PatchOptions, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PatchOptions &&
            (identical(other.globalPatchOptions, globalPatchOptions) ||
                other.globalPatchOptions == globalPatchOptions) &&
            (identical(other.force, force) || other.force == force));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalPatchOptions, force);

  @override
  String toString() {
    return 'PatchOptions(globalPatchOptions: $globalPatchOptions, force: $force)';
  }
}

/// @nodoc
abstract mixin class $PatchOptionsCopyWith<$Res> {
  factory $PatchOptionsCopyWith(
          PatchOptions value, $Res Function(PatchOptions) _then) =
      _$PatchOptionsCopyWithImpl;
  @useResult
  $Res call({GlobalPatchOptions globalPatchOptions, bool force});

  $GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions;
}

/// @nodoc
class _$PatchOptionsCopyWithImpl<$Res> implements $PatchOptionsCopyWith<$Res> {
  _$PatchOptionsCopyWithImpl(this._self, this._then);

  final PatchOptions _self;
  final $Res Function(PatchOptions) _then;

  /// Create a copy of PatchOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalPatchOptions = null,
    Object? force = null,
  }) {
    return _then(_self.copyWith(
      globalPatchOptions: null == globalPatchOptions
          ? _self.globalPatchOptions
          : globalPatchOptions // ignore: cast_nullable_to_non_nullable
              as GlobalPatchOptions,
      force: null == force
          ? _self.force
          : force // ignore: cast_nullable_to_non_nullable
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

/// @nodoc

class _PatchOptions implements PatchOptions {
  const _PatchOptions({required this.globalPatchOptions, required this.force});

  @override
  final GlobalPatchOptions globalPatchOptions;
  @override
  final bool force;

  /// Create a copy of PatchOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PatchOptionsCopyWith<_PatchOptions> get copyWith =>
      __$PatchOptionsCopyWithImpl<_PatchOptions>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PatchOptions &&
            (identical(other.globalPatchOptions, globalPatchOptions) ||
                other.globalPatchOptions == globalPatchOptions) &&
            (identical(other.force, force) || other.force == force));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalPatchOptions, force);

  @override
  String toString() {
    return 'PatchOptions(globalPatchOptions: $globalPatchOptions, force: $force)';
  }
}

/// @nodoc
abstract mixin class _$PatchOptionsCopyWith<$Res>
    implements $PatchOptionsCopyWith<$Res> {
  factory _$PatchOptionsCopyWith(
          _PatchOptions value, $Res Function(_PatchOptions) _then) =
      __$PatchOptionsCopyWithImpl;
  @override
  @useResult
  $Res call({GlobalPatchOptions globalPatchOptions, bool force});

  @override
  $GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions;
}

/// @nodoc
class __$PatchOptionsCopyWithImpl<$Res>
    implements _$PatchOptionsCopyWith<$Res> {
  __$PatchOptionsCopyWithImpl(this._self, this._then);

  final _PatchOptions _self;
  final $Res Function(_PatchOptions) _then;

  /// Create a copy of PatchOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? globalPatchOptions = null,
    Object? force = null,
  }) {
    return _then(_PatchOptions(
      globalPatchOptions: null == globalPatchOptions
          ? _self.globalPatchOptions
          : globalPatchOptions // ignore: cast_nullable_to_non_nullable
              as GlobalPatchOptions,
      force: null == force
          ? _self.force
          : force // ignore: cast_nullable_to_non_nullable
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
