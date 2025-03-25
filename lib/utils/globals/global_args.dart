import 'package:args/args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_args.freezed.dart';

void addGlobalArgs(ArgParser parser) {
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

  parser.addFlag(
    'verbose',
    abbr: 'v',
    help: 'Enable verbose output',
    negatable: false,
  );
}

@freezed
abstract class GlobalOptions with _$GlobalOptions {
  const factory GlobalOptions._internal({
    required bool verbose,
    required String? directory,
  }) = _GlobalOptions;

  factory GlobalOptions({required String? directory, required bool verbose}) {
    return GlobalOptions._internal(directory: directory, verbose: verbose);
  }

  factory GlobalOptions.fromArgResults(ArgResults results) {
    return GlobalOptions(
      directory: results.option('directory'),
      verbose: results.flag('verbose'),
    );
  }
}
