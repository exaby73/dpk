import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/mixins/hook_runner_mixin.dart';
import 'package:dpk/core/mixins/process_handler_mixin.dart';
import 'package:dpk/core/mixins/pub_env_mixin.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:dpk/utils/globals/global_pub_args.dart';
import 'package:logging/logging.dart';

const pubPassthroughCommandDefinitions = [
  PubCommandDefinition(
    name: 'add',
    description: 'Add dependencies to `pubspec.yaml`',
  ),
  PubCommandDefinition(
    name: 'bump',
    description: 'Increase the version number of the current package',
  ),
  PubCommandDefinition(
    name: 'cache',
    description: 'Work with the system cache',
  ),
  PubCommandDefinition(name: 'deps', description: 'Print package dependencies'),
  PubCommandDefinition(
    name: 'downgrade',
    description:
        "Downgrade the current package's dependencies to oldest versions",
  ),
  PubCommandDefinition(
    name: 'global',
    description: 'Work with global packages',
  ),
  PubCommandDefinition(name: 'login', description: 'Log into pub.dev'),
  PubCommandDefinition(name: 'logout', description: 'Log out of pub.dev'),
  PubCommandDefinition(
    name: 'outdated',
    description: 'Analyze dependency versions',
  ),
  PubCommandDefinition(
    name: 'publish',
    description: 'Publish the current package',
  ),
  PubCommandDefinition(
    name: 'remove',
    description: 'Remove dependencies from `pubspec.yaml`',
  ),
  PubCommandDefinition(
    name: 'token',
    description: 'Manage authentication tokens for hosted pub repositories',
  ),
  PubCommandDefinition(
    name: 'unpack',
    description: 'Download a package without adding it as a dependency',
  ),
  PubCommandDefinition(
    name: 'upgrade',
    description: 'Upgrade dependencies',
    aliases: ['update'],
  ),
  PubCommandDefinition(
    name: 'workspace',
    description: 'Work with the current workspace',
  ),
];

final _pubPassthroughCommandNames = {
  for (final definition in pubPassthroughCommandDefinitions) definition.name,
};

final class PubCommandDefinition {
  final String name;
  final String description;
  final List<String> aliases;

  const PubCommandDefinition({
    required this.name,
    required this.description,
    this.aliases = const [],
  });
}

final class PubPassthroughCommand extends Command<int>
    with ConfigMixin, PubEnvMixin, ProcessHandlerMixin, HookRunnerMixin {
  final String commandName;
  final String commandDescription;
  final List<String> commandAliases;

  @override
  final ArgParser argParser = ArgParser.allowAnything();

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  List<String> get aliases => commandAliases;

  final logger = Logger('pub.passthrough');

  PubPassthroughCommand({
    required this.commandName,
    required this.commandDescription,
    this.commandAliases = const [],
  }) {
    if (!_pubPassthroughCommandNames.contains(commandName)) {
      throw ArgumentError.value(
        commandName,
        'commandName',
        'Must be a supported dart pub passthrough command',
      );
    }
  }

  PubPassthroughCommand.fromDefinition(PubCommandDefinition definition)
    : this(
        commandName: definition.name,
        commandDescription: definition.description,
        commandAliases: definition.aliases,
      );

  @override
  Future<int> run() async {
    final parsed = _parsePassthroughArguments(argResults!.rest);
    final options = parsed.options;
    final isHelpRequest =
        parsed.pubArguments.contains('--help') ||
        parsed.pubArguments.contains('-h');

    if (isHelpRequest) {
      return runDartProcess(
        arguments: ['pub', commandName, ...parsed.pubArguments],
      );
    }

    final targetDirectory =
        options.globalOptions.directory ?? config.workingDirectory;
    final arguments = [
      'pub',
      ...buildGlobalArgs(options),
      commandName,
      ...parsed.pubArguments,
    ];

    final beforeHookExitCode = await runBeforeHook(
      commandName: commandName,
      globalOptions: options.globalOptions,
    );
    if (beforeHookExitCode != 0) {
      return beforeHookExitCode;
    }

    final preHookExitCode = await runPreHook(
      commandName: commandName,
      globalOptions: options.globalOptions,
    );
    if (preHookExitCode != 0) {
      return preHookExitCode;
    }

    if (options.globalOptions.isVerbose) {
      logger.info('Running: dart ${arguments.join(' ')}');
    }

    final exitCode = await runDartProcess(
      arguments: arguments,
      workingDirectory: targetDirectory,
      environment: getCacheEnv(options.cacheDir),
    );
    if (exitCode != 0) {
      return exitCode;
    }

    final postHookExitCode = await runPostHook(
      commandName: commandName,
      globalOptions: options.globalOptions,
    );
    if (postHookExitCode != 0) {
      return postHookExitCode;
    }

    final afterHookExitCode = await runAfterHook(
      commandName: commandName,
      globalOptions: options.globalOptions,
    );
    return afterHookExitCode;
  }

  ({GlobalPubOptions options, List<String> pubArguments})
  _parsePassthroughArguments(List<String> arguments) {
    final globalOptions = GlobalOptions.fromArgResults(globalResults!);
    var directory = globalOptions.directory;
    var verbose = globalOptions.verbose;
    var debug = globalOptions.debug;
    var cacheDir = globalResults!.option('cache-dir')!;
    bool? color;
    final pubArguments = <String>[];

    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];

      if (argument == '--directory' || argument == '-C') {
        if (i + 1 >= arguments.length) {
          throw UsageException('Option "$argument" requires a value.', usage);
        }
        directory = _normalizeDirectory(arguments[++i]);
        continue;
      }

      if (argument.startsWith('--directory=')) {
        directory = _normalizeDirectory(
          argument.substring('--directory='.length),
        );
        continue;
      }

      if (argument.startsWith('-C') && argument.length > 2) {
        directory = _normalizeDirectory(argument.substring(2));
        continue;
      }

      if (argument == '--cache-dir' || argument == '-d') {
        if (i + 1 >= arguments.length) {
          throw UsageException('Option "$argument" requires a value.', usage);
        }
        cacheDir = arguments[++i];
        continue;
      }

      if (argument.startsWith('--cache-dir=')) {
        cacheDir = argument.substring('--cache-dir='.length);
        continue;
      }

      if (argument.startsWith('-d') && argument.length > 2) {
        cacheDir = argument.substring(2);
        continue;
      }

      if (argument == '--verbose' || argument == '-v') {
        verbose = true;
        continue;
      }

      if (argument == '--debug') {
        debug = true;
        continue;
      }

      if (argument == '--color') {
        color = true;
        continue;
      }

      if (argument == '--no-color') {
        color = false;
        continue;
      }

      pubArguments.add(argument);
    }

    return (
      options: GlobalPubOptions(
        globalOptions: GlobalOptions(
          directory: directory,
          verbose: verbose,
          debug: debug,
        ),
        cacheDir: cacheDir,
        color: color,
      ),
      pubArguments: pubArguments,
    );
  }

  String _normalizeDirectory(String directory) {
    return Directory(directory).absolute.path;
  }
}
