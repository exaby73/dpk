import 'package:dpk/config/data/dependency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

part 'catalog.freezed.dart';

@freezed
abstract class Catalog with _$Catalog {
  const factory Catalog({
    Map<String, VersionConstraint?>? environment,
    Version? version,
    String? publishTo,
    Uri? homepage,
    Uri? repository,
    Uri? issueTracker,
    List<String>? topics,
    String? documentation,
    List<String>? funding,
    Map<String, Object?>? platforms,
    String? resolution,
    Map<String, Dependency>? dependencies,
  }) = _Catalog;

  factory Catalog.fromYaml(YamlMap yaml) {
    final environment = _extractEnvironment(yaml['environment'] as YamlMap?);
    final dependencies = _extractDependencies(yaml['dependencies'] as YamlMap?);
    final version = yaml['version'] as String?;
    final publishTo = yaml['publish_to'] as String?;
    final homepage = yaml['homepage'] as String?;
    final repository = yaml['repository'] as String?;
    final issueTracker = yaml['issue_tracker'] as String?;
    final topics = (yaml['topics'] as YamlList?)?.cast<String>();
    final documentation = yaml['documentation'] as String?;
    final funding = (yaml['funding'] as YamlList?)?.cast<String>();
    final platforms = (yaml['platforms'] as YamlMap?)?.cast<String, Object?>();
    final resolution = yaml['resolution'] as String?;

    return Catalog(
      environment: environment,
      version: version != null ? Version.parse(version) : null,
      dependencies: dependencies,
      publishTo: publishTo,
      homepage: homepage != null ? Uri.parse(homepage) : null,
      repository: repository != null ? Uri.parse(repository) : null,
      issueTracker: issueTracker != null ? Uri.parse(issueTracker) : null,
      topics: topics,
      documentation: documentation,
      funding: funding,
      platforms: platforms,
      resolution: resolution,
    );
  }

  static Map<String, Dependency>? _extractDependencies(YamlMap? yaml) {
    if (yaml == null) {
      return null;
    }

    return parseDeps(yaml);
  }

  static Map<String, VersionConstraint?>? _extractEnvironment(YamlMap? yaml) {
    if (yaml == null) {
      return null;
    }

    return yaml.cast<String, String>().map((key, value) {
      return MapEntry(key, VersionConstraint.parse(value));
    });
  }
}
