import 'dart:io';

import 'package:dpk/constants/pubspec.g.dart';

String renderVersionOutput() {
  final dartVersion = Platform.version.split(' ').first;

  return '''
dpk
  Version:    ${Pubspec.version.representation}
  Dart SDK:   $dartVersion
  Repository: ${Pubspec.repository}
'''
      .trimRight();
}
