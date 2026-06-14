import 'dart:io';
import 'dart:isolate';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

final class SkillsCommand extends Command<int> {
  @override
  String get name => 'skills';

  @override
  String get description => 'Print detailed dpk usage guidance for AI agents';

  @override
  Future<int> run() async {
    final skillText = await _loadSkillText();
    // ignore: avoid_print
    print(skillText.trimRight());
    return 0;
  }

  Future<String> _loadSkillText() async {
    for (final file in await _candidateSkillFiles()) {
      if (file.existsSync()) {
        return file.readAsString();
      }
    }

    return _fallbackSkillText;
  }

  Future<List<File>> _candidateSkillFiles() async {
    final candidates = <File>[];

    final packageUri = await Isolate.resolvePackageUri(
      Uri.parse('package:dpk/commands/skills_command.dart'),
    );
    if (packageUri != null && packageUri.isScheme('file')) {
      final packageFile = File.fromUri(packageUri);
      final packageRoot = path.dirname(
        path.dirname(path.dirname(packageFile.path)),
      );
      candidates.add(File(path.join(packageRoot, 'skills', 'dpk', 'SKILL.md')));
    }

    final scriptFile = File.fromUri(Platform.script);
    final scriptDir = scriptFile.parent.path;
    candidates
      ..add(File(path.join(scriptDir, '..', 'skills', 'dpk', 'SKILL.md')))
      ..add(File(path.join(scriptDir, '..', '..', 'skills', 'dpk', 'SKILL.md')))
      ..add(
        File(path.join(Directory.current.path, 'skills', 'dpk', 'SKILL.md')),
      );

    return candidates;
  }
}

const _fallbackSkillText = '''
# dpk Skill

The bundled `skills/dpk/SKILL.md` file could not be found, so dpk cannot print
the full agent guide from this installation.

Check that the installed package includes `skills/dpk/SKILL.md`, or run
`dpk skills` from a source checkout that contains that file.
''';
