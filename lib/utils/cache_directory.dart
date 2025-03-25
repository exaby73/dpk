import 'dart:io';

import 'package:path/path.dart';

String initializeCacheDir(String cacheDir, String? directory) {
  if (cacheDir.startsWith('/')) {
    return cacheDir;
  }

  late String currentDirPath;
  if (directory != null) {
    currentDirPath = Directory(directory).absolute.path;
  } else {
    currentDirPath = Directory.current.absolute.path;
  }

  return join(currentDirPath, cacheDir);
}
