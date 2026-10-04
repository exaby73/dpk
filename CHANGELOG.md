## 1.0.0

### Breaking changes

- [BREAKING] Chore: Require Dart 3.11 or later and upgrade dependencies to their latest compatible versions
- [BREAKING] Feat: dpk options such as `-C` and `-v` count only before the command; every argument after a script name reaches the script, including `--help`, `--version`, and `-v`
- [BREAKING] Feat: Remove `-d` as a short form of `--cache-dir`
- [BREAKING] Feat: Run scripts in `/bin/sh`, or `cmd.exe` on Windows, instead of `$SHELL`
- [BREAKING] Feat: Rename `runInPackages` and `runHooksFrom` to `run_in_packages` and `run_hooks_from`; the old names still work with a warning, and `dpk get` renames them
- [BREAKING] Feat: Validate `dpk.yaml` on every run, with errors that name the file, line, and key, and suggestions for typos; remove the nested `dpk:` mapping
- [BREAKING] Feat: Run a script in the workspace package it is started from, instead of the folder that holds `dpk.yaml`
- [BREAKING] Feat: Fail when `run_in_packages` matches no workspace package, instead of running at the root
- [BREAKING] Feat: `dpk run` without a script lists the scripts and exits with code 0

### Features

- Feat: Find workspaces from pubspec files, without `dart pub workspace list` and without requiring the root package to be named `_`
- Feat: Add `depends_on` to run other scripts first, including `^script` to run a script in a package's workspace dependencies
- Feat: Run the same dpk when a script calls `dpk`, through a launcher first on the script's `PATH`, for installed binaries and `dart run`
- Feat: Add `dpk clean`
- Feat: Add `dpk exec` to run a shell command in every workspace package
- Feat: Add `dpk list` with `--graph` and `--json`
- Feat: Add `--filter`, `--concurrency`, `--fail-fast`, and `--dependency-order` to `dpk run` and `dpk exec`, and the `concurrency`, `fail_fast`, and `dependency_order` script keys
- Feat: Add the `env_file` script key, and the `DPK_PACKAGE_NAME` and `DPK_PACKAGE_PATH` variables; set `DPK_ROOT` for every script
- Feat: Show script descriptions in `dpk run`, with hooks listed apart from scripts
- Feat: Print each script and hook to stderr before it runs, with `-q` to hide them
- Feat: Prefix each line of parallel output with its package name, and add colors only in a terminal
- Feat: Add `dpk get --check` for CI, and make `dpk get --dry-run` write nothing
- Feat: Use the catalog version in `dpk add <package>`
- Feat: Add `dpk catalog outdated` and `dpk catalog upgrade`
- Feat: Record the project cache baseline and apply patches on every `dpk get`, `add`, `remove`, `upgrade`, and `downgrade`
- Feat: Add `dpk patch list` and `dpk patch remove`, and `dpk patch generate <package>`
- Feat: Report stale patches whose package version the lockfile no longer uses
- Feat: Add `dpk release version` and `dpk release publish` for Conventional Commits releases
- Feat: Add `dpk doctor`
- Feat: Add the `cache_dir` and `patch_dir` keys
- Feat: Publish a JSON schema for `dpk.yaml`, and point to it from `dpk init`
- Feat: Make `dpk init` add starter scripts, keep the project cache out of git and the analyzer in project mode, and print next steps
- Feat: Group commands in `dpk --help`
- Feat: Let `cache`, `global`, `unpack`, `login`, `logout`, `token`, `help`, and `doctor` run outside a project

### Fixes

