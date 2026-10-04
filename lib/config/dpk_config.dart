import 'package:dpk/config/config_reader.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

enum DpkMode { global, project }

/// The contents of a workspace root's `dpk.yaml`.
final class DpkConfig {
  const DpkConfig({
    required this.version,
    this.mode = DpkMode.global,
    this.sortPubspec = false,
    this.workspace,
    this.cacheDir,
    this.patchDir = 'patches',
    this.catalog,
    this.scripts = const {},
    this.warnings = const [],
  });

  static const keys = [
    'version',
    'mode',
    'sort_pubspec',
    'workspace',
    'cache_dir',
    'patch_dir',
    'catalog',
    'scripts',
  ];

  /// Keys that a workspace package's own `dpk.yaml` may contain.
  static const packageKeys = ['version', 'scripts'];

  /// Old key names that `dpk get` migrates.
  static const legacyKeys = {'sortPubspec': 'sort_pubspec'};

  /// Reads only the `version` constraint, so a version mismatch is reported
  /// before anything else in the file.
  static VersionConstraint parseVersion(ConfigReader reader) {
    final raw = reader.requiredString('version');
    try {
      return VersionConstraint.parse(raw);
    } on FormatException {
      throw reader.valueError(
        'version',
        '"$raw" is not a version constraint. Use one like ^1.0.0.',
      );
    }
  }

  factory DpkConfig.parse(ConfigReader reader) {
    if (reader.has('dpk')) {
      throw reader.error(
        'The nested "dpk:" mapping is no longer supported. Move its keys to '
        'the top level of the file.',
        key: 'dpk',
      );
    }
    reader.checkKeys([...keys, ...legacyKeys.keys], suggestions: keys);
    _warnLegacy(reader, legacyKeys);

    final modeName = reader.string('mode') ?? 'global';
    final mode = DpkMode.values.where((m) => m.name == modeName).firstOrNull;
    if (mode == null) {
      throw reader.valueError(
        'mode',
        '"$modeName" is not a mode. Use "global" or "project".',
      );
    }

    final scriptsReader = reader.child('scripts');
    final scripts = scriptsReader == null
        ? const <String, Script>{}
        : Script.parseAll(scriptsReader);
    final catalogReader = reader.child('catalog');
    final catalog = catalogReader == null ? null : Catalog.parse(catalogReader);

    for (final child in [?scriptsReader, ?catalogReader]) {
      reader.adoptWarnings(child);
    }

    return DpkConfig(
      version: parseVersion(reader),
      mode: mode,
      sortPubspec:
          reader.boolean('sort_pubspec') ??
          reader.boolean('sortPubspec') ??
          false,
      workspace: reader.stringList('workspace'),
      cacheDir: reader.string('cache_dir'),
      patchDir: reader.string('patch_dir') ?? 'patches',
      catalog: catalog,
      scripts: scripts,
      warnings: List.unmodifiable(reader.warnings),
    );
  }

  final VersionConstraint version;
  final DpkMode mode;
  final bool sortPubspec;

  /// Globs that select workspace packages.
  final List<String>? workspace;

  /// The project cache directory, relative to the workspace root.
  final String? cacheDir;

  /// The patch directory, relative to the workspace root.
  final String patchDir;
  final Catalog? catalog;
  final Map<String, Script> scripts;
  final List<ConfigWarning> warnings;
}

/// Parses the scripts of a workspace package's own `dpk.yaml`, which may only
/// contain `version` and `scripts`.
({Map<String, Script> scripts, List<ConfigWarning> warnings})
parsePackageConfig(ConfigReader reader, {required String rootConfigPath}) {
  for (final key in reader.map.keys) {
    if (DpkConfig.packageKeys.contains(key)) {
      continue;
    }
    if (DpkConfig.keys.contains(key) || DpkConfig.legacyKeys.containsKey(key)) {
      throw reader.error(
        '"$key" is only allowed in the workspace root config. Move it to '
        '$rootConfigPath.',
        key: key,
      );
    }
  }
  reader.checkKeys(DpkConfig.packageKeys);
  final scriptsReader = reader.child('scripts');
  if (scriptsReader == null) {
    return (scripts: const {}, warnings: const []);
  }
  final scripts = Script.parseAll(scriptsReader);
  return (scripts: scripts, warnings: scriptsReader.warnings);
}

