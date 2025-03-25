import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/config/config.dart';
import 'package:dpm/config/data/config_data.dart';
import 'package:dpm/core/shell.dart';
import 'package:dpm/core/types.dart';
import 'package:dpm/utils/fs.dart';
import 'package:dpm/utils/globals/global_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_command.freezed.dart';

final class RunCommand extends Command {
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

    final config = loadConfig(getProjectRoot(options.globalOptions.directory));
    final runner = DpmCommandRunner(
      config: config,
      options: options,
      arguments: argResults!.rest,
    );
    final exitCode = await runner.run();

    exit(exitCode);
  }
}

@freezed
abstract class RunOptions with _$RunOptions {
  const factory RunOptions({
    required GlobalOptions globalOptions,
    required String script,
  }) = _RunOptions;

  factory RunOptions.fromArgResults(ArgResults results) {
    if (results.rest.isEmpty) {
      throw StateError('Script name is required');
    }

    return RunOptions(
      globalOptions: GlobalOptions.fromArgResults(results),
      script: results.rest.first,
    );
  }
}

final class DpmCommandRunner {
  final ConfigData config;
  final RunOptions options;
  final List<String> arguments;

  DpmCommandRunner({
    required this.config,
    required this.options,
    required this.arguments,
  });

  Future<int> run({
    /// If true, the script will be skipped if it is not found in the config.
    bool skipIfMissing = false,
  }) async {
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

      process.stdout.transform(utf8.decoder).listen((data) {
        stdout.write(data);
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        stderr.write(data);
      });

      return process.exitCode;
    }

    print('Command: ${arguments.join(' ')}');

    final process = await Process.start(
      'dart',
      ['run', ...arguments],
      runInShell: true,
      workingDirectory: options.globalOptions.directory,
    );
    process.stdout.transform(utf8.decoder).listen((data) {
      stdout.write(data);
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      stderr.write(data);
    });

    return process.exitCode;
  }

  (IntCallback?, IntCallback?) _getHooks({
    required ConfigData config,
    required RunOptions options,
    required List<String> arguments,
  }) {
    final hooks = commandToHookMapper[options.script];
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
