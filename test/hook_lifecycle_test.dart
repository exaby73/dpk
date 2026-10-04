import 'package:dpk/config/dpk_config.dart';
import 'package:dpk/core/console.dart';
import 'package:dpk/scripts/hook_lifecycle.dart';
import 'package:test/test.dart';

void main() {
  const root = '/workspace';

  group('Given scripts with every kind of hook for build', () {
    final scripts = _scripts([
      const Script(name: 'before', command: 'b', hookTargets: ['build']),
      const Script(name: 'pre:build', command: 'p'),
      const Script(name: 'post:build', command: 'q'),
      const Script(name: 'after', command: 'a', all: true),
    ]);

    group('When running build in the standard order', () {
      late List<String> calls;
      late HookStack actionStack;

      setUp(() async {
        calls = [];
        await _lifecycle(scripts, calls).run('build', (stack) async {
          calls.add('build');
          actionStack = stack;
          return 0;
        });
      });

      test('Then hooks run before, pre, target, post, after', () {
        expect(
          calls,
          equals(['before', 'pre:build', 'build', 'post:build', 'after']),
        );
      });

      test(
        'Then the target sees every hook of this lifecycle on its stack',
        () {
          expect(actionStack.contains(root, 'before'), isTrue);
          expect(actionStack.contains(root, 'after'), isTrue);
          expect(actionStack.contains(root, 'pre:build'), isTrue);
        },
      );
    });

    test(
      'When running in the get order then before runs after the target',
      () async {
        final calls = <String>[];
        final getScripts = _scripts([
          const Script(name: 'before', command: 'b', hookTargets: ['get']),
          const Script(name: 'pre:get', command: 'p'),
          const Script(name: 'post:get', command: 'q'),
        ]);

        await _lifecycle(getScripts, calls).run('get', (stack) async {
          calls.add('get');
          return 0;
        }, order: HookOrder.beforeAfterTarget);

        expect(calls, equals(['pre:get', 'get', 'before', 'post:get']));
      },
    );

    test('When the pre hook fails then nothing after it runs', () async {
      final calls = <String>[];

      final exitCode =
          await _lifecycle(scripts, calls, exitCodes: {'pre:build': 3}).run(
            'build',
            (stack) async {
              calls.add('build');
              return 0;
            },
          );

      expect(exitCode, equals(3));
      expect(calls, equals(['before', 'pre:build']));
    });
  });

  group('Given a watch script that uses the hooks of build', () {
    final scripts = _scripts([
      const Script(name: 'before', command: 'b', hookTargets: ['watch']),
      const Script(name: 'pre:build', command: 'p'),
      const Script(name: 'pre:watch', command: 'p'),
      const Script(name: 'post:watch', command: 'q'),
      const Script(name: 'post:build', command: 'q'),
    ]);

    test(
      'When running watch then both hook sets run, with build outside',
      () async {
        final calls = <String>[];

        await _lifecycle(scripts, calls).run('watch', (stack) async {
          calls.add('watch');
          return 0;
        }, hooksFrom: 'build');

        expect(
          calls,
          equals([
            'before',
            'pre:build',
            'pre:watch',
            'watch',
            'post:watch',
            'post:build',
          ]),
        );
      },
    );
  });

  group('Given a hook stack from a parent dpk process', () {
    final scripts = _scripts([
      const Script(name: 'before', command: 'b', all: true),
      const Script(name: 'pre:test', command: 'p'),
    ]);

    test(
      'When the parent ran before then the child skips it but runs its own hooks',
      () async {
        final calls = <String>[];

        await _lifecycle(
          scripts,
          calls,
          stack: const HookStack().adding(root, ['before']),
        ).run('test', (stack) async {
          calls.add('test');
          return 0;
        });

        expect(calls, equals(['pre:test', 'test']));
      },
    );

    test(
      'When the stack is from another project then nothing is skipped',
      () async {
        final calls = <String>[];

        await _lifecycle(
          scripts,
          calls,
          stack: const HookStack().adding('/other', ['before', 'pre:test']),
        ).run('test', (stack) async {
          calls.add('test');
          return 0;
        });

        expect(calls, equals(['before', 'pre:test', 'test']));
      },
    );
  });

  group('Given an encoded hook stack', () {
    test('Then it survives a trip through the environment', () {
      final stack = const HookStack().adding(root, ['before', 'pre:x']);

      final decoded = HookStack.fromEnvironment(stack.toEnvironment());

      expect(decoded.contains(root, 'before'), isTrue);
      expect(decoded.contains(root, 'pre:x'), isTrue);
      expect(decoded.contains(root, 'after'), isFalse);
    });
  });
}

Map<String, Script> _scripts(List<Script> scripts) => {
  for (final script in scripts) script.name: script,
};

HookLifecycle _lifecycle(
  Map<String, Script> scripts,
  List<String> calls, {
  Map<String, int> exitCodes = const {},
  HookStack stack = const HookStack(),
}) => HookLifecycle(
  scripts: scripts,
  rootPath: '/workspace',
  stack: stack,
  console: Console.buffered(),
  runHook: (hook, stack) async {
    calls.add(hook.name);
    return exitCodes[hook.name] ?? 0;
  },
);
