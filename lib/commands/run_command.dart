import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/config/config.dart';
import 'package:dpm/config/data/config_data.dart';
import 'package:dpm/core/config_mixin.dart';
import 'package:dpm/core/shell.dart';
import 'package:dpm/core/types.dart';
import 'package:dpm/utils/globals/global_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prompts/prompts.dart' as prompts;

part 'run_command.freezed.dart';

final class RunCommand extends Command with ConfigMixin {
  @override
  String get name => 'run';

  @override
  String get description => 'Run a script';

  RunCommand() {
    addGlobalArgs(argParser);
  }

  @override
  Future<void> run() async {
    final options = RunOptions.fromArgResults(argResults!);
    options.script ??= _promptForScript();

    final runner = DpmScriptRunner(
      config: config,
      options: options,
      arguments: argResults!.rest,
    );

    final exitCode = await runner.run();

    exit(exitCode);
  }

  String _promptForScript() {
    final scriptNames = config.scripts.scripts.keys.toList();
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

final class DpmScriptRunner {
  final ConfigData config;
  final RunOptions options;
  final List<String> arguments;

  DpmScriptRunner({
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

    if (config.scripts.scripts.containsKey(options.script)) {
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
    final script = config.scripts.scripts[options.script];
    final scriptExists = script != null;

    if (!scriptExists && skipIfMissing) {
      return 0;
    }

    if (scriptExists) {
      if (script.command.isEmpty) {
        throw StateError('Script command is empty');
      }

      final command = script.command.trim();

      final finalScript = [
        command,
        if (arguments.length > 1) ...['--', ...arguments.sublist(1)],
      ];

      final process = await Process.start(
        getShell(),
        ['-c', finalScript.join(' ')],
        runInShell: true,
        workingDirectory: options.globalOptions.directory,
      );

      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);

      return process.exitCode;
    }

    final process = await Process.start(
      'dart',
      ['run', ...arguments],
      runInShell: true,
      workingDirectory: options.globalOptions.directory,
    );
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);

    return process.exitCode;
  }

  (IntCallback?, IntCallback?) _getHooks({
    required ConfigData config,
    required RunOptions options,
    required List<String> arguments,
  }) {
    final script = config.scripts.scripts[options.script];
    final hooks = commandToHookMapper[script?.runHooksFrom ?? options.script];
    if (hooks == null) {
      return (null, null);
    }

    IntCallback? preHookCallback;
    IntCallback? postHookCallback;

    final (preHook, postHook) = hooks;

    if (config.scripts.scripts.containsKey(preHook.name)) {
      preHookCallback =
          () => _runScript(
            config: config,
            options: options.copyWith(script: preHook.name),
            arguments: [],
          );
    }

    if (config.scripts.scripts.containsKey(postHook.name)) {
      postHookCallback =
          () => _runScript(
            config: config,
            options: options.copyWith(script: postHook.name),
            arguments: [],
          );
    }

    return (preHookCallback, postHookCallback);
  }
}
