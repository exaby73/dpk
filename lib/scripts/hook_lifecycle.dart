import 'package:dpk/config/dpk_config.dart';
import 'package:dpk/core/console.dart';

/// Hooks that are running or have run in this tree of dpk processes.
///
/// dpk passes the stack to child processes in [variable]. A nested `dpk`
/// call skips any hook on the stack, so a hook that calls `dpk run` cannot
/// loop, and a shared hook runs once even when a script starts `dpk` again in
/// each workspace package.
final class HookStack {
  const HookStack([this.entries = const {}]);

  factory HookStack.fromEnvironment(Map<String, String> environment) {
    final encoded = environment[variable];
    if (encoded == null || encoded.isEmpty) {
      return const HookStack();
    }
    return HookStack(encoded.split(_separator).toSet());
  }

  static const variable = 'DPK_HOOK_STACK';
  static const _separator = '\n';

  /// Entries in the form `<workspace root>#<hook name>`, so hooks in another
  /// project are never mistaken for these.
  final Set<String> entries;

  bool contains(String rootPath, String hook) =>
      entries.contains('$rootPath#$hook');

  HookStack adding(String rootPath, Iterable<String> hooks) =>
      HookStack({...entries, for (final hook in hooks) '$rootPath#$hook'});

  Map<String, String> toEnvironment() =>
      entries.isEmpty ? const {} : {variable: entries.join(_separator)};
}

/// Where the `before` hook runs relative to the hook target.
enum HookOrder {
  /// `before`, `pre:<target>`, the target, `post:<target>`, `after`.
  standard,

  /// `pre:<target>`, the target, `before`, `post:<target>`, `after`. Used by
  /// `dpk get`, because `before` work such as code generation needs resolved
  /// packages.
  beforeAfterTarget,
}

/// Runs a hook target with every hook that applies to it.
final class HookLifecycle {
  HookLifecycle({
    required this.scripts,
    required this.rootPath,
    required this.stack,
    required this.runHook,
    required this.console,
  });

  final Map<String, Script> scripts;
  final String rootPath;
  final HookStack stack;
  final Console console;

  /// Runs one hook script. [stack] is the stack its processes inherit.
  final Future<int> Function(Script hook, HookStack stack) runHook;

  /// Runs [action] for [target] between its hooks, and returns the first
  /// non-zero exit code, or 0.
  ///
  /// With [hooksFrom], the target also uses the hooks of that script:
  /// `pre:<hooksFrom>` runs before `pre:<target>`, and `post:<target>` runs
  /// before `post:<hooksFrom>`. Shared hooks run once when they apply to
  /// either name.
  ///
  /// [action] receives the stack that its child processes should inherit.
  Future<int> run(
    String target,
    Future<int> Function(HookStack stack) action, {
    String? hooksFrom,
    HookOrder order = HookOrder.standard,
  }) async {
    if (isHookName(target)) {
      return action(stack);
    }

    final names = {?hooksFrom, target}.toList();
    Script? shared(String name) {
      final hook = scripts[name];
      return hook != null && names.any(hook.appliesTo) ? hook : null;
    }

    final before = shared('before');
    final after = shared('after');
    final pre = [for (final name in names) ?scripts['pre:$name']];
    final post = [for (final name in names.reversed) ?scripts['post:$name']];

    final all = [?before, ...pre, ...post, ?after];
    final childStack = stack.adding(rootPath, all.map((hook) => hook.name));

    final sequence = <Future<int> Function()>[
      if (order == HookOrder.standard) ...[
        if (before != null) () => _runHook(before, childStack),
        for (final hook in pre) () => _runHook(hook, childStack),
        () => action(childStack),
      ] else ...[
        for (final hook in pre) () => _runHook(hook, childStack),
        () => action(childStack),
        if (before != null) () => _runHook(before, childStack),
      ],
      for (final hook in post) () => _runHook(hook, childStack),
      if (after != null) () => _runHook(after, childStack),
    ];

    for (final step in sequence) {
      final exitCode = await step();
      if (exitCode != 0) {
        return exitCode;
      }
    }
    return 0;
  }

  Future<int> _runHook(Script hook, HookStack childStack) {
    if (stack.contains(rootPath, hook.name)) {
      console.detail(
        'Skipping hook "${hook.name}": it already ran in a parent dpk process.',
      );
      return Future.value(0);
    }
    return runHook(hook, childStack);
  }
}
