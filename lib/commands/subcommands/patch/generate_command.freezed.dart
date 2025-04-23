// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generate_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GenerateOptions {
  GlobalPatchOptions get globalPatchOptions;
  bool get force;

  /// Create a copy of GenerateOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GenerateOptionsCopyWith<GenerateOptions> get copyWith =>
      _$GenerateOptionsCopyWithImpl<GenerateOptions>(
          this as GenerateOptions, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GenerateOptions &&
            (identical(other.globalPatchOptions, globalPatchOptions) ||
                other.globalPatchOptions == globalPatchOptions) &&
            (identical(other.force, force) || other.force == force));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalPatchOptions, force);

  @override
  String toString() {
    return 'GenerateOptions(globalPatchOptions: $globalPatchOptions, force: $force)';
  }
}

/// @nodoc
abstract mixin class $GenerateOptionsCopyWith<$Res> {
  factory $GenerateOptionsCopyWith(
          GenerateOptions value, $Res Function(GenerateOptions) _then) =
      _$GenerateOptionsCopyWithImpl;
  @useResult
  $Res call({GlobalPatchOptions globalPatchOptions, bool force});

  $GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions;
}

/// @nodoc
class _$GenerateOptionsCopyWithImpl<$Res>
    implements $GenerateOptionsCopyWith<$Res> {
  _$GenerateOptionsCopyWithImpl(this._self, this._then);

  final GenerateOptions _self;
  final $Res Function(GenerateOptions) _then;

  /// Create a copy of GenerateOptions
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

  /// Create a copy of GenerateOptions
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

class _GenerateOptions implements GenerateOptions {
  const _GenerateOptions(
      {required this.globalPatchOptions, required this.force});

  @override
  final GlobalPatchOptions globalPatchOptions;
  @override
  final bool force;

  /// Create a copy of GenerateOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GenerateOptionsCopyWith<_GenerateOptions> get copyWith =>
      __$GenerateOptionsCopyWithImpl<_GenerateOptions>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GenerateOptions &&
            (identical(other.globalPatchOptions, globalPatchOptions) ||
                other.globalPatchOptions == globalPatchOptions) &&
            (identical(other.force, force) || other.force == force));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalPatchOptions, force);

  @override
  String toString() {
    return 'GenerateOptions(globalPatchOptions: $globalPatchOptions, force: $force)';
  }
}

/// @nodoc
abstract mixin class _$GenerateOptionsCopyWith<$Res>
    implements $GenerateOptionsCopyWith<$Res> {
  factory _$GenerateOptionsCopyWith(
          _GenerateOptions value, $Res Function(_GenerateOptions) _then) =
      __$GenerateOptionsCopyWithImpl;
  @override
  @useResult
  $Res call({GlobalPatchOptions globalPatchOptions, bool force});

  @override
  $GlobalPatchOptionsCopyWith<$Res> get globalPatchOptions;
}

/// @nodoc
class __$GenerateOptionsCopyWithImpl<$Res>
    implements _$GenerateOptionsCopyWith<$Res> {
  __$GenerateOptionsCopyWithImpl(this._self, this._then);

  final _GenerateOptions _self;
  final $Res Function(_GenerateOptions) _then;

  /// Create a copy of GenerateOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? globalPatchOptions = null,
    Object? force = null,
  }) {
    return _then(_GenerateOptions(
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

  /// Create a copy of GenerateOptions
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
