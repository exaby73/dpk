import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_1_base.freezed.dart';

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

@freezed
abstract class TestClass with _$TestClass {
  const factory TestClass({required int foo, required String bar}) = _TestClass;
}
