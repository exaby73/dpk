import 'dart:io';

import 'package:args/args.dart';
import 'package:dpm/utils/string_extensions.dart';

void addGlobalArgs(ArgParser parser) {
  parser.addFlag(
    'debug',
    help: 'Enable debug output',
    negatable: false,
    hide: true,
  );

  parser.addOption(
    'directory',
    abbr: 'C',
    help: 'Directory to run the subcommand in',
  );

  parser.addOption(
    'cache-dir',
    abbr: 'd',
    defaultsTo: 'pub_packages',
    help: 'Directory to store dependencies',
  );
}

base class GlobalOptions {
  final bool debug;
  final String? directory;
  late final String cacheDir;

  GlobalOptions({
    required this.debug,
    required this.directory,
    required String cacheDir,
  }) {
    if (cacheDir.startsWith('/')) {
      this.cacheDir = cacheDir;
      return;
    }

    late String currentDirPath;
    if (directory != null) {
      currentDirPath = Directory(directory!).absolute.path;
    } else {
      currentDirPath = Directory.current.absolute.path;
    }

    this.cacheDir = '$currentDirPath/$cacheDir';
  }

  @override
  String toString() {
    return '''
    GlobalOptions(
      debug: $debug,
      directory: $directory,
      cacheDir: $cacheDir,
    )
    '''.trimIndents();
  }
}
