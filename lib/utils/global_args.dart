import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:path/path.dart';

part 'global_args.mapper.dart';

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

  parser.addOption('patch-dir', abbr: 'p', defaultsTo: 'patches');
}

@MappableClass()
base class GlobalOptions with GlobalOptionsMappable {
  final bool debug;
  final String? directory;
  late final String cacheDir;
  late final String patchDir;

  GlobalOptions({
    required this.debug,
    required this.directory,
    required String cacheDir,
    required String patchDir,
  }) {
    _initializeCacheDir(cacheDir);
    _initializePatchDir(patchDir);
  }

  void _initializeCacheDir(String cacheDir) {
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

    this.cacheDir = join(currentDirPath, cacheDir);
  }

  void _initializePatchDir(String patchDir) {
    if (patchDir.startsWith('/')) {
      this.patchDir = patchDir;
      return;
    }

    late String currentDirPath;
    if (directory != null) {
      currentDirPath = Directory(directory!).absolute.path;
    } else {
      currentDirPath = Directory.current.absolute.path;
    }

    this.patchDir = join(currentDirPath, patchDir);
  }
}
