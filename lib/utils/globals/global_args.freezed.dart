// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_args.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GlobalOptions {
  String? get directory;
  bool get verbose;
  bool get debug;

  /// Create a copy of GlobalOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GlobalOptionsCopyWith<GlobalOptions> get copyWith =>
      _$GlobalOptionsCopyWithImpl<GlobalOptions>(
          this as GlobalOptions, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GlobalOptions &&
            (identical(other.directory, directory) ||
                other.directory == directory) &&
            (identical(other.verbose, verbose) || other.verbose == verbose) &&
            (identical(other.debug, debug) || other.debug == debug));
  }

  @override
  int get hashCode => Object.hash(runtimeType, directory, verbose, debug);

  @override
  String toString() {
    return 'GlobalOptions(directory: $directory, verbose: $verbose, debug: $debug)';
  }
}

/// @nodoc
abstract mixin class $GlobalOptionsCopyWith<$Res> {
  factory $GlobalOptionsCopyWith(
          GlobalOptions value, $Res Function(GlobalOptions) _then) =
      _$GlobalOptionsCopyWithImpl;
  @useResult
  $Res call({String? directory, bool verbose, bool debug});
}

/// @nodoc
class _$GlobalOptionsCopyWithImpl<$Res>
    implements $GlobalOptionsCopyWith<$Res> {
  _$GlobalOptionsCopyWithImpl(this._self, this._then);

  final GlobalOptions _self;
  final $Res Function(GlobalOptions) _then;

  /// Create a copy of GlobalOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? directory = freezed,
    Object? verbose = null,
    Object? debug = null,
  }) {
    return _then(_self.copyWith(
      directory: freezed == directory
          ? _self.directory
          : directory // ignore: cast_nullable_to_non_nullable
              as String?,
      verbose: null == verbose
          ? _self.verbose
          : verbose // ignore: cast_nullable_to_non_nullable
              as bool,
      debug: null == debug
          ? _self.debug
          : debug // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _GlobalOptions extends GlobalOptions {
  const _GlobalOptions(
      {required this.directory, required this.verbose, required this.debug})
      : super._();

  @override
  final String? directory;
  @override
  final bool verbose;
  @override
  final bool debug;

  /// Create a copy of GlobalOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GlobalOptionsCopyWith<_GlobalOptions> get copyWith =>
      __$GlobalOptionsCopyWithImpl<_GlobalOptions>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GlobalOptions &&
            (identical(other.directory, directory) ||
                other.directory == directory) &&
            (identical(other.verbose, verbose) || other.verbose == verbose) &&
            (identical(other.debug, debug) || other.debug == debug));
  }

  @override
  int get hashCode => Object.hash(runtimeType, directory, verbose, debug);

  @override
  String toString() {
    return 'GlobalOptions._internal(directory: $directory, verbose: $verbose, debug: $debug)';
  }
}

/// @nodoc
abstract mixin class _$GlobalOptionsCopyWith<$Res>
    implements $GlobalOptionsCopyWith<$Res> {
  factory _$GlobalOptionsCopyWith(
          _GlobalOptions value, $Res Function(_GlobalOptions) _then) =
      __$GlobalOptionsCopyWithImpl;
  @override
  @useResult
  $Res call({String? directory, bool verbose, bool debug});
}

/// @nodoc
class __$GlobalOptionsCopyWithImpl<$Res>
    implements _$GlobalOptionsCopyWith<$Res> {
  __$GlobalOptionsCopyWithImpl(this._self, this._then);

  final _GlobalOptions _self;
  final $Res Function(_GlobalOptions) _then;

  /// Create a copy of GlobalOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? directory = freezed,
    Object? verbose = null,
    Object? debug = null,
  }) {
    return _then(_GlobalOptions(
      directory: freezed == directory
          ? _self.directory
          : directory // ignore: cast_nullable_to_non_nullable
              as String?,
      verbose: null == verbose
          ? _self.verbose
          : verbose // ignore: cast_nullable_to_non_nullable
              as bool,
      debug: null == debug
          ? _self.debug
          : debug // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
