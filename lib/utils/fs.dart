import 'dart:io';

Directory getProjectRoot(String? path) {
  if (path == null) {
    return Directory.current;
  }

  return Directory(path);
}
