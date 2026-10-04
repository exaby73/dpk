# AGENTS.md

dpk is a Dart CLI that wraps `dart pub`. Read `GLOSSARY.md` before you name a domain concept. Read `docs/architecture.md` before you change how commands, config, or workspaces fit together.

## Rules

- Add dependencies with `dpk add`. When you need a pub option that dpk lacks, add first-class support for it. Use `--` only as a stopgap.
- Cover every CLI change with tests written with the `gwt-tester` skill. Build package and workspace fixtures with `test_descriptor`, and run dpk in-process with `dpk()` from `test/utils/dpk_test_utils.dart`. Pass a `RecordingProcessRunner` when the test only needs to know which `dart` or script commands dpk would run.
- To read a dependency's source, use the `pub-package-explorer` skill.
- Format project paths only: `dart format bin lib test tool`. `examples/monorepo` runs in project mode, so `dart format .` also reformats its project cache.
- Write commit messages and PR titles with the `git-committer` skill.

## Gotchas

- After you change `pubspec.yaml` or `skills/dpk/SKILL.md`, run `dpk run build` and commit the generated files. `dpk get`, `dpk run analyze`, and `dpk run publish` run the build for you through the `before` hook.
- `skills/dpk/SKILL.md` is the only source for the dpk skill. dpk embeds it in the binary, and `dpk get` reinstalls the copy in `.agents/skills/dpk`.
- dpk refuses to run when its own version is outside `version` in `dpk.yaml`. When you move the package version out of that range, update this repo's `dpk.yaml` and `examples/monorepo/dpk.yaml` in the same change. Tests build their `version` from the running dpk, so they need no change.
- Commands get everything through the `DpkContext` passed to their constructor. Keep it that way: global state breaks the in-process tests.
- Scripts run in `/bin/sh`, so test scripts must be POSIX shell.

## Agent skills

### Issue tracker

Issues live in GitHub Issues for `exaby73/dpk`, managed with `gh`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
