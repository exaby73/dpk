# How dpk fits together

dpk wraps `dart pub`. A run parses the command line, loads the project, and hands both to a command, which does its work between its hooks. Most of that work lives in a few modules with small interfaces, and commands are thin. For the words used here, see [`GLOSSARY.md`](../GLOSSARY.md).

## A run, from command line to exit code

`bin/dpk.dart` calls `runDpk` in `lib/core/command_runner.dart`, which:

1. Parses the arguments with `Invocation.parse` (`lib/core/invocation.dart`). dpk options only count before the command, and everything after the command name is kept for the command unchanged. This one rule is why `dpk run test -v` passes `-v` to the script. [ADR 0003](adr/0003-dpk-options-go-before-the-command.md) explains it.
2. Loads the project with `Project.load` (`lib/config/project.dart`) when the command needs one. Help, completion, and the pub commands that work anywhere (such as `global`) skip it.
3. Builds a `DpkContext` (`lib/core/context.dart`) and runs `DpkCommandRunner`, a `CompletionCommandRunner` from `cli_completion` with auto-install turned off.
4. Turns expected failures (`DpkException`, `ProjectException`, `ConfigException`, `RunPlanException`) into `error: <message>` and exit code 1, and usage errors into exit code 64. Anything else reaches `bin/dpk.dart`, which prints it as a bug.

Commands extend `DpkCommand` (`lib/commands/dpk_command.dart`) and receive the context in their constructor. There is no global state, so tests call `runDpk` in-process with a buffered `Console` and a fake `ProcessRunner`.

## The context is the seam to the outside world

`DpkContext` holds the parsed invocation, the project, a `Console` (`lib/core/console.dart`), and a `ProcessRunner` (`lib/core/process_runner.dart`).

- **`Console`** prints dpk's own messages: results to stdout, and errors, warnings, and `> script: command` progress lines to stderr. It decides colors once, from the terminal and `NO_COLOR`.
- **`ProcessRunner`** starts every process dpk depends on: `dart`, `git`, and script shells. `SystemProcessRunner` is the production adapter. It gives interactive commands the terminal (`ProcessStartMode.inheritStdio`), so prompts such as `dart pub publish`'s confirmation work, and it pipes output into the console when the console is not the terminal. While children run, it forwards SIGTERM, waits for them, and exits with `128 + signal`. Tests use a recording fake.

`DpkContext.runDart`, `withHooks`, and `runScript` are the three operations most commands need.

## Projects come from files, not from pub

`Workspace.discover` (`lib/workspace/workspace.dart`) reads pubspecs directly. It finds the current package (the nearest directory with a `pubspec.yaml`), then the nearest ancestor whose `pubspec.yaml` `workspace` list, or `dpk.yaml` `workspace` globs, include it. Reading files avoids a `dart pub workspace list` process on every run, works before the first `dart pub get`, and needs no particular root package name.

`Project.load` adds the config. It reads the root `dpk.yaml`, checks the `version` constraint first so a newer config reports a version mismatch instead of unknown keys, then parses the rest with `DpkConfig.parse` (`lib/config/dpk_config.dart`). A workspace package's own `dpk.yaml` can add or override scripts and nothing else.

Parsing goes through `ConfigReader` (`lib/config/config_reader.dart`). Every typed read reports problems with the file, line, column, and key path, and unknown keys get a did-you-mean suggestion. Deprecated camelCase keys parse with a warning, and `migrateConfig` (`lib/config/config_migration.dart`) renames them in place during `dpk get` by replacing only the key text, so comments survive.

## Hooks run through one module

`HookLifecycle` (`lib/scripts/hook_lifecycle.dart`) runs a hook target between its hooks: `before`, `pre:<target>`, the target, `post:<target>`, `after`, or the `get` order, where `before` follows the target. It handles `run_hooks_from` and stops at the first failure.

The lifecycle also owns the `HookStack`. Every process dpk starts inherits `DPK_HOOK_STACK`, the hooks of the current lifecycle keyed by workspace root. A nested `dpk` skips any hook already on the stack. That one rule stops a hook that calls `dpk run` from looping, and makes an `all: true` hook run once even when a script starts `dpk` in every workspace package.

