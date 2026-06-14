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
---
name: dpk
description: Use dpk to manage Dart pub workflows, scripts, hooks, project caches, catalogs, patches, and dpk-specific CLI behavior.
---

# dpk Skill

Use this skill when an AI agent needs to operate the `dpk` CLI for an end user.

Run `dpk skills` to print this guide from the CLI. The command is configless, so it works outside a configured dpk workspace.

## Core Commands

- `dpk init` creates `dpk.yaml`.
- `dpk skills` prints detailed CLI guidance for agents.
- `dpk get` runs the dpk-aware dependency fetch flow.
- `dpk run <script>` runs a configured script.
- `dpk patch init`, `dpk patch generate`, and `dpk patch apply` manage package patches in project cache mode.
- `dpk add`, `dpk remove`, `dpk upgrade`, `dpk downgrade`, `dpk outdated`, and other supported pub commands pass through to `dart pub`.

## Scripts and Hooks

Define scripts in `dpk.yaml` under `scripts`. Run scripts with `dpk run <name>`. To call one dpk script from another, write `dpk run <other-script>` inside the script command.

Use `pre:<command>` and `post:<command>` to wrap specific commands. Use `before` and `after` script definitions with either `scripts: [...]` or `all: true` to run shared hooks around matching scripts. For `dpk get`, matching `before` hooks run after `pub get` succeeds so build-style hooks have dependencies available. Recursive before/after hooks are skipped to avoid infinite hook loops.

## Project Cache and Patches

Set `mode: project` in `dpk.yaml` to use a local `pub_packages` cache. Patch commands require project cache mode. Use `dpk patch apply --force` only when it is acceptable to discard dirty package-cache changes before applying saved patches.
''';
