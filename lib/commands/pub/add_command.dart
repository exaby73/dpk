import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/utils/global_pub_args.dart';
import 'package:dpm/utils/string_extensions.dart';

final class PubAddCommand extends Command {
  @override
  String name = 'add';

  @override
  String get description =>
      '''
Add dependencies to `pubspec.yaml`.

Invoking `dart pub add foo bar` will add `foo` and `bar` to `pubspec.yaml`
with a default constraint derived from latest compatible version.

Add to dev_dependencies by prefixing with "dev:".

Make dependency overrides by prefixing with "override:".

Add packages with specific constraints or other sources by giving a descriptor
after a colon.

For example:
  * Add a hosted dependency at newest compatible stable version:
    `dart pub add foo`
  * Add a hosted dev dependency at newest compatible stable version:
    `dart pub add dev:foo`
  * Add a hosted dependency with the given constraint
    `dart pub add foo:^1.2.3`
  * Add multiple dependencies:
    `dart pub add foo dev:bar`
  * Add a path dependency:
    `dart pub add 'foo:{"path":"../foo"}'`
  * Add a hosted dependency:
    `dart pub add 'foo:{"hosted":"my-pub.dev"}'`
  * Add an sdk dependency:
    `dart pub add 'foo:{"sdk":"flutter"}'`
  * Add a git dependency:
    `dart pub add 'foo:{"git":"https://github.com/foo/foo"}'`
  * Add a dependency override:
    `dart pub add 'override:foo:1.0.0'`
  * Add a git dependency with a path and ref specified:
    `dart pub add \\
      'foo:{"git":{"url":"../foo.git","ref":"<branch>","path":"<subdir>"}}'`
'''.trimIndents();

  PubAddCommand() {
    addGlobalPubArgs(argParser);
    argParser.addFlag(
      'offline',
      help: 'Use cached packages instead of accessing the network',
    );
    argParser.addFlag(
      'dry-run',
      abbr: 'n',
      help: 'Report what dependencies would change but don\'t change any',
    );
    argParser.addFlag(
      'precompile',
      help: 'Build executables in immediate dependencies',
    );
  }

  @override
  Future<void> run() async {
    final options = _PubGetOptions.fromArgResults(argResults!);
    final arguments = [
      'pub',
      ...buildGlobalArgs(options),
      'add',
      if (options.offline) '--offline',
      if (options.dryRun) '--dry-run',
      if (options.precompile) '--precompile',
      ...argResults!.rest,
    ];

    if (options.isVerbose) {
      print('Running: dart ${arguments.join(' ')}');
    }

    final pubProcess = await Process.start(
      'dart',
      arguments,
      environment: {'PUB_CACHE': options.cacheDir},
    );

    pubProcess.stdout.transform(utf8.decoder).listen((data) {
      stdout.write(data);
    });

    pubProcess.stderr.transform(utf8.decoder).listen((data) {
      stderr.write(data);
    });

    final exitCode = await pubProcess.exitCode;

    exit(exitCode);
  }
}

final class _PubGetOptions extends PubOptions {
  final bool offline;
  final bool dryRun;
  final bool precompile;

  _PubGetOptions({
    required super.debug,
    required super.directory,
    required super.cacheDir,
    required super.patchDir,
    required super.verbose,
    required super.color,

    required this.offline,
    required this.dryRun,
    required this.precompile,
  });

  factory _PubGetOptions.fromArgResults(ArgResults results) {
    return _PubGetOptions(
      debug: results.flag('debug'),
      directory: results.option('directory'),
      cacheDir: results.option('cache-dir')!,
      patchDir: results.option('patch-dir')!,
      verbose: results.flag('verbose'),
      color: results['color'] as bool?,
      offline: results.flag('offline'),
      dryRun: results.flag('dry-run'),
      precompile: results.flag('precompile'),
    );
  }

  @override
  String toString() {
    return '''
    PubGetOptions(
      debug: $debug,
      directory: $directory,
      cacheDir: $cacheDir,
      patchDir: $patchDir,
      verbose: $verbose,
      color: $color,
      offline: $offline,
      dryRun: $dryRun,
      precompile: $precompile,
    )
    '''.trimIndents();
  }
}
