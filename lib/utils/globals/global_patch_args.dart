import 'package:args/args.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
    return GlobalPatchOptions.internal(
      globalOptions: globalOptions,
      cacheDir: cacheDir,
      patchDir: patchDir,
    );
  }
  const factory GlobalPatchOptions.internal({
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
}
