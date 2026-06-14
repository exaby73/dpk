import 'dart:io';

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

  parser.addFlag(
    'debug',
    help: 'Enable debug output',
    negatable: false,
    hide: true,
  );
}

String? extractDirectoryArg(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--') {
      return null;
    }

    if (arg == '--directory' || arg == '-C') {
      return i + 1 < args.length ? args[i + 1] : null;
    }

    if (arg.startsWith('--directory=')) {
      return arg.substring('--directory='.length);
    }

    if (arg.startsWith('-C') && arg.length > 2) {
      return arg.substring(2);
    }
  }

  return null;
}

@freezed
abstract class GlobalOptions with _$GlobalOptions {
  factory GlobalOptions({
    required String? directory,
    required bool verbose,
    required bool debug,
  }) {
    return GlobalOptions.internal(
      directory: directory,
      verbose: verbose,
      debug: debug,
    );
  }

  const factory GlobalOptions.internal({
    required String? directory,
    required bool verbose,
    required bool debug,
  }) = _GlobalOptions;

  factory GlobalOptions.fromArgResults(ArgResults results) {
    final directoryArg = results.option('directory');
    return GlobalOptions(
      directory: directoryArg != null
          ? Directory(directoryArg).absolute.path
          : null,
      verbose: results.flag('verbose'),
      debug: results.flag('debug'),
    );
  }

  const GlobalOptions._();

  bool get isVerbose => verbose || debug;
}
