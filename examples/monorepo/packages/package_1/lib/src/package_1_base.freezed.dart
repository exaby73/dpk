// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_1_base.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TestClass {
  int get foo;
  String get bar;

  /// Create a copy of TestClass
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TestClassCopyWith<TestClass> get copyWith =>
      _$TestClassCopyWithImpl<TestClass>(this as TestClass, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TestClass &&
            (identical(other.foo, foo) || other.foo == foo) &&
            (identical(other.bar, bar) || other.bar == bar));
  }

  @override
  int get hashCode => Object.hash(runtimeType, foo, bar);

  @override
  String toString() {
    return 'TestClass(foo: $foo, bar: $bar)';
  }
}

/// @nodoc
abstract mixin class $TestClassCopyWith<$Res> {
  factory $TestClassCopyWith(TestClass value, $Res Function(TestClass) _then) =
      _$TestClassCopyWithImpl;
  @useResult
  $Res call({int foo, String bar});
}

/// @nodoc
class _$TestClassCopyWithImpl<$Res> implements $TestClassCopyWith<$Res> {
  _$TestClassCopyWithImpl(this._self, this._then);

  final TestClass _self;
  final $Res Function(TestClass) _then;

  /// Create a copy of TestClass
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foo = null,
    Object? bar = null,
  }) {
    return _then(_self.copyWith(
      foo: null == foo
          ? _self.foo
          : foo // ignore: cast_nullable_to_non_nullable
              as int,
      bar: null == bar
          ? _self.bar
          : bar // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _TestClass implements TestClass {
  const _TestClass({required this.foo, required this.bar});

  @override
  final int foo;
  @override
  final String bar;

  /// Create a copy of TestClass
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TestClassCopyWith<_TestClass> get copyWith =>
      __$TestClassCopyWithImpl<_TestClass>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TestClass &&
            (identical(other.foo, foo) || other.foo == foo) &&
            (identical(other.bar, bar) || other.bar == bar));
  }

  @override
  int get hashCode => Object.hash(runtimeType, foo, bar);

  @override
  String toString() {
    return 'TestClass(foo: $foo, bar: $bar)';
  }
}

/// @nodoc
abstract mixin class _$TestClassCopyWith<$Res>
    implements $TestClassCopyWith<$Res> {
  factory _$TestClassCopyWith(
          _TestClass value, $Res Function(_TestClass) _then) =
      __$TestClassCopyWithImpl;
  @override
  @useResult
  $Res call({int foo, String bar});
}

/// @nodoc
class __$TestClassCopyWithImpl<$Res> implements _$TestClassCopyWith<$Res> {
  __$TestClassCopyWithImpl(this._self, this._then);

  final _TestClass _self;
  final $Res Function(_TestClass) _then;

  /// Create a copy of TestClass
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? foo = null,
    Object? bar = null,
  }) {
    return _then(_TestClass(
      foo: null == foo
          ? _self.foo
          : foo // ignore: cast_nullable_to_non_nullable
              as int,
      bar: null == bar
          ? _self.bar
          : bar // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
