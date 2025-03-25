import 'dart:convert';

extension DebugJsonPrettyPrint on Map {
  String toPrettyString() {
    return const JsonEncoder.withIndent('  ').convert(this);
  }
}
