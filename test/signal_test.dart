@TestOn('!windows')
@Timeout(Duration(minutes: 2))
library;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given a long-running script that records SIGTERM', () {
    setUp(() async {
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec('_', extra: 'workspace:\n  - packages/a\n  - packages/b\n'),
        ),
        d.file('dpk.yaml', '''
version: $versionConstraint
scripts:
  wait: &wait >-
    trap 'echo "\$DPK_PACKAGE_NAME" >> "\$DPK_ROOT/terminated.log"; exit 0' TERM;
    touch "\$DPK_ROOT/ready-\$DPK_PACKAGE_NAME";
    sleep 30 & wait
  wait_all:
    command: *wait
    run_in_packages: [packages/*]
'''),
        d.dir('packages', [
          d.dir('a', [
            d.file(
              'pubspec.yaml',
              pubspec('a', extra: 'resolution: workspace\n'),
            ),
          ]),
          d.dir('b', [
            d.file(
              'pubspec.yaml',
              pubspec('b', extra: 'resolution: workspace\n'),
            ),
          ]),
        ]),
      ]).create();
    });

    group('When dpk is sent SIGTERM while one script runs', () {
      late int exitCode;

      setUp(() async {
        exitCode = await _terminateWhenReady(['run', 'wait'], ready: ['_']);
      });

      test('Then the script receives SIGTERM', () {
        expect(_terminated(), equals(['_']));
      });

      test('Then dpk exits with 143', () {
        expect(exitCode, equals(143));
      });
    });

    group('When dpk is sent SIGTERM while scripts run in several packages', () {
      late int exitCode;

      setUp(() async {
        exitCode = await _terminateWhenReady(
          ['run', 'wait_all'],
          ready: ['a', 'b'],
        );
      });

      test('Then every script receives SIGTERM', () {
        expect(_terminated()..sort(), equals(['a', 'b']));
      });

      test('Then dpk exits with 143', () {
        expect(exitCode, equals(143));
      });
    });
  });
}

/// Starts the real dpk executable, waits until each package in [ready] has
/// written its ready file, sends SIGTERM to dpk, and returns dpk's exit code.
Future<int> _terminateWhenReady(
  List<String> arguments, {
  required List<String> ready,
}) async {
  final process = await Process.start(Platform.resolvedExecutable, [
    p.join(Directory.current.path, 'bin', 'dpk.dart'),
    ...arguments,
  ], workingDirectory: d.path('repo'));
  unawaited(process.stdout.drain<void>());
  unawaited(process.stderr.drain<void>());

  final deadline = DateTime.now().add(const Duration(seconds: 60));
  while (!ready.every(
    (name) => File(d.path('repo/ready-$name')).existsSync(),
  )) {
    if (DateTime.now().isAfter(deadline)) {
      process.kill(ProcessSignal.sigkill);
      fail('The scripts never started.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  process.kill();
  return process.exitCode.timeout(const Duration(seconds: 20));
}

List<String> _terminated() {
  final log = File(d.path('repo/terminated.log'));
  return log.existsSync() ? log.readAsLinesSync() : const [];
}