void _warnLegacy(ConfigReader reader, Map<String, String> legacy) {
  for (final MapEntry(key: old, value: replacement) in legacy.entries) {
    if (reader.has(old)) {
      reader.warn(
        '"${reader.keyPath(old)}" is deprecated. Rename it to '
        '"$replacement"; "dpk get" does this for you.',
        key: old,
      );
    }
  }
}

/// A script, hook, or shared hook defined under `scripts`.
final class Script {
  const Script({
    required this.name,
    required this.command,
    this.description,
    this.env = const {},
    this.envFile,
    this.runInPackages,
    this.runHooksFrom,
    this.hookTargets,
    this.all = false,
    this.concurrency,
    this.failFast,
    this.dependencyOrder,
  });

  static const keys = [
    'command',
    'description',
    'env',
    'env_file',
    'run_in_packages',
    'run_hooks_from',
    'scripts',
    'all',
    'concurrency',
    'fail_fast',
    'dependency_order',
  ];

  static const legacyKeys = {
    'runInPackages': 'run_in_packages',
    'runHooksFrom': 'run_hooks_from',
  };

  static Map<String, Script> parseAll(ConfigReader reader) {
    final scripts = <String, Script>{};
    for (final MapEntry(key: keyNode, value: valueNode)
        in reader.map.nodes.entries) {
      final name = (keyNode as YamlNode).value;
      if (name is! String || name.trim().isEmpty) {
        throw ConfigException(
          'Script names must be text.',
          span: SourceSpanLike.of(keyNode),
          file: reader.file,
        );
      }
      scripts[name] = Script._parse(name, valueNode, reader);
    }

    for (final script in scripts.values) {
      final from = script.runHooksFrom;
      if (from != null && !scripts.containsKey(from) && !_isKnownTarget(from)) {
        final suggestion = closestMatch(from, scripts.keys);
        throw ConfigException(
          'scripts.${script.name}.run_hooks_from: no script named "$from".'
          '${suggestion == null ? '' : ' Did you mean "$suggestion"?'}',
          file: reader.file,
        );
      }
    }
    return scripts;
  }

  /// Whether [name] is a built-in command that hooks can target.
  static bool _isKnownTarget(String name) => const {
    'get',
    'add',
    'remove',
    'upgrade',
    'downgrade',
    'outdated',
    'deps',
    'publish',
    'bump',
    'workspace',
    'cache',
    'global',
    'unpack',
    'login',
    'logout',
    'token',
  }.contains(name);

  factory Script._parse(String name, YamlNode node, ConfigReader parent) {
    final value = node.value;
    if (value is String) {
      if (value.trim().isEmpty) {
        throw parent.valueError(name, 'the command is empty.');
      }
      return Script(name: name, command: value);
    }
    if (value is! YamlMap) {
      throw parent.valueError(
        name,
        'expected a command or a mapping with "command", found '
        '${describe(value)}.',
      );
    }

    final reader = ConfigReader(
      value,
      file: parent.file,
      path: [...parent.path, name],
    );
    reader.checkKeys([...keys, ...legacyKeys.keys], suggestions: keys);
    _warnLegacy(reader, legacyKeys);

    final isHook = isSharedHookName(name);
    for (final key in ['scripts', 'all']) {
      if (!isHook && reader.has(key)) {
        throw reader.error(
          '"$key" only applies to the shared hooks "before" and "after".',
          key: key,
        );
      }
    }
    if (!reader.has('command')) {
      throw reader.error('${reader.keyPath('command')} is required.');
    }

    final script = Script(
      name: name,
      command: reader.requiredString('command'),
      description: reader.string('description'),
      env: reader.stringMap('env') ?? const {},
      envFile: reader.string('env_file'),
      runInPackages:
          reader.stringList('run_in_packages') ??
          reader.stringList('runInPackages'),
      runHooksFrom:
          reader.string('run_hooks_from') ?? reader.string('runHooksFrom'),
      hookTargets: reader.stringList('scripts'),
      all: reader.boolean('all') ?? false,
      concurrency: reader.integer('concurrency'),
      failFast: reader.boolean('fail_fast'),
      dependencyOrder: reader.boolean('dependency_order'),
    );
    parent.adoptWarnings(reader);
    return script;
  }

  final String name;
  final String command;
  final String? description;
  final Map<String, String> env;

  /// A dotenv file, relative to the workspace root. [env] overrides its
  /// variables.
  final String? envFile;

  /// Globs or package names that choose the workspace packages to run in.
  final List<String>? runInPackages;

  /// The script whose hooks this script uses.
  final String? runHooksFrom;

  /// For `before` and `after`: the hook targets they apply to.
  final List<String>? hookTargets;

