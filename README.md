# dpk

[![pub version](https://img.shields.io/pub/v/dpk.svg)](https://pub.dev/packages/dpk)
[![license](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

dpk is a package manager for Dart. It wraps `dart pub`, so `dpk get`, `dpk add`, and every other pub command work as you know them, and it adds:

- **Scripts and hooks**: named commands in `dpk.yaml`, with dependencies between scripts and hooks that run before and after any script or pub command.
- **Workspace runs**: run a script or any shell command across the packages of a pub workspace, with filters, a concurrency limit, fail-fast, and dependency order.
- **A catalog**: one place for SDK constraints, dependency versions, and package metadata that `dpk get` applies to every workspace package.
- **Dependency patches**: edit a dependency's source, save the edit as a patch file, and have `dpk get` apply it for everyone.
- **Releases**: version packages and write changelogs from Conventional Commits, then publish them in dependency order.

## Contents

- [What's new in 1.0](#whats-new-in-10)
- [Install](#install)
- [Quick start](#quick-start)
- [How dpk reads a command line](#how-dpk-reads-a-command-line)
- [Commands](#commands)
- [Scripts](#scripts)
- [Script dependencies](#script-dependencies)
- [Hooks](#hooks)
- [Run across workspace packages](#run-across-workspace-packages)
- [Workspaces](#workspaces)
- [Catalog](#catalog)
- [Sorting pubspecs](#sorting-pubspecs)
- [Checking in CI](#checking-in-ci)
- [Cleaning build output](#cleaning-build-output)
- [Patching dependencies](#patching-dependencies)
- [Releasing](#releasing)
- [Editor support](#editor-support)
- [Shell completion](#shell-completion)
- [Upgrading to 1.0](#upgrading-to-10)
- [Troubleshooting](#troubleshooting)

## What's new in 1.0

- **Arguments reach your scripts.** Everything after a script name goes to the script, so `dpk run test --coverage` works. See [How dpk reads a command line](#how-dpk-reads-a-command-line).
- **Script dependencies.** `depends_on` runs other scripts first, once per run, and `^build` builds the workspace packages a package depends on. See [Script dependencies](#script-dependencies).
- **Workspace runs with control.** `--filter`, `--concurrency`, `--fail-fast`, and `--dependency-order`, plus `dpk exec` for any shell command and `dpk list` for the workspace packages. See [Run across workspace packages](#run-across-workspace-packages).
- **The same dpk inside scripts.** `dpk` in a script runs the dpk that started it, whether that is an installed binary or `dart run bin/dpk.dart`. See [Scripts](#scripts).
- **Any workspace root name.** dpk finds pub workspaces from their pubspecs, so the root package no longer has to be named `_`. See [Workspaces](#workspaces).
- **A safer catalog.** Environment keys merge, dependency values are written as given, and a package's own `hosted:` source is kept. `dpk catalog outdated` and `upgrade` keep it current. See [Catalog](#catalog).
- **CI checks.** `dpk get --check` fails when the catalog or sorting would change a file. See [Checking in CI](#checking-in-ci).
- **Automatic patches.** `dpk get` applies patches, reports stale ones, and `dpk patch list` and `remove` manage them. See [Patching dependencies](#patching-dependencies).
- **Releases.** `dpk release version` and `dpk release publish` work from Conventional Commits. See [Releasing](#releasing).
- **`dpk clean`.** Removes build output across the workspace. See [Cleaning build output](#cleaning-build-output).
- **`dpk doctor`, a JSON schema, and strict validation.** Typos in `dpk.yaml` are errors with the file, line, and a suggestion. See [Editor support](#editor-support).

Upgrading from 0.x? See [Upgrading to 1.0](#upgrading-to-10).

## Install

dpk needs Dart 3.11 or later. It supports macOS and Linux. Windows support is best effort.

```bash
dart install dpk
```

## Quick start

Create a `dpk.yaml` in your package or workspace root:

```bash
dpk init
```

The file it writes looks like this:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/exaby73/dpk/main/schema/dpk.schema.json
version: ^1.0.0

scripts:
  analyze:
    command: dart analyze
    description: Analyze the code.
  test:
    command: dart test
    description: Run the tests.
```

Get dependencies, list the scripts, and run one:

```bash
dpk get
dpk run
dpk run test --coverage=coverage
```

Every argument after the script name goes to the script, so the last command runs `dart test --coverage=coverage`.

To check a project's setup at any time, run `dpk doctor`.

## How dpk reads a command line

dpk's own options go before the command. Everything after the command belongs to the command:

```bash
dpk -C packages/app run test -v   # -C is dpk's, -v goes to the test script
dpk add http -C packages/app      # -C goes to dart pub add
```

| Option | Meaning |
| --- | --- |
| `-C, --directory <dir>` | Run as if dpk was started in `<dir>`. |
| `--cache-dir <dir>` | Use `<dir>` as the project cache in project mode. |
| `-v, --verbose` | Print what dpk runs, and pass `--verbose` to pub. |
| `-q, --quiet` | Do not print the scripts and hooks dpk runs. |
| `--color`, `--no-color` | Turn colors on or off. By default, colors are on in a terminal unless `NO_COLOR` is set. |
| `--version` | Print the dpk and Dart versions. |

## Commands

| Command | What it does |
| --- | --- |
| `dpk get [--check]` | Applies the catalog and sorting to pubspecs, runs `dart pub get`, and applies patches in project mode. |
| `dpk run [options] <script> [args]` | Runs a script. `dpk run` alone lists the scripts. |
| `dpk exec [options] -- <command>` | Runs a shell command in every workspace package. |
| `dpk list [--graph] [--json]` | Lists the workspace packages. |
| `dpk clean` | Removes `.dart_tool/` and `build/` in every workspace package. |
| `dpk catalog outdated` | Shows catalog dependencies whose constraint excludes the latest version. |
| `dpk catalog upgrade [--major-versions]` | Raises catalog constraints, then runs `dpk get`. |
| `dpk patch <generate\|apply\|list\|remove\|init>` | Manages dependency patches. |
| `dpk release version` | Raises versions and writes changelogs from Conventional Commits. |
| `dpk release publish` | Publishes the packages whose version is not published yet. |
| `dpk init` | Creates a `dpk.yaml`. |
| `dpk doctor` | Checks the dpk setup and reports problems. |
| `dpk skills` | Prints a dpk usage guide for AI agents. |

These pub commands pass every argument to `dart pub` and run their hooks: `add`, `remove`, `upgrade` (alias `update`), `downgrade`, `outdated`, `deps`, `bump`, `publish`, `workspace`, `cache`, `global`, `unpack`, `login`, `logout`, and `token`. In project mode, pub uses the project cache. `global` is the exception: it always uses the global pub cache.

`dpk add <package>` uses the catalog's version when the package is in the catalog and you give no version.

## Scripts

Define scripts under `scripts` in `dpk.yaml`. A script is a shell command, or a mapping with more options:

```yaml
scripts:
  analyze: dart analyze

  test:
    command: dart test
    description: Run the tests.
    env:
      LOG_LEVEL: verbose
    env_file: .env.test
```

| Key | Meaning |
| --- | --- |
| `command` | The shell command. Required in the mapping form. |
| `description` | Shown by `dpk run` when it lists the scripts. |
| `env` | Environment variables. Numbers and booleans become text. |
| `env_file` | A dotenv file of `KEY=value` lines, relative to the workspace root. `env` overrides its values. |
| `depends_on` | Scripts to run first. See [Script dependencies](#script-dependencies). |
| `run_in_packages` | Workspace packages to run in. See [Run across workspace packages](#run-across-workspace-packages). |
| `run_hooks_from` | Also run the hooks of this script or command. |
| `concurrency`, `fail_fast`, `dependency_order` | Defaults for the `--concurrency`, `--fail-fast`, and `--dependency-order` options. |

Scripts run in `/bin/sh`, or `cmd.exe` on Windows, whatever your login shell is, so a script behaves the same for every teammate. dpk appends the arguments after the script name to the end of the command, each quoted for the shell.

`dpk` inside a script runs the same dpk that started the script. dpk puts a small `dpk` launcher first on the script's `PATH`, so a script that calls `dpk run build` never picks up another installed version. This works for an installed binary and for dpk started with `dart run path/to/bin/dpk.dart`.

dpk prints each script and hook it runs to stderr, such as `> test: dart test`. Use `-q` to hide these lines.

Every script gets these environment variables:

| Variable | Value |
| --- | --- |
| `DPK_ROOT` | The workspace root. |
| `DPK_PACKAGE_NAME` | The name of the package the script runs in. |
| `DPK_PACKAGE_PATH` | The path of the package the script runs in. |
| `PUB_CACHE` | The project cache, in project mode only. |

A script runs in the workspace package you start it from. From the workspace root, or a folder that is not inside a workspace package, it runs at the root.

## Script dependencies

`depends_on` lists scripts that run before a script, each with its own hooks and dependencies:

```yaml
scripts:
  codegen: dart run build_runner build -d
  analyze:
    command: dart analyze
    depends_on: [codegen]
  test:
    command: dart test
    depends_on: [codegen]
  check:
    command: echo "All checks passed"
    depends_on: [analyze, test]
```

`dpk run check` runs `codegen` once, then `analyze`, then `test`, then `check`. A dependency runs once per run of dpk, even when several scripts depend on it or a script starts `dpk` again. A failing dependency stops the run.

A name that starts with `^` runs that script in the workspace packages that the script's packages depend on, through `dependencies`, in dependency order:

```yaml
scripts:
  build:
    command: dart run build_runner build -d
    depends_on: [^build]
  test:
    command: dart test
    run_in_packages: [app]
    depends_on: [^build]
```

`dpk run test` builds every workspace package that `app` depends on, dependencies first, then tests `app`. Because `build` also depends on `^build`, running `dpk run build` in one package builds everything it needs.

`depends_on` names must be scripts, not hooks, and a cycle is an error.

## Hooks

A hook is a script that runs around a script or a pub command. The hook target is the script or command it runs around.

- `pre:<name>` and `post:<name>` run directly before and after the hook target `<name>`.
- `before` and `after` are shared hooks. They run around every hook target listed under `scripts`, or around all of them with `all: true`.

```yaml
scripts:
  before:
    command: dpk run build
    scripts: [analyze, publish]
  pre:test: dart run tool/start_server.dart
  post:test: dart run tool/stop_server.dart
  build: dart run build_runner build -d
  watch:
    command: dart run build_runner watch -d
    run_hooks_from: build
```

For most hook targets, the order is `before`, `pre:<name>`, the target, `post:<name>`, `after`. A failing step stops the rest. A script's `depends_on` runs before all of its hooks.

`dpk get` runs `before` after `dart pub get`, because typical `before` work such as code generation needs the packages first. The order for `get` is `pre:get`, `dart pub get`, `before`, `post:get`, `after`.

With `run_hooks_from`, a script also runs the hooks of the script it names. In the example above, `dpk run watch` runs `pre:build` and `post:build` around `pre:watch` and `post:watch`.

Commands and scripts share hook names. If you have a script named `clean`, `pre:clean` runs around both `dpk run clean` and `dpk clean`.

Hooks never run twice in one tree of dpk processes. When a hook calls `dpk run`, or a script starts `dpk` again in each workspace package, the nested dpk skips the hooks that already ran.

## Run across workspace packages

`run_in_packages` selects workspace packages by name, or by a glob over their paths relative to the workspace root. `.` selects the root.

```yaml
scripts:
  test:
    command: dart test
    run_in_packages: [packages/*, app]
```

dpk runs the command in every selected package at once, prefixes each output line with the package name, and prints a summary. It exits with the exit code of the first package that failed. A `run_in_packages` that matches no package is an error, and dpk lists the workspace packages.

Options before the script name change how the packages run:

| Option | Meaning |
| --- | --- |
| `--filter <package>` | Run only in packages with this name or path glob. Repeat it to select more. Without `run_in_packages`, it selects from the whole workspace. |
| `-j, --concurrency <count>` | Run in at most this many packages at once. |
| `--fail-fast` | When one package fails, stop the others and skip the rest. |
| `--dependency-order` | Start a package only after the workspace packages in its `dependencies` have finished. |

```bash
dpk run --filter packages/core --filter app test
dpk run -j 2 --fail-fast test
```

`dpk exec` runs any command the same way, in every workspace package by default:

```bash
dpk exec -- dart format --set-exit-if-changed .
dpk exec --filter 'packages/*' 'dart analyze && dart test'
```

One argument runs as a shell command line. Several arguments run as one command, each quoted.

## Workspaces

dpk works with [pub workspaces](https://dart.dev/tools/pub/workspaces). It finds the workspace root by looking for a `pubspec.yaml` whose `workspace` list includes the current package, so you can run dpk from any folder inside the workspace. The root package can have any name.

Instead of listing every package in the root `pubspec.yaml`, list globs in `dpk.yaml`:

```yaml
workspace:
  - packages/*
  - apps/*
```

`dpk get` writes the matching packages to the root pubspec's `workspace` list. A glob only matches packages whose pubspec has `resolution: workspace`, and never hidden folders or `build/`.

A workspace package can have its own `dpk.yaml` with `version` and `scripts`. Its scripts add to the root's scripts and override those with the same name. Everything else belongs to the root `dpk.yaml`.

## Catalog

The catalog is shared config in the root `dpk.yaml` that `dpk get` applies to the workspace root and every workspace package:

```yaml
catalog:
  environment:
    sdk: ^3.11.0
  version: 1.2.0
  repository: https://github.com/me/repo/tree/main/DPK_PACKAGE_PATH
  topics: [cli]
  dependencies:
    http: ^1.2.0
    luthor:
      git:
        url: https://github.com/exaby73/luthor.git
        path: packages/luthor
```

| Key | Applied to | How |
| --- | --- | --- |
| `environment` | Root and packages | Merged key by key, so a package keeps its own `flutter` constraint. |
| `dependencies` | Root and packages | Updates `dependencies` and `dev_dependencies` that a package already has. Values are written as given. A package's own `hosted:` source is kept, and only its version changes. Each managed dependency gets a `# Configured via catalog` comment. |
| `version`, `publish_to`, `homepage`, `repository`, `issue_tracker`, `documentation`, `funding`, `platforms`, `resolution` | Packages | Replaced. |
| `topics` | Packages | Added to each package's topics. |

A pub workspace resolves one version of each package for every workspace package, so the catalog gives every package the same constraint. For `dependency_overrides`, edit the root `pubspec.yaml`: pub applies them to the whole workspace.

`homepage`, `repository`, `issue_tracker`, `documentation`, and `funding` can use these variables, written as `NAME`, `$NAME`, or `${NAME}`:

| Variable | Value |
| --- | --- |
| `DPK_PACKAGE_PATH` | The package path relative to the workspace root, such as `packages/core`. |
| `DPK_PACKAGE_NAME` | The package name. |
| `DPK_PACKAGE_VERSION` | The catalog `version`, or else the package's version. |

`dpk catalog outdated` compares each catalog constraint with the latest version, and `dpk catalog upgrade` raises the constraints to the newest versions within them. Add `--major-versions` to allow new major versions. Exact versions stay exact.

## Sorting pubspecs

With `sort_pubspec: true`, `dpk get` sorts every pubspec it manages. Top-level keys follow the standard pubspec order, and dependencies are sorted by name. Comments, blank lines inside values, and every section other than the dependencies stay exactly as written.

## Checking in CI

`dpk get --check` exits with code 1 when `dpk get` would change a pubspec or `dpk.yaml`, without changing anything. `dpk get --dry-run` prints what would change, writes nothing, and runs `dart pub get --dry-run`.

## Cleaning build output

`dpk clean` removes `.dart_tool/` and `build/` in the workspace root and every workspace package. For a package that depends on the Flutter SDK, it runs `flutter clean` first when `flutter` is on your `PATH`.

| Option | Meaning |
| --- | --- |
| `--filter <package>` | Only clean packages with this name or path glob. |
| `--lockfile` | Also remove `pubspec.lock`. |
| `--cache` | Also remove the project cache. `dpk get` downloads the packages and applies the patches again. Project mode only. |
| `-n, --dry-run` | List what would be removed. |

`dpk clean` only removes these fixed paths, and prints each one.

## Patching dependencies

Use project mode only when you patch dependencies. Otherwise, keep the default global mode.

```yaml
mode: project
```

In project mode, pub stores packages in the project cache, `pub_packages/` by default, instead of the global pub cache. `dpk init --mode project` adds the project cache to `.gitignore` and excludes it from the analyzer. Do both yourself when you switch an existing project, because the analyzer slows down badly when it reads every downloaded package.

To patch a dependency:

1. Run `dpk get`. It records a git baseline of the project cache.
2. Edit the package's files in `pub_packages/hosted/pub.dev/<package>-<version>/`.
3. Run `dpk patch generate`. It saves your edits as `patches/hosted/<package>-<version>.patch`, including deleted, new, and binary files.
4. Commit the `patches/` folder.

Every `dpk get`, `add`, `remove`, `upgrade`, or `downgrade` applies the patches. Applying is idempotent.

A patch targets one package version. When you upgrade that package, `dpk get` fails and tells you to edit the new version and run `dpk patch generate` again, or to remove the patch.

| Command | What it does |
| --- | --- |
| `dpk patch generate [package...]` | Saves edits as patch files. Removes patches for packages that no longer have edits. |
| `dpk patch apply [--force]` | Applies the patches. `--force` resets a package whose edits conflict with its patch. |
| `dpk patch list` | Shows whether each patch is applied, stale, or conflicting. |
| `dpk patch remove <package>` | Deletes a package's patch and undoes it in the project cache. |
| `dpk patch init [--force]` | Records the baseline. `--force` discards every edit and records it again. |

`cache_dir` and `patch_dir` in `dpk.yaml` change the folders. Patching needs `git` on your `PATH`.

## Releasing

`dpk release version` reads the Conventional Commits that touch each package since its last release tag, then:

1. Raises the version in each package's pubspec. A `feat` commit raises the minor version. `fix`, `perf`, and `revert` commits raise the patch version. A breaking change, marked with `!` or a `BREAKING CHANGE:` footer, raises the major version. Below 1.0.0, a breaking change raises the minor version and a feature raises the patch version.
2. Raises the constraint of every workspace package that no longer allows a new version, and gives it a patch release.
3. Adds an entry to each package's `CHANGELOG.md`.
4. Runs the `version` hooks. A `post:version` hook runs after the files change and before the commit, and the files it changes go into the release commit.
5. Commits and tags each release with an annotated tag, as `<package>-v<version>` in a workspace or `v<version>` for a standalone package.

```bash
dpk release version --dry-run     # show the plan and changelogs
dpk release version               # ask, then release
dpk release version --prerelease beta
git push --follow-tags
```

When the catalog sets `version`, every package shares it and gets one new version.

`dpk release publish` publishes every package whose version is not on its pub server yet, dependencies first. It skips `publish_to: none` packages. After each package publishes, it creates that version's release tag if the tag is missing, for example after you raised a version by hand, and refuses to tag from a working tree with uncommitted changes. Pass `--no-tag` to skip tagging.

Both commands accept `--filter`, `--dry-run`, and `--yes`. `version` also takes `--bump`, `--prerelease`, `--graduate`, `--no-commit`, `--no-tag`, and `--allow-dirty`. Their hooks are `version` and `release`.

A package with generated files that depend on its version can rebuild them in both steps:

```yaml
scripts:
  build: dart run build_runner build -d
  post:version: dpk run build   # the rebuilt files go into the release commit
  pre:release: dpk run build    # publish fresh generated files
```

## Editor support

`dpk init` adds a comment that points editors with the YAML language server at the [dpk.yaml JSON schema](schema/dpk.schema.json), for completion and validation. Add it to an existing file:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/exaby73/dpk/main/schema/dpk.schema.json
```

dpk itself validates `dpk.yaml` on every run. An unknown key or a wrong type is an error that names the file, the line, and the key, with a suggestion for typos.

## Shell completion

dpk never changes your shell config on its own. To install completion for commands, options, and script names, run:

```bash
dpk install-completion-files
```

## Upgrading to 1.0

dpk 1.0 needs Dart 3.11 or later. Most projects upgrade with three steps:

1. Install the new version with `dart install dpk`.
2. Change `version` in `dpk.yaml` to `^1.0.0`.
3. Run `dpk get`. It renames deprecated keys in `dpk.yaml` and applies the catalog with the new rules. Commit the changes.

Then check these changes against your project:

| What changed | What to do |
| --- | --- |
| `runInPackages`, `runHooksFrom`, and `sortPubspec` are now `run_in_packages`, `run_hooks_from`, and `sort_pubspec`. | Nothing. `dpk get` renames them, and the old names work with a warning until then. |
| dpk's own options only count before the command. `dpk run test -v` passes `-v` to the script. | Move `-C`, `-v`, and `--cache-dir` before the command, as in `dpk -C packages/app get`. |
| `-d` is no longer short for `--cache-dir`. | Use `--cache-dir`, or `cache_dir` in `dpk.yaml`. |
| Scripts run in `/bin/sh` instead of `$SHELL`. | Rewrite scripts that use zsh, fish, or bash features, or call that shell explicitly: `zsh -c '...'`. |
| A script runs in the workspace package you start it from, not where `dpk.yaml` is. | Start workspace-wide scripts from the root, or give them `run_in_packages`. |
| A `run_in_packages` that matches nothing is an error, and `./packages/*` now matches. | Fix globs that matched nothing before. `dpk run` and `dpk list` show what they select. |
| `dpk.yaml` is validated, and the nested `dpk:` mapping is gone. | Fix the keys dpk reports, and move keys out of `dpk:` to the top level. |
| The workspace root package no longer has to be named `_`. | Nothing. Rename the root package if you like. |
| `dpk get` records the patch baseline and applies patches. | Drop `dpk patch init` and `dpk patch apply` from setup steps and CI. |
| `dpk run` without a script lists the scripts and exits with 0. | Nothing, unless a script relied on the old usage error. |
| Shell completion is no longer installed automatically. | Run `dpk install-completion-files` once. |

See the [changelog](CHANGELOG.md) for every change.

## Troubleshooting

- **`dpk.yaml requires dpk ^X, but dpk Y is installed`**: update dpk with `dart install dpk`, or change `version` in `dpk.yaml`.
- **`No dpk.yaml found`**: run `dpk init` in the package or workspace root.
- **A script runs in the wrong folder**: run `dpk list` to see the workspace packages, and `dpk doctor` to check the workspace.
- **A patch is stale**: the lockfile uses another version of the package. Edit the new version in the project cache and run `dpk patch generate`, or run `dpk patch remove <package>`.
