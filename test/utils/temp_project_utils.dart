import 'dart:io';

import 'package:dpk/config/data/dpk_config.dart';
import 'package:path/path.dart';

Directory createTempProjectDir() {
  final tempDir = Directory.systemTemp.createTempSync();
  final projectDir = Directory(join(tempDir.path, 'temp_project'));
  projectDir.createSync(recursive: true);
  return projectDir;
}

extension TempProject on Directory {
  void initializeTestProject({
    bool withDpkYaml = false,
    DpkMode mode = DpkMode.global,
  }) {
    final pubspecYaml = _makePubspecYaml();
    final pubspecYamlFile = File(join(path, 'pubspec.yaml'));
    pubspecYamlFile.writeAsStringSync(pubspecYaml);

    if (withDpkYaml) {
      final dpkYaml = _makeDpkYaml(mode);
      final dpkYamlFile = File(join(path, 'dpk.yaml'));
      dpkYamlFile.writeAsStringSync(dpkYaml);
    }
  }
}

String _makePubspecYaml() {
  return '''
name: temp_project
dependencies:
  luthor: 0.6.0
''';
}

String _makeDpkYaml(DpkMode mode) {
  return '''
mode: ${mode.name}
''';
}
