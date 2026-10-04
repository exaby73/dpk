# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`dpk` is an alternative package manager for Dart that wraps `dart pub` and adds enhanced features:
- Script running with hooks and workspace support
- Dependency patching for monorepos
- Catalog-based configuration for workspace packages
- Pubspec.yaml sorting and workspace management

## Development Commands

### Testing
```bash
# Run all tests
dart test

# Run a specific test file
dart test test/workspace_config_test.dart
```

### Building
```bash
# Generate code (Freezed, JSON serialization, pubspec constants)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs
```

### Code Quality
```bash
# Run analyzer
dart analyze

# Format code
dart format .
```

### Testing Locally
```bash
# Install dpk locally for testing (requires Dart 3.11+)
dart install --source path .

# Then test commands
dpk get
dpk run <script>
```

## Architecture

### Command Structure

The CLI uses the `args` package with a command/subcommand pattern:

1. **`DpkCommandRunner`** (`lib/core/command_runner.dart`) - Entry point that:
   - Loads `dpk.yaml` and `pubspec.yaml` configuration before command execution
   - Validates dpk version compatibility
   - Registers all commands (add, remove, get, upgrade, downgrade, patch, run)
   - Handles global options (--directory)

2. **Command Types**:
   - **Pub wrapper commands** (`add`, `remove`, `get`, `upgrade`, `downgrade`) - Delegate to `dart pub` with hooks support
   - **Patch commands** (`patch init/generate/apply`) - Manage dependency patches via git
   - **Run command** (`run`) - Execute scripts defined in `dpk.yaml`

### Configuration System

Configuration is split between two files, parsed in `lib/config/config.dart`:

1. **`pubspec.yaml`** - Standard Dart pubspec with optional `workspace` field for monorepos
2. **`dpk.yaml`** - dpk-specific config with:
   - `version` (required) - dpk version constraint
   - `mode` - `global` (default, uses pub cache) or `project` (local `pub_packages/` dir for patching)
   - `sortPubspec` - Auto-sort pubspec.yaml on `dpk get`
   - `workspace` - Glob patterns expanded to package paths
   - `scripts` - Script definitions with hooks, env vars, and workspace targeting
   - `catalog` - Shared config for workspace packages (env, dependencies, metadata)

**Key class**: `ConfigData` (`lib/config/data/config_data.dart`) merges pubspec and dpk.yaml into unified config object.

### Workspace Handling

Workspaces are detected by searching up the directory tree for a parent `pubspec.yaml` with a `workspace` field:

- **Workspace root**: Directory containing `dpk.yaml` with catalog/workspace definitions
- **Workspace packages**: Subdirectories with their own `pubspec.yaml` and optional `dpk.yaml`
- **Config merging**: Package scripts override root scripts; catalog and mode come from root only
- **Detection logic**: `lib/utils/workspace.dart` - `getWorkspaceInfo()` walks up tree to find workspace root

### Script Execution

Scripts are executed by `DpkScriptRunner` in `lib/commands/run_command.dart`:

1. **Hook resolution**: Checks for `pre:<script>` and `post:<script>` hooks (or inherited via `runHooksFrom`)
2. **Workspace execution**: If `runInPackages` globs match multiple packages, runs script in parallel across packages with color-coded output
3. **Environment injection**: Sets `DPK_ROOT` env var for workspace-aware scripts
4. **Process handling**: Uses platform shell (`zsh`, `bash`, or `cmd`) via `lib/core/shell.dart`

### Dependency Patching

Patching requires `mode: project` in `dpk.yaml`:

1. **`patch init`** - Creates `pub_packages/` git repo and commits initial state
2. **User modifies** packages in `pub_packages/`
3. **`patch generate`** - Creates `.patch` files in `patches/` directory via git diff
4. **`patch apply`** - Applies patches from `patches/` to `pub_packages/`

Implementation: `lib/commands/subcommands/patch/` with git process handling.

### Catalog System

The catalog (in root `dpk.yaml`) applies shared configuration across workspace packages:

- Only works when root `pubspec.yaml` has `name: _` (signals catalog mode)
- **Template variables** in repository/issue_tracker/documentation URLs:
  - `DPK_PACKAGE_PATH` - relative path from workspace root
  - `DPK_PACKAGE_NAME` - package name
  - `DPK_PACKAGE_VERSION` - package version
- **Dependency resolution**: `workspace` or `hosted` mode
- **Shared dependencies**: Updates existing deps in workspace packages (doesn't add new ones)

Applied during `dpk get` in `lib/commands/get_command.dart`.

### Code Generation

The project uses `build_runner` with:
- **Freezed** - Immutable data classes (`*.freezed.dart` files)
- **JSON serialization** - `json_serializable` for `Script` config
- **Pubspec generation** - `pubspec_generator` creates `lib/constants/pubspec.g.dart` with version info

Run `dart run build_runner build -d` after modifying annotated classes.

## Key Patterns

### Mixins

Commands use mixins for shared behavior:
- **`ConfigMixin`** - Provides `config` getter from DI container
- **`HookRunnerMixin`** - Runs `pre:` and `post:` hooks for commands
- **`ProcessHandlerMixin`** - Runs `dart pub` subprocesses
- **`PubEnvMixin`** - Sets up environment for pub commands (handles `PUB_CACHE` for project mode)

### Dependency Injection

Uses `get_it` package (`lib/core/injection_container.dart`):
- `ConfigData` registered as singleton in `DpkCommandRunner.init()`
- Commands access via `ConfigMixin.config`

### Global Options

Global args (like `--directory`) are parsed early in `DpkCommandRunner._create()` to determine working directory before loading config.

## Common Tasks

### Adding a New Command

1. Create command file in `lib/commands/` (or `lib/commands/subcommands/` for subcommands)
2. Extend `Command<int>` and optionally mix in `ConfigMixin`, `HookRunnerMixin`
3. Register in `DpkCommandRunner.init()`
4. If using hooks, call `runPreHook()` and `runPostHook()` with command name

### Modifying Configuration Schema

1. Update data classes in `lib/config/data/`
2. Modify parsing logic in `.fromYaml()` factory constructors
3. Run `dart run build_runner build -d` to regenerate Freezed code
4. Update config loading in `lib/config/config.dart` if needed

### Testing Workspace Features

Use `examples/monorepo/` for testing workspace functionality:
- Has root `dpk.yaml` with catalog and workspace globs
- Contains 3 test packages in `packages/`
- Test script execution, dependency resolution, catalog application

## Important Notes

- **Version validation**: dpk refuses to run if installed version doesn't match `version` constraint in `dpk.yaml`
- **Shell compatibility**: Cross-platform shell detection in `lib/core/shell.dart` (zsh/bash on Unix, cmd on Windows)
- **Pubspec sorting**: Custom sorting logic in `lib/utils/pubspec_sorter.dart` preserves comments and uses standard key order
- **Terminal title**: Commands set terminal title to show current operation (e.g., "dpk run build")