- Fix: Stop `sort_pubspec` from adding a blank line after nested dependency values, such as `sdk: flutter`, on every `dpk get`
- Fix: Rewrite the pubspec sorter to keep comments, block scalars, anchors, empty values, flow-style sections, 4-space indentation, and CRLF line endings
- Fix: Never install shell completion without asking; run `dpk install-completion-files` to opt in
- Fix: Forward stdin to `dart pub`, so `dpk publish` and `dpk token add` no longer hang
- Fix: Run `dpk add` and other pub commands in the current workspace package instead of the workspace root
- Fix: Make `-C` work with relative and symbolic-link paths
- Fix: Stop rewriting the root pubspec on every command; only `dpk get` writes it
- Fix: Only add packages with `resolution: workspace` from `workspace` globs
- Fix: Check the `version` constraint before the rest of `dpk.yaml`
- Fix: Merge the catalog `environment` key by key, so packages keep their `flutter` constraint
- Fix: Write catalog dependency values as given, keep a package's private `hosted:` source, and stop crashing on `hosted:` catalog dependencies
- Fix: Remove `# Configured via catalog` from dependencies that left the catalog, and keep `#` inside quoted values
- Fix: Expand template variables in URL hosts and in the `${NAME}` form
- Fix: Sort pubspecs outside workspaces when `sort_pubspec` is on
- Fix: Write all pubspec changes together, after every change is computed
- Fix: Never delete anything but `*.patch` files when generating patches
- Fix: Include deleted, new, binary, and space-named files in patches
- Fix: Record the project cache baseline without a git identity, signing, or hooks, and check every git exit code
- Fix: Make `dpk patch apply` idempotent
- Fix: Resolve the project cache at the workspace root from workspace packages
- Fix: Keep `dpk global` on the global pub cache in project mode, and give scripts `PUB_CACHE` in project mode
- Fix: Honor `--cache-dir` in every command
- Fix: Run `run_hooks_from` scripts with their own shared, pre, and post hooks, and reject unknown `run_hooks_from` names
- Fix: Key the hook recursion guard by workspace root, and run shared hooks once across nested dpk calls
- Fix: Run a package matched by several globs once
- Fix: Keep the last line of parallel output when it has no trailing newline
- Fix: Close stdin for parallel package runs instead of hanging
- Fix: Forward SIGTERM to scripts, and exit with `128 + signal` when a script is killed
- Fix: Exit with the first failed package's exit code instead of 1
- Fix: Restore the previous terminal title after a command
- Fix: Write errors to stderr with an `error:` prefix and no stack trace
- Fix: Name `dpk.yaml`, not `pubspec.yaml`, in the error for keys that belong at the workspace root

### Docs and chores

- Docs: Rewrite the README as the full reference, with an upgrade guide from 0.x
- Docs: Rewrite the dpk skill for 1.0
- Docs: Document shared `before` and `after` hooks
- Docs: Recommend global mode unless you patch dependencies
- Docs: Fix the license badge, which said MIT instead of Apache-2.0
- Refactor: Rebuild the CLI around invocation, workspace, config, hook, run plan, catalog, project cache, and release modules, and remove `freezed`, `get_it`, and other unused dependencies
- Chore: Move the repository to `exaby73/dpk`

## 0.8.3

- Feat: Add catalog support for `homepage`, `version`, `funding`, and `platforms`
- Feat: Rename `sortPubspec` to `sort_pubspec` and migrate legacy keys during `dpk get`
- Docs: Clarify catalog field behavior and template variable expansion

## 0.8.2

- Feat: Support `description` metadata on dpk script objects
- Docs: Document every dpk script object option in README and the bundled skill

## 0.8.1

- Feat: Embed the dpk skill content so installed CLI binaries can print the full guide
- Feat: Add detailed `dpk --version` output with Dart SDK metadata
- Docs: Document the full dpk CLI surface in the bundled skill guide

## 0.8.0

- Feat: Add `dpk skills` to print detailed end-user CLI guidance for AI agents
- Feat: Run shared `before`/`after` hooks for pub commands, promote `get` before hooks after `pub get`, and skip recursive hook loops
- Docs: Expand the dpk skill with command coverage, script chaining, hooks, catalog behavior, project cache mode, and patch workflows

## 0.7.0

- Feat: Add `dpk init` to create `dpk.yaml`, with support for `--mode`, `--force`, and `-C`
- Feat: Add passthrough wrappers for the remaining `dart pub` commands
- Feat: Add `before` and `after` script hooks with `scripts` filters and `all` matching
- Refactor: Route plain pub commands through the passthrough wrapper and validate pass-through command names
- Fix: Make `-C` work reliably for config discovery and `dpk run`
- Fix: Run pub commands from the resolved target directory without mutating process-wide cwd
- Fix: Quote forwarded script arguments so shell metacharacters are passed as data
- Fix: Require `--force` before `patch apply` discards dirty patch cache changes
- Test: Rewrite utility and workspace tests with Given/When/Then structure
- Test: Add descriptor-backed CLI coverage for startup, `dpk run`, `dpk init`, patch safety, and `dpk add --dev`
- Docs: Add end-user dpk skill guidance and minimal agent instructions