## Scripts: plan first, then execute

`planRun` (`lib/scripts/run_plan.dart`) is a pure function. From the workspace, `run_in_packages`, and `--filter`, it picks the packages: the current package by default, matches by name or path glob otherwise, never duplicates, and an error when nothing matches. For `--dependency-order`, it also records the dependencies between the chosen packages and rejects cycles.

`ScriptExecutor` (`lib/scripts/script_executor.dart`) carries out a plan. One package runs with the terminal attached. Several packages run with piped output, each line prefixed with the package name, under the concurrency limit, with fail-fast and dependency order. It reads each output stream to the end before printing the summary, and returns the exit code of the first failed package.

Scripts run in `/bin/sh`, or `cmd.exe` on Windows (`lib/core/shell.dart`). [ADR 0002](adr/0002-scripts-run-in-a-fixed-shell.md) explains why dpk does not use the user's shell.

## `dpk get` plans every file change before writing

`planPubspecUpdates` (`lib/catalog/pubspec_updates.dart`) computes every pubspec change in memory: the root `workspace` list from the `dpk.yaml` globs, the catalog, and sorting. `dpk get --check` and `--dry-run` report the plan and write nothing. Otherwise, `writePubspecUpdates` writes each changed file to a temporary file and renames it into place.

Two pure text-to-text functions do the editing:

- `applyCatalog` (`lib/catalog/catalog_application.dart`) applies the catalog to one pubspec through `yaml_edit`, so the rest of the file keeps its formatting. It skips writes that would not change a value, which keeps it idempotent, and marks catalog dependencies with `# Configured via catalog`.
- `sortPubspec` (`lib/utils/pubspec_sorter.dart`) reorders whole blocks of source lines, found from YAML node spans, and never re-renders a value. It checks that the result parses to the same data and returns the input unchanged when it cannot sort safely.

## Project mode and patches

In project mode, `Project.pubEnvironment` sets `PUB_CACHE` to the project cache for pub commands and scripts. `ProjectCache` (`lib/patching/project_cache.dart`) owns everything about it:

- **Baseline**: a git repository over the cache's `hosted/` folder, committed by dpk with its own identity (`lib/patching/git.dart`). New package folders pub downloads are added to the baseline automatically.
- **Generate**: stages everything under a package, diffs the staged changes against the baseline with `--binary`, and writes one patch per package. Only `*.patch` files under `hosted/` and `git/` in the patch directory are ever written or removed.
- **Apply**: checks each patch against the lockfile version, skips patches that are already applied (`git apply --reverse --check`), and reports stale or conflicting patches with the command that fixes them.

`dpk get` and the pub commands that change resolution call `ProjectCache.sync`, which updates the baseline and applies every patch. [ADR 0001](adr/0001-project-mode-uses-a-project-cache.md) explains why patching works this way.

## Releases

`ConventionalCommit` (`lib/release/conventional_commit.dart`) parses commit subjects and maps them to a version bump with Dart's pre-1.0 rules. `planRelease` (`lib/release/release_plan.dart`) is pure: from each package's commits and the workspace constraints, it picks new versions, raises constraints that no longer allow a new version, and renders changelog entries. `ReleaseCommand` (`lib/commands/release_command.dart`) does the I/O: git log and tags in the user's repository with the user's own git identity, file edits, and pub server queries for `release publish`.

## Generated code is committed

`build_runner` generates two committed files:

- `lib/constants/pubspec.g.dart` holds the package version that the version check and `dpk --version` use.
- `lib/constants/embedded_dpk_skill.g.dart` embeds `skills/dpk/SKILL.md`, so `dpk skills` works from an installed binary.

Because both are compiled in, a stale build ships the wrong version or old skill text. The `before` hook in this repository's `dpk.yaml` rebuilds on `dpk get`, `dpk run analyze`, and `dpk run publish` to prevent that.
