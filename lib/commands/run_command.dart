import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/config/data/config_data.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/shell.dart';
import 'package:dpk/core/types.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:dpk/utils/terminal_title.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glob/glob.dart';
import 'package:prompts/prompts.dart' as prompts;

part 'run_command.freezed.dart';

final class RunCommand extends Command<int> with ConfigMixin {
  @override
  String get name => 'run';

  @override
  String get description => 'Run a script';

  RunCommand() {
    addGlobalArgs(argParser);
    _registerScriptSubcommands();
  }

  void _registerScriptSubcommands() {
    final scripts = config.scripts?.scriptsMap;
    if (scripts != null) {
      for (final scriptName in scripts.keys) {
        addSubcommand(ScriptSubCommand(
          scriptName: scriptName,
          config: config,
        ));
      }
    }
  }

  @override
  Future<int> run() async {
    // If a sub-command was called, it will be handled by the ScriptSubCommand
    // This method only handles the fallback case for backward compatibility
    final options = RunOptions.fromArgResults(argResults!);
    options.script ??= _promptForScript();

    final runner = DpkScriptRunner(
      config: config,
      options: options,
      arguments: argResults!.rest.skip(1).toList(),
    );

    return await runner.run();
  }

  String _promptForScript() {
    final scriptNames = config.scripts?.scriptsMap.keys.toList();
    if (scriptNames == null) {
      throw StateError('No scripts found');
    }

    final scriptName = prompts.choose(
      'Which script do you want to run?',
      scriptNames,
      chevron: false,
      interactive: false,
    );

    if (scriptName == null) {
      throw StateError('Script name is required');
    }

    return scriptName;
  }
}

@unfreezed
abstract class RunOptions with _$RunOptions {
  factory RunOptions({
    required GlobalOptions globalOptions,
    required String? script,
  }) = _RunOptions;

  factory RunOptions.fromArgResults(ArgResults results) {
    return RunOptions(
      globalOptions: GlobalOptions.fromArgResults(results),
      script: results.rest.firstOrNull,
    );
  }
}

final class ScriptSubCommand extends Command<int> {
  final String scriptName;
  final ConfigData config;

  ScriptSubCommand({
    required this.scriptName,
    required this.config,
  });

  @override
  String get name => scriptName;

  @override
  String get description {
    final script = config.scripts?.scriptsMap[scriptName];
    return script?.command ?? 'Run $scriptName script';
  }

  @override
  Future<int> run() async {
    final options = RunOptions(
      globalOptions: GlobalOptions.fromArgResults(globalResults!),
      script: scriptName,
    );

    final runner = DpkScriptRunner(
      config: config,
      options: options,
      arguments: argResults!.rest,
    );

    return await runner.run();
  }
}

final class DpkScriptRunner {
  final ConfigData config;
  final RunOptions options;
  final List<String> arguments;

  DpkScriptRunner({
    required this.config,
    required this.options,
    required this.arguments,
  });

  Future<int> run({
    /// If true, the script will be skipped if it is not found in the config.
    bool skipIfMissing = false,
  }) async {
    assert(options.script != null, 'Script name is required');

    IntCallback? preHook;
    IntCallback? postHook;

    if (config.scripts?.scriptsMap.containsKey(options.script) == true) {
      (preHook, postHook) = _getHooks(
        config: config,
        options: options,
        arguments: arguments,
      );
    }

    final preHookExitCode = await preHook?.call();
    if (preHookExitCode != null && preHookExitCode != 0) {
      return preHookExitCode;
    }

    final exitCode = await _runScript(
      config: config,
      options: options,
      arguments: arguments,
      skipIfMissing: skipIfMissing,
    );
    if (exitCode != 0) {
      return exitCode;
    }

    final postHookExitCode = await postHook?.call();
    return postHookExitCode ?? 0;
  }

