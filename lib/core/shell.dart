import 'dart:io';

import 'package:path/path.dart';

String getShell() {
  final shellPath = Platform.environment['SHELL'];
  if (shellPath == null) {
    return 'bash';
  }

  return basename(shellPath);
}
