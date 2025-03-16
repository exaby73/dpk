import 'package:args/args.dart';
import 'package:dpm/utils/global_args.dart' show GlobalOptions, addGlobalArgs;
import 'package:dpm/utils/string_extensions.dart';

void addGlobalPubArgs(ArgParser parser) {
  addGlobalArgs(parser);

  parser.addFlag(
    'verbose',
    abbr: 'v',
    help: 'Enable verbose output',
    negatable: false,
  );

  parser.addFlag(
    'color',
    help:
        'Use colors in terminal output\n'
        'Defaults to color when connected to a terminal, and no-color otherwise.',
    defaultsTo: null,
  );
}

List<String> buildGlobalArgs(PubOptions options) {
  return [
    if (options.verbose) '--verbose',
    if (options.directory?.isNotEmpty == true) ...['-C', options.directory!],
    if (options.color != null) options.color! ? '--color' : '--no-color',
  ];
}

base class PubOptions extends GlobalOptions {
  final bool verbose;
  final bool? color;

  PubOptions({
    required super.debug,
    required super.directory,
    required super.cacheDir,
    required this.verbose,
    required this.color,
  });

  @override
  String toString() {
    return '''
    PubOptions(
      debug: $debug,
      directory: $directory,
      cacheDir: $cacheDir,
      verbose: $verbose,
      color: $color,
    )
    '''.trimIndents();
  }

  bool get isVerbose => debug || verbose;
}