  Future<int> _runScript({
    required ConfigData config,
    required RunOptions options,
    required List<String> arguments,
    bool skipIfMissing = false,
  }) async {
    final script = config.scripts?.scriptsMap[options.script];
    final scriptExists = script != null;

    if (scriptExists && options.script != null) {
      setTerminalTitle('dpk run ${options.script}');
    }

    if (!scriptExists && skipIfMissing) {
      return 0;
    }

    if (scriptExists) {
      final packagesToRunInGlobs = script.runInPackages;
      late final bool hasToRunMultiple;
      final packagesToRunIn = <String>[];

      final workspace = config.pubspec.workspace;
      if (packagesToRunInGlobs != null && workspace == null) {
        throw StateError(
          'No workspace packages configured, '
          'but you have runInPackages configured',
        );
      }

      if (packagesToRunInGlobs == null) {
        hasToRunMultiple = false;
      } else if (packagesToRunInGlobs.isEmpty) {
        hasToRunMultiple = false;
      } else {
        for (final pattern in packagesToRunInGlobs) {
          final glob = Glob(pattern);
          for (final package in workspace!) {
            if (glob.matches(package)) {
              packagesToRunIn.add(package);
            }
          }
        }
        hasToRunMultiple = packagesToRunIn.length > 1;
      }

      if (script.command.isEmpty) {
        throw StateError('Script command is empty');
      }

      final command = script.command.trim();

      final finalScript = [
        command,
        if (arguments.isNotEmpty) ...arguments,
      ];

      if (hasToRunMultiple) {
        final processExitCodesFutures = <Future<int>>[];
        final stdoutStream = StreamController<List<int>>();
        final stderrStream = StreamController<List<int>>();

        for (final package in packagesToRunIn) {
          final process = await Process.start(
            getShell(),
            ['-c', finalScript.join(' ')],
            runInShell: true,
            workingDirectory: package,
            environment: script.env,
          );

          process.stdout.transform(utf8.decoder).listen((event) {
            final prefix = '[$package]: ';
            final logLines = event.split('\n');
            for (int i = 1; i < logLines.length; i++) {
              final originalLogLine = logLines[i];
              if (originalLogLine.trim().isEmpty) {
                continue;
              }
              logLines[i] = originalLogLine.padLeft(
                originalLogLine.length + prefix.length,
              );
            }
            stdoutStream.add('$prefix${logLines.join('\n')}'.codeUnits);
          });
          process.stderr.transform(utf8.decoder).listen((event) {
            stderrStream.add('[$package]: $event'.codeUnits);
          });

          processExitCodesFutures.add(process.exitCode);
        }

        stdout.addStream(stdoutStream.stream);
        stderr.addStream(stderrStream.stream);

        final processExitCodes = await Future.wait(processExitCodesFutures);
        return processExitCodes.fold(
          0,
          (previousValue, element) {
            return previousValue == 0 ? element : previousValue;
          },
        );
      }

      final process = await Process.start(
        getShell(),
        ['-c', finalScript.join(' ')],
        runInShell: true,
        workingDirectory: packagesToRunIn.isNotEmpty
            ? packagesToRunIn.first
            : options.globalOptions.directory,
        environment: script.env,
      );

      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);

      return process.exitCode;
    }

    // If we get here, the script doesn't exist in dpk.yaml
    final availableScripts = config.scripts?.scriptsMap.keys.toList() ?? [];
    throw StateError('Script "${options.script}" not found in dpk.yaml.\n'
        'Available scripts: ${availableScripts.isEmpty ? 'none' : availableScripts.join(', ')}');
  }

  (IntCallback?, IntCallback?) _getHooks({
    required ConfigData config,
    required RunOptions options,
    required List<String> arguments,
  }) {
    final script = config.scripts?.scriptsMap[options.script];
    final commandName = script?.runHooksFrom ?? options.script;

    if (commandName == null) {
      return (null, null);
    }

    final preHookName = 'pre:$commandName';
    final postHookName = 'post:$commandName';

    IntCallback? preHookCallback;
    IntCallback? postHookCallback;

    if (config.scripts?.scriptsMap.containsKey(preHookName) == true) {
      preHookCallback = () => _runScript(
            config: config,
            options: options.copyWith(script: preHookName),
            arguments: [],
          );
    }

    if (config.scripts?.scriptsMap.containsKey(postHookName) == true) {
      postHookCallback = () => _runScript(
            config: config,
            options: options.copyWith(script: postHookName),
            arguments: [],
          );
    }

    return (preHookCallback, postHookCallback);
  }
}
