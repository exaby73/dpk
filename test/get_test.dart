import 'dart:async';
import 'dart:io';

import 'package:dpk/core/command_runner.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'utils/temp_project_utils.dart';

void main() {
  group('dpk get', () {
    final originalDir = Directory.current;

    setUp(() {
      Directory.current = originalDir.path;
    });

    tearDown(() {
      Directory.current = originalDir.path;
    });

    test('should get a package', () async {
      final runner = DpkCommandRunner.init(['get']);
      final projectDir = createTempProjectDir()..initializeTestProject();

      await runner.runDpk();

      print(Directory(join(projectDir.path)).listSync());
      expect(
        File(
          join(projectDir.path, '.dart_tool/package_config.json'),
        ).existsSync(),
        isTrue,
      );
    });
  });
}
