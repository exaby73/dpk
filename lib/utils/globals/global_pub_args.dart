import 'package:args/args.dart';
import 'package:dpk/utils/cache_directory.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_pub_args.freezed.dart';

void addGlobalPubArgs(ArgParser parser) {
  addGlobalArgs(parser);
  parser.addFlag(
    'color',
    help:
        'Use colors in terminal output\n'
        'Defaults to color when connected to a terminal, and no-color otherwise.',
    defaultsTo: null,
  );
}

List<String> buildGlobalArgs(GlobalPubOptions options) {
  return [
    if (options.globalOptions.verbose) '--verbose',
    if (options.globalOptions.directory?.isNotEmpty == true) ...[
      '-C',
      options.globalOptions.directory!,
    ],
    if (options.color != null) options.color! ? '--color' : '--no-color',
  ];
}

@freezed
abstract class GlobalPubOptions with _$GlobalPubOptions {
  factory GlobalPubOptions({
    required GlobalOptions globalOptions,
    required String cacheDir,
    required bool? color,
  }) {
    return GlobalPubOptions._internal(
      globalOptions: globalOptions,
      cacheDir: initializeCacheDir(cacheDir, globalOptions.directory),
      color: color,
    );
  }
  const factory GlobalPubOptions._internal({
    required GlobalOptions globalOptions,
    required String cacheDir,
    required bool? color,
  }) = _GlobalPubOptions;

  factory GlobalPubOptions.fromArgResults(ArgResults results) {
    return GlobalPubOptions(
      globalOptions: GlobalOptions.fromArgResults(results),
      cacheDir: results.option('cache-dir')!,
      color: results['color'] as bool?,
    );
  }

  const GlobalPubOptions._();
}
