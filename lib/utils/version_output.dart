import 'dart:io';

import 'package:dpk/constants/pubspec.dart';

String renderVersionOutput() {
  final dartVersion = Platform.version.split(' ').first;

  return '''
dpk
  Version:  ${pubspec.version}
  Dart SDK: $dartVersion
'''
      .trimRight();
}
