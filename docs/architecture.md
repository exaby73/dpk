# How dpk fits together

dpk wraps `dart pub`. Each command finds and loads the dpk configuration, does its own work around a `dart pub` call, and runs hooks before and after. For the words used here, see [`GLOSSARY.md`](../GLOSSARY.md).

## Startup loads configuration before any command runs

`bin/dpk.dart` calls `DpkCommandRunner.init` in `lib/core/command_runner.dart`. Before it registers commands, the runner works out where the project is:

1. It reads `-C` or `--directory` from the raw arguments, because the `args` parser has not run yet. Without the flag, it starts from the current directory.
2. `findDpkYamlDirectory` in `lib/config/config.dart` walks up from that directory to the nearest `dpk.yaml`. It stops at the workspace root, so a package never picks up configuration from outside its workspace.
3. `loadConfig` merges `pubspec.yaml` and `dpk.yaml` into one `ConfigData` and registers it with `get_it` (`lib/core/injection_container.dart`). Commands read it through `ConfigMixin`.

Help requests and the `init` and `skills` commands skip this step, because they must work in a directory without a `dpk.yaml`. The runner registers `run` only when configuration loads.

Before any command runs, the runner checks that the installed dpk version satisfies `version` in `dpk.yaml`, and stops with an error if it does not. This check keeps everyone on a team on a compatible dpk.

## Commands fall into three groups

- **`get`** (`lib/commands/get_command.dart`) applies the catalog, sorts pubspecs, runs `dart pub get`, and runs hooks in its own order.
- **Passthrough commands** (`lib/commands/pub_passthrough_command.dart`) cover every other pub command, from `add` and `upgrade` to `publish` and `workspace`. They come from one list of definitions, `pubPassthroughCommandDefinitions`. Each one forwards its arguments to `dart pub` and adds config discovery, hooks, and project cache setup. A new pub command needs only a new definition.
- **dpk-only commands** have no pub equivalent: `run`, `init`, `skills`, and `patch` with its `init`, `generate`, and `apply` subcommands.

Commands share behavior through mixins in `lib/core/mixins/`: `ConfigMixin` for configuration, `HookRunnerMixin` for hooks, `ProcessHandlerMixin` for running `dart`, and `PubEnvMixin` for the project mode environment.

## Workspaces come from `dart pub workspace list`

dpk does not parse workspace layouts itself. `getWorkspaceInfo` in `lib/utils/workspace.dart` runs `dart pub workspace list --json` and treats the first package as the workspace root. Today it also requires the root package's name to be `_`. Issue #7 tracks removing that rule, because Dart no longer needs it.

Inside a workspace package, the workspace root's `dpk.yaml` is the base. A package's own `dpk.yaml` can only add or override scripts. `catalog`, `mode`, and `dependency_overrides` belong to the workspace root, and dpk rejects them in a package's `dpk.yaml`.

`workspace` in `dpk.yaml` takes globs. When dpk loads the configuration, it expands them and writes the resulting paths to the `workspace` list in the root `pubspec.yaml`, because `dart pub` accepts only literal paths.

## `dpk get` rewrites pubspecs before it resolves

In a workspace root, `dpk get` edits pubspec files before it calls `dart pub get`:

1. It applies the catalog. The root pubspec receives only `environment` and catalog dependencies. Each workspace package also receives the package metadata. dpk expands template variables such as `DPK_PACKAGE_NAME` for each package.
2. It marks each catalog dependency with a `# Configured via catalog` comment.
3. If `sort_pubspec` is on, it sorts each pubspec with `lib/utils/pubspec_sorter.dart`. The sorter works on lines rather than on a parsed YAML tree, so it can keep comments and blank lines.

Edits go through `yaml_edit`, so the rest of each file keeps its formatting.

## Hooks wrap commands and scripts

A command or script is a hook target. For most hook targets, dpk runs `before`, then `pre:<name>`, then the target, then `post:<name>`, then `after`.

`dpk get` is the exception. A matching `before` hook runs after `dart pub get`, because typical `before` work, such as code generation, needs resolved packages. The `before` hook in dpk's own `dpk.yaml` depends on this order. It runs `dpk run build` for `get`, `analyze`, and `publish`.

Hooks often call `dpk run`, which could trigger the same hook again. To stop the loop, dpk passes the hooks that are already running to child processes in the `DPK_HOOK_STACK` environment variable. dpk skips a hook that is already on the stack and prints a warning.

## Scripts run in the user's shell

`DpkScriptRunner` in `lib/commands/run_command.dart` runs each script through the shell in `$SHELL`, or `/bin/sh` if `$SHELL` is not set, with `-c`. On Windows it uses `%COMSPEC%` with `/C` (see `lib/core/shell.dart`). dpk shell-quotes the arguments after the script name, so the script receives them as data.

When `runInPackages` matches more than one package, dpk starts the script in all of them at once. It prints each chunk of output under a `[package]` header, indented, and prints a pass or fail summary at the end. The run fails if any package fails. These scripts get `DPK_ROOT`, the absolute path of the workspace root.

## Project mode moves the pub cache into the project

In project mode, `PubEnvMixin.getCacheEnv` sets `PUB_CACHE` to the project cache, `pub_packages/` by default. Every pub command then reads and writes packages there. The `patch` commands use git on that directory to record and replay patches. [ADR 0001](adr/0001-project-mode-uses-a-project-cache.md) explains why patching works this way.

## Generated code is committed

`build_runner` generates three kinds of files, all committed:

- Freezed and `json_serializable` output (`*.freezed.dart` and `*.g.dart`) for configuration and option classes.
- `lib/constants/pubspec.g.dart`, which holds the package version that the version check and `dpk --version` use.
- `lib/constants/embedded_dpk_skill.g.dart`, which embeds `skills/dpk/SKILL.md`, so that `dpk skills` works from an installed binary.

Because the version and the skill are compiled in, a stale build ships the wrong version or old skill text. The `before` hook in `dpk.yaml` rebuilds on `dpk get`, `dpk run analyze`, and `dpk run publish` to prevent that.
