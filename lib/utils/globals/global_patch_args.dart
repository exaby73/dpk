import 'dart:io';

import 'package:args/args.dart';
import 'package:dpk/utils/cache_directory.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';

part 'global_patch_args.freezed.dart';

void addGlobalPatchArgs(ArgParser parser) {
  addGlobalArgs(parser);
  parser.addOption('patch-dir', abbr: 'p', defaultsTo: 'patches');
}

@freezed
abstract class GlobalPatchOptions with _$GlobalPatchOptions {
  factory GlobalPatchOptions({
    required GlobalOptions globalOptions,
    required String cacheDir,
    required String patchDir,
  }) {
    return GlobalPatchOptions._internal(
      globalOptions: globalOptions,
      cacheDir: initializeCacheDir(cacheDir, globalOptions.directory),
      patchDir: _initializePatchDir(patchDir, globalOptions.directory),
    );
  }
  const factory GlobalPatchOptions._internal({
    required GlobalOptions globalOptions,
    required String cacheDir,
    required String patchDir,
  }) = _GlobalPatchOptions;

  factory GlobalPatchOptions.fromArgResults(ArgResults results) {
    return GlobalPatchOptions(
      globalOptions: GlobalOptions.fromArgResults(results),
      cacheDir: results.option('cache-dir')!,
      patchDir: results.option('patch-dir')!,
    );
  }

  static String _initializePatchDir(String patchDir, String? directory) {
    if (patchDir.startsWith('/')) {
      return patchDir;
    }

    late String currentDirPath;
    if (directory != null) {
      currentDirPath = Directory(directory).absolute.path;
    } else {
      currentDirPath = Directory.current.absolute.path;
    }

    return join(currentDirPath, patchDir);
  }
}