## 0.6.5

- Fix: Ensure remainingBytes is an empty list when lastWhitespacePos is at the end of currentLine

## 0.6.4

- Feat: Add inline comments to catalog-managed dependencies showing `# Configured via catalog` for better visibility
- Fix: Pubspec sorter now correctly preserves inline comments on complex dependency keys (git, path, sdk)

## 0.6.3

- Fix: Allow --version and --help to work before dpk.yaml parsing

## 0.6.2

- Docs: Add setup section to README with required pubspec.yaml and dpk.yaml file structures

## 0.6.0

- [BREAKING] Refactor: Consolidate catalog deps into single field for dependencies and
  dev_dependencies
- [BREAKING] dpk.yaml is now required - dpk config in pubspec.yaml is no longer supported
- Feat: Add required `version` field in dpk.yaml to enforce dpk version constraints
- Feat: Add DPK_ROOT environment variable support to scripts with `runInPackages` option, allowing scripts to access the workspace root directory
- Feat: Add glob pattern support for workspace in dpk.yaml
- Feat: Add sortPubspec option to sort pubspec.yaml files on get command

## 0.5.0

- [BREAKING] Feat: Update min Dart to 3.8.0
- Feat: Improve parallel script output with header grouping, indentation, and line wrapping, and preserve colors for single scripts
- Feat: Add summary table for parallel scripts

## 0.4.0

- Feat: Workspace packages can now define package-specific `dpk.yaml` files that merge with workspace root scripts, with package scripts taking precedence over root scripts for script name conflicts
- Feat: Scripts with `runInPackages` now work correctly when executed from workspace package directories, automatically resolving package paths relative to the workspace root
- Feat: Workspace root `dpk.yaml` scripts are automatically inherited by all workspace packages, enabling shared script definitions across the workspace
- Fix: Package `dpk.yaml` files are now validated to prevent defining forbidden fields (`catalog`, `mode`, `dependency_overrides`) which must only be defined in workspace root

## 0.3.1

- Fix: `cacheDir` is now resolved relative to the dpk.yaml directory instead of the current working directory, ensuring consistent cache location across all commands (`add`, `get`, `remove`, `upgrade`, `downgrade`, and patch commands) regardless of where they are executed from

## 0.3.0

- Feat: Catalog dependencies now update matching dependencies in workspace packages during `dpk get`, synchronizing versions across all dependency sections (dependencies, dev_dependencies, dependency_overrides) with validation to prevent duplicate package names across catalog sections

## 0.2.4

- Fix: `HostedDependency.toJson()` now outputs simplified format (version string instead of map) when no hosted field is present, matching standard pubspec.yaml format and producing cleaner generated files

## 0.2.3

- Fix: Commands like `add`, `remove`, `upgrade`, and `downgrade` now correctly operate in the current directory instead of the dpk.yaml directory, ensuring packages are added to the correct pubspec.yaml when running from subdirectories
- Fix: Hooks now run in isolation with directory save/restore, preventing directory changes from affecting the calling command

## 0.2.2

- Fix: `-C` flag no longer causes "directory does not exist" error by removing duplicate directory argument passed to dart pub

## 0.2.1

- Fix: Added hook support to all built-in commands (`add`, `remove`, `upgrade`, `downgrade`)

## 0.2.0

- Feat: Added support for recursively finding the dpk.yaml file in parent directories.
- Feat!: Added support for arbritary script hooks.

### Breaking changes

- Hooks now use the `pre:` and `post:` prefix.

## 0.1.14

- Fix: Correctly set 'PUB_CACHE' in getCacheEnv method for project mode.

## 0.1.13

- Fix `--version` command printing old version.

## 0.1.12

- Fixed a bug where arguements after `--` were not being passed scripts.

## 0.1.11

- Added support for terminal title.

## 0.1.9

- Added `version` flag to print the version and exit.

## 0.1.8

- Added CLI autocompletion support for scripts by registering them as sub-commands of the run command.

## 0.1.7

- Fix: Apply command not working when git dependencies are present.

## 0.1.5

- Fix: Postget script not running when in pub workspace.

## 0.1.4

- Added `link` to `get` command.

## 0.1.3

- Added catalog support

## 0.1.1

- Downgrade Dart SDK version to 3.6.0.

## 0.1.0

- Initial version.
