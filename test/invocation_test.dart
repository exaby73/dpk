import 'package:args/command_runner.dart';
import 'package:dpk/core/invocation.dart';
import 'package:test/test.dart';

void main() {
  group('Given a command line with dpk options before the command', () {
    late Invocation invocation;

    setUp(() {
      invocation = Invocation.parse([
        '-C',
        'packages/a',
        '--cache-dir=.cache',
        '-v',
        '--no-color',
        'run',
        'test',
      ]);
    });

    test('Then dpk keeps its own options', () {
      expect(invocation.directory, equals('packages/a'));
      expect(invocation.cacheDirectory, equals('.cache'));
      expect(invocation.verbose, isTrue);
      expect(invocation.color, isFalse);
    });

    test('Then the command and its arguments are split off', () {
      expect(invocation.command, equals('run'));
      expect(invocation.commandArguments, equals(['test']));
    });
  });

  group('Given options after the command name', () {
    late Invocation invocation;

    setUp(() {
      invocation = Invocation.parse([
        'run',
        'test',
        '-v',
        '--help',
        '--version',
        '-C',
        'x',
        '--coverage',
      ]);
    });

    test('Then every option belongs to the command', () {
      expect(
        invocation.commandArguments,
        equals(['test', '-v', '--help', '--version', '-C', 'x', '--coverage']),
      );
    });

    test('Then dpk does not take any of them', () {
      expect(invocation.verbose, isFalse);
      expect(invocation.help, isFalse);
      expect(invocation.version, isFalse);
      expect(invocation.directory, isNull);
    });
  });

  group('Given the short -C form with an attached value', () {
    test('Then the directory is read from it', () {
      expect(Invocation.parse(['-Cpackages/a', 'get']).directory, 'packages/a');
    });
  });

  group('Given an unknown option before the command', () {
    test('Then parsing fails with a usage error that explains the rule', () {
      expect(
        () => Invocation.parse(['--coverage', 'run', 'test']),
        throwsA(
          isA<UsageException>().having(
            (e) => e.message,
            'message',
            contains('dpk options go before the command'),
          ),
        ),
      );
    });
  });

  group('Given -C without a value', () {
    test('Then parsing fails with a usage error', () {
      expect(() => Invocation.parse(['-C']), throwsA(isA<UsageException>()));
    });
  });

  group('Given commands that work without a project', () {
    test('Then they do not need a project', () {
      for (final command in [
        'help',
        'init',
        'skills',
        'completion',
        'global',
        'login',
        'logout',
        'token',
        'cache',
        'unpack',
      ]) {
        expect(
          Invocation.parse([command]).needsProject,
          isFalse,
          reason: command,
        );
      }
    });

    test('Then project commands still need one', () {
      for (final command in ['get', 'run', 'add', 'patch', 'exec', 'list']) {
        expect(
          Invocation.parse([command]).needsProject,
          isTrue,
          reason: command,
        );
      }
    });

    test('Then a dpk-level help request never needs a project', () {
      expect(Invocation.parse(['--help', 'run']).needsProject, isFalse);
    });
  });

  group('Given dpk --help followed by a command', () {
    test('Then the runner gets --help first so it shows that command', () {
      expect(
        Invocation.parse(['--help', 'run']).runnerArguments,
        equals(['--help', 'run']),
      );
    });
  });
}
