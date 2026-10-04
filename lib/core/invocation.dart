import 'package:args/command_runner.dart';

/// Commands that work outside a dpk project.
const projectlessCommands = {
  'help',
  'init',
  'skills',
  'completion',
  'install-completion-files',
  'uninstall-completion-files',
  'cache',
  'global',
  'login',
  'logout',
  'token',
  'unpack',
};

/// One dpk command line, split into dpk's own options, the command, and the
/// arguments that belong to the command.
///
/// dpk's own options only count before the command name. Everything after the
/// command name belongs to the command, so `dpk run test -v` passes `-v` to
/// the `test` script, and `dpk add http -C x` passes `-C x` to `dart pub add`.
final class Invocation {
  const Invocation({
    this.directory,
    this.cacheDirectory,
    this.verbose = false,
    this.quiet = false,
    this.color,
    this.help = false,
    this.version = false,
    this.command,
    this.commandArguments = const [],
  });

  /// Parses [arguments] as typed after `dpk`.
  ///
  /// Throws a [UsageException] for an unknown option before the command.
  factory Invocation.parse(List<String> arguments) {
    String? directory;
    String? cacheDirectory;
    var verbose = false;
    var quiet = false;
    bool? color;
    var help = false;
    var version = false;

    var index = 0;
    String takeValue(String option) {
      if (index + 1 >= arguments.length) {
        throw UsageException('Option "$option" needs a value.', usageHint);
      }
      index++;
      return arguments[index];
    }

    while (index < arguments.length) {
      final argument = arguments[index];
      if (argument == '--') {
        index++;
        break;
      }
      if (!argument.startsWith('-') || argument == '-') {
        break;
      }

      switch (argument) {
        case '-C' || '--directory':
          directory = takeValue(argument);
        case '--cache-dir':
          cacheDirectory = takeValue(argument);
        case '-v' || '--verbose':
          verbose = true;
        case '-q' || '--quiet':
          quiet = true;
        case '--color':
          color = true;
        case '--no-color':
          color = false;
        case '-h' || '--help':
          help = true;
        case '--version':
          version = true;
        case _ when argument.startsWith('--directory='):
          directory = argument.substring('--directory='.length);
        case _ when argument.startsWith('--cache-dir='):
          cacheDirectory = argument.substring('--cache-dir='.length);
        case _ when argument.startsWith('-C') && argument.length > 2:
          directory = argument.substring(2);
        default:
          throw UsageException(
            'Unknown option "$argument". dpk options go before the command, '
            'and options after the command belong to the command.',
            usageHint,
          );
      }
      index++;
    }

    final command = index < arguments.length ? arguments[index] : null;
    return Invocation(
      directory: directory,
      cacheDirectory: cacheDirectory,
      verbose: verbose,
      quiet: quiet,
      color: color,
      help: help,
      version: version,
      command: command,
      commandArguments: command == null
          ? const []
          : arguments.sublist(index + 1),
    );
  }

  static const usageHint = 'Run "dpk help" to see dpk options and commands.';

  /// The `-C` directory, if given.
  final String? directory;

  /// The `--cache-dir` value, if given.
  final String? cacheDirectory;
  final bool verbose;
  final bool quiet;
  final bool? color;
  final bool help;
  final bool version;

  /// The command name, such as `run` or `get`. `null` when only dpk options
  /// were given.
  final String? command;

  /// Every argument after [command], unchanged.
  final List<String> commandArguments;

  /// Whether the command can only run inside a dpk project.
  bool get needsProject =>
      command != null && !help && !projectlessCommands.contains(command);

  /// The arguments to hand to the `args` command runner: the command and its
  /// arguments, with `--help` in front when it was given as a dpk option.
  List<String> get runnerArguments => [
    if (help) '--help',
    ?command,
    ...commandArguments,
  ];
}
