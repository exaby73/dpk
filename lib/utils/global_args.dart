import 'package:args/args.dart';
import 'package:dpm/utils/string_extensions.dart';

void addGlobalArgs(ArgParser parser) {
  parser.addFlag(
    'debug',
    help: 'Enable debug output',
    negatable: false,
    hide: true,
  );

  parser.addFlag(
    'verbose',
    abbr: 'v',
    help: 'Enable verbose output',
    negatable: false,
  );

  parser.addOption(
    'directory',
    abbr: 'C',
    help: 'Directory to run the subcommand in',
  );

  parser.addFlag(
    'color',
    help:
        'Use colors in terminal output\n'
        'Defaults to color when connected to a terminal, and no-color otherwise.',
    defaultsTo: null,
  );

  parser.addOption(
    'cache-dir',
    abbr: 'd',
    defaultsTo: 'pub_packages',
    help: 'Directory to store dependencies',
  );
}

List<String> buildGlobalArgs(PubOptions options) {
  return [
    if (options.verbose) '--verbose',
    if (options.directory?.isNotEmpty == true) ...['-C', options.directory!],
    if (options.color != null) options.color! ? '--color' : '--no-color',
  ];
}

base class PubOptions {
  final bool debug;
  final bool verbose;
  final String? directory;
  final bool? color;
  final String cacheDir;

  PubOptions({
    required this.debug,
    required this.verbose,
    required this.directory,
    required this.color,
    required this.cacheDir,
  });

  @override
  String toString() {
    return '''
    PubOptions(
      debug: $debug,
      verbose: $verbose,
      directory: $directory,
      color: $color,
      cacheDir: $cacheDir,
    )
    '''.trimIndents();
  }

  bool get isVerbose => debug || verbose;
}