  /// For `before` and `after`: whether they apply to every hook target.
  final bool all;
  final int? concurrency;
  final bool? failFast;
  final bool? dependencyOrder;

  bool get isHook => isHookName(name);

  /// Whether this shared hook applies to [target].
  bool appliesTo(String target) =>
      all || (hookTargets?.contains(target) ?? false);
}

bool isSharedHookName(String name) => name == 'before' || name == 'after';

bool isHookName(String name) =>
    isSharedHookName(name) ||
    name.startsWith('pre:') ||
    name.startsWith('post:');

/// Shared config for workspace packages, applied by `dpk get`.
final class Catalog {
  const Catalog({
    this.environment,
    this.version,
    this.publishTo,
    this.homepage,
    this.repository,
    this.issueTracker,
    this.documentation,
    this.topics,
    this.funding,
    this.platforms,
    this.resolution,
    this.dependencies,
    this.dependencyOverrides,
  });

  static const keys = [
    'environment',
    'version',
    'publish_to',
    'homepage',
    'repository',
    'issue_tracker',
    'documentation',
    'topics',
    'funding',
    'platforms',
    'resolution',
    'dependencies',
    'dependency_overrides',
  ];

  factory Catalog.parse(ConfigReader reader) {
    reader.checkKeys(keys);

    final environment = reader.stringMap('environment');
    if (environment != null) {
      final environmentReader = reader.child('environment')!;
      for (final MapEntry(:key, :value) in environment.entries) {
        try {
          VersionConstraint.parse(value);
        } on FormatException {
          throw environmentReader.valueError(
            key,
            '"$value" is not a version constraint.',
          );
        }
      }
    }

    final version = reader.string('version');
    if (version != null) {
      try {
        Version.parse(version);
      } on FormatException {
        throw reader.valueError(
          'version',
          '"$version" is not a version. Use one like 1.2.3.',
        );
      }
    }

    final resolution = reader.string('resolution');
    if (resolution != null &&
        !const {'workspace', 'local', 'external'}.contains(resolution)) {
      throw reader.valueError(
        'resolution',
        '"$resolution" is not a resolution. Use "workspace", "local", or '
            '"external".',
      );
    }

    final platforms = reader.map['platforms'];
    if (platforms != null && platforms is! YamlMap) {
      throw reader.valueError(
        'platforms',
        'expected a mapping, found ${describe(platforms)}.',
      );
    }

    return Catalog(
      environment: environment,
      version: version,
      publishTo: reader.string('publish_to'),
      homepage: reader.string('homepage'),
      repository: reader.string('repository'),
      issueTracker: reader.string('issue_tracker'),
      documentation: reader.string('documentation'),
      topics: reader.stringList('topics'),
      funding: reader.stringList('funding'),
      platforms: platforms == null
          ? null
          : toPlain(platforms) as Map<Object?, Object?>,
      resolution: resolution,
      dependencies: _dependencies(reader, 'dependencies'),
      dependencyOverrides: _dependencies(reader, 'dependency_overrides'),
    );
  }

  static Map<String, Object?>? _dependencies(ConfigReader reader, String key) {
    final child = reader.child(key);
    if (child == null) {
      return null;
    }
    final result = <String, Object?>{};
    for (final MapEntry(key: name, value: node) in child.map.nodes.entries) {
      final packageName = (name as YamlNode).value;
      final value = node.value;
      if (packageName is! String) {
        throw ConfigException(
          '${child.keyPath('')}: package names must be text.',
          span: SourceSpanLike.of(name),
          file: reader.file,
        );
      }
      if (value is! String && value is! YamlMap && value != null) {
        throw child.valueError(
          packageName,
          'expected a version constraint or a dependency mapping, found '
          '${describe(value)}.',
        );
      }
      result[packageName] = toPlain(value);
    }
    return result;
  }

  /// Text values such as `^1.0.0` or `"any"`, or maps such as
  /// `{git: {url: ...}}`, written to pubspecs as they appear in `dpk.yaml`.
  final Map<String, Object?>? dependencies;

  /// Overrides written to the workspace root pubspec.
  final Map<String, Object?>? dependencyOverrides;
  final Map<String, String>? environment;
  final String? version;
  final String? publishTo;
  final String? homepage;
  final String? repository;
  final String? issueTracker;
  final String? documentation;
  final List<String>? topics;
  final List<String>? funding;
  final Map<Object?, Object?>? platforms;
  final String? resolution;
}
