import 'dart:convert';

import 'package:args/args.dart';
import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/patching/project_cache.dart';
import 'package:dpk/utils/terminal_title.dart';

/// A `dart pub` command that dpk forwards.
final class PubCommandDefinition {
  const PubCommandDefinition({
    required this.name,
    required this.description,
    this.aliases = const [],
    this.category = CommandCategory.pub,
    this.changesResolution = false,
  });

  final String name;
  final String description;
  final List<String> aliases;
  final String category;

  /// Whether the command can change the resolved packages, so the project
  /// cache needs a sync afterwards.
  final bool changesResolution;
}

const pubPassthroughCommandDefinitions = [
  PubCommandDefinition(
    name: 'add',
    description: 'Add dependencies to pubspec.yaml.',
    category: CommandCategory.dependencies,
    changesResolution: true,
  ),
  PubCommandDefinition(
    name: 'remove',
    description: 'Remove dependencies from pubspec.yaml.',
    category: CommandCategory.dependencies,
    changesResolution: true,
  ),
  PubCommandDefinition(
    name: 'upgrade',
    description: 'Upgrade dependencies to their latest versions.',
    aliases: ['update'],
    category: CommandCategory.dependencies,
    changesResolution: true,
  ),
  PubCommandDefinition(
    name: 'downgrade',
    description: 'Downgrade dependencies to their oldest versions.',
    category: CommandCategory.dependencies,
    changesResolution: true,
  ),
  PubCommandDefinition(
    name: 'outdated',
    description: 'Show dependencies with newer versions.',
    category: CommandCategory.dependencies,
  ),
  PubCommandDefinition(
    name: 'deps',
    description: 'Print the dependency graph.',
    category: CommandCategory.dependencies,
  ),
  PubCommandDefinition(
    name: 'bump',
    description: 'Increase the version of the current package.',
  ),
  PubCommandDefinition(
    name: 'publish',
    description: 'Publish the current package to pub.dev.',
  ),
  PubCommandDefinition(
    name: 'workspace',
    description: 'Work with the pub workspace.',
  ),
  PubCommandDefinition(name: 'cache', description: 'Work with the pub cache.'),
  PubCommandDefinition(
    name: 'global',
    description: 'Work with global packages.',
  ),
  PubCommandDefinition(
    name: 'unpack',
    description: 'Download a package without adding it as a dependency.',
  ),
  PubCommandDefinition(name: 'login', description: 'Log in to pub.dev.'),
  PubCommandDefinition(name: 'logout', description: 'Log out of pub.dev.'),
  PubCommandDefinition(
    name: 'token',
    description: 'Manage tokens for hosted pub repositories.',
  ),
];

/// Forwards its arguments to `dart pub <name>`, between its hooks.
final class PubPassthroughCommand extends DpkCommand {
  PubPassthroughCommand(super.context, this.definition);

  final PubCommandDefinition definition;

  @override
  final ArgParser argParser = ArgParser.allowAnything();

  @override
  String get name => definition.name;

  @override
  String get description => definition.description;

  @override
  List<String> get aliases => definition.aliases;

  @override
  String get category => definition.category;

  @override
  bool get takesArguments => true;

  @override
  String get invocation => 'dpk $name [arguments]';

  @override
  void printUsage() => console.info(
    '$description\n\nUsage: $invocation\n\n'
    'dpk passes every argument to "dart pub $name". Run "dpk $name --help" '
    'to see its options.',
  );

  @override
  Future<int> run() async {
    var arguments = argResults!.rest;
    if (arguments.contains('--help') || arguments.contains('-h')) {
      console.info('dpk $name passes its arguments to dart pub $name.\n');
      return context.runDart(['pub', name, ...arguments]);
    }

    if (name == 'add') {
      arguments = _withCatalogVersions(arguments);
    }

    final project = context.project;
    return withTerminalTitle(
      console,
      'dpk $name',
      () => context.withHooks(name, (stack) async {
        final exitCode = await context.runDart(
          ['pub', ...context.pubFlags, name, ...arguments],
          useProjectCache: name != 'global',
          environment: stack.toEnvironment(),
        );
        if (exitCode != 0 ||
            !definition.changesResolution ||
            project == null ||
            !project.isProjectMode) {
          return exitCode;
        }
        return ProjectCache.forProject(project, context).sync();
      }),
    );
  }

  /// Gives `dpk add <package>` the catalog's version when the package is in
  /// the catalog and no version was given.
  List<String> _withCatalogVersions(List<String> arguments) {
    final catalog = context.project?.config.catalog?.dependencies;
    if (catalog == null || catalog.isEmpty) {
      return arguments;
    }
    return [
      for (final argument in arguments)
        if (argument.startsWith('-'))
          argument
        else
          _withCatalogVersion(argument, catalog),
    ];
  }

  String _withCatalogVersion(String argument, Map<String, Object?> catalog) {
    final prefix = RegExp(r'^(dev:|override:)?').stringMatch(argument)!;
    final package = argument.substring(prefix.length);
    if (package.contains(':') || !catalog.containsKey(package)) {
      return argument;
    }
    final value = catalog[package];
    final descriptor = switch (value) {
      null => 'any',
      String() => value,
      _ => jsonEncode(value),
    };
    console.step('> Using the catalog version of $package: $descriptor');
    return '$prefix$package:$descriptor';
  }
}
