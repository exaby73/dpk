# dpk

[![pub version](https://img.shields.io/pub/v/dpk.svg)](https://pub.dev/packages/dpk)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

An alternative package manager for Dart that enhances the standard `dart pub` commands with extra features like script running and dependency patching. `dpk` acts as a wrapper around the standard Dart tooling, allowing you to use the commands you are already familiar with.

## Features

- **Familiar Commands**: Implements `get`, `add`, `remove`, `upgrade`, and `downgrade` commands that mirror `dart pub`.
- **Script Runner**: Define and run custom scripts from your `dpk.yaml` file using `dpk run`.
- **Dependency Patching**: A powerful feature to manage and apply patches to your dependencies, ideal for monorepos or when you need to test a fix before a package is updated.

## Installation

Activate `dpk` globally using the following command:

```bash
dart pub global activate dpk
```

## Usage

`dpk` is designed to be a drop-in replacement for many `dart pub` commands.

### Managing Dependencies

- **`dpk get`**: Gets the dependencies for the current package.
- **`dpk add <package>`**: Adds a new dependency to your `pubspec.yaml`.

  ```bash
  # Add a dependency
  dpk add http

  # Add a dev dependency
  dpk add dev:lints
  ```

- **`dpk remove <package>`**: Removes a dependency from your `pubspec.yaml`.
- **`dpk upgrade`**: Upgrades the dependencies to their latest versions.
- **`dpk update`**: Alias for `upgrade` - upgrades dependencies to their latest versions.
- **`dpk downgrade`**: Downgrades dependencies to the oldest possible versions.

### Running Scripts

You can define custom scripts in a `dpk.yaml` file at the root of your project.

**`dpk.yaml` example:**

```yaml
scripts:
  analyze: dart analyze
  test: dart test
```

Run a script using `dpk run`:

```bash
dpk run analyze
```

### Script Hooks

Scripts can have `pre` and `post` hooks that run before and after the main command. Currently supported hooks are for `get` and `build` commands:

**Example with hooks:**

```yaml
scripts:
  # Get command hooks
  preget: echo "Starting dependency resolution..."
  get: dart pub get
  postget: echo "Dependencies resolved!"

  # Build command hooks
  prebuild: dart run build_runner clean
  build: dart run build_runner build -d
  postbuild: echo "Build completed successfully"

  # Watch command can inherit build hooks
  watch:
    runHooksFrom: build
    command: dart run build_runner watch -d
```

When you run `dpk run build`, it executes:

1. `prebuild` hook (if defined)
2. `build` command
3. `postbuild` hook (if defined)

### Environment Variables

You can set environment variables for scripts using the `env` section:

```yaml
scripts:
  deploy:
    command: deploy --api-key $API_KEY
    env:
      API_KEY: your-secret-key
      ENVIRONMENT: production
```

### Patching Dependencies

The `patch` command set allows you to create, apply, and manage patches for your dependencies. This is particularly useful when you need to make temporary changes to a package without forking it.

#### 1. Initialize Patching

First, initialize the patching environment. This will create a `pub_packages` directory and set up a git repository to track changes.

```bash
dpk patch init
```

This command must be run after fetching dependencies with `dpk get`. It creates a git repository in the `pub_packages` directory and commits the initial state of your dependencies.

**Important:** Make sure to exclude the `pub_packages` directory from version control and analysis:

1. Add to `.gitignore`:

```text
pub_packages/
```

1. Add to `analysis_options.yaml` to prevent analyzer performance issues:

```yaml
analyzer:
  exclude:
    - pub_packages/**
```

Excluding `pub_packages` from analysis is crucial - without this, the Dart analyzer will consume excessive resources analyzing all dependency code, leading to slow performance and potential crashes.

#### 2. Modify Your Dependencies

Navigate into the `pub_packages` directory and make any required changes to the dependency source code.

#### 3. Generate Patches

Once you have made your changes, generate patch files:

```bash
dpk patch generate
```

This command compares the modified dependency code against the initial state and creates `.patch` files in the `patches` directory.

#### 4. Apply Patches

To apply existing patches to your dependencies (e.g., after a fresh `dpk get`), use the `apply` command:

```bash
dpk patch apply
```

This command will apply all `.patch` files found in the `patches` directory to the corresponding packages in `pub_packages`. This is useful in a CI/CD environment or when another developer on your team needs to get your changes.

**Note:** If you haven't run `dpk patch init` yet, you'll need to run it first to set up the patching environment.

## Configuration (`dpk.yaml`)

The `dpk.yaml` file allows for advanced configuration of scripts and workspace settings. Below is a complete reference of all available options:

### Complete Configuration Example

```yaml
# Operational mode
mode: global # or 'project' - see mode section below

# Script definitions
scripts:
  # Simple format
  analyze: dart analyze
  format: dart format .

  # Advanced format with all options
  test:
    command: dart test
    env:
      TEST_ENV: integration
      API_URL: http://localhost:8080
    runInPackages: # Run in specific workspace packages
      - 'packages/*'
      - 'apps/*'
    runHooksFrom: build # Inherit hooks from another script

  build:
    command: dart compile exe bin/main.dart

  # Hook definitions
  pre:build: echo "Starting build at $(date)"
  post:build: |
    echo "Build completed"
    ls -la bin/

  pre:test: dart analyze
  post:test: dart format --set-exit-if-changed .

# Catalog configuration (for monorepos/workspaces)
# Note: Requires root pubspec.yaml to have name: '_'
catalog:
  # Environment constraints
  environment:
    sdk: '>=3.0.0 <4.0.0'
    flutter: '>=3.10.0' # Optional Flutter SDK constraint

  # Package metadata
  repository: https://github.com/username/repo
  issue_tracker: https://github.com/username/repo/issues
  documentation: https://docs.example.com
  homepage: https://example.com

  # Publishing configuration
  publish_to: none # or a custom pub server URL

  # Package categorization for pub.dev
  topics:
    - dart
    - cli
    - package-manager

  # Dependency resolution type
  resolution: hosted # or 'git' for git-based dependencies

  # Shared dependencies across workspace
  dependencies:
    http: ^1.1.0
    path: ^1.9.0

  dev_dependencies:
    lints: ^3.0.0
    test: ^1.24.0

  # Override dependencies at workspace level
  dependency_overrides:
    http: ^1.2.0
```

### Configuration Properties

#### `mode`

Specifies the operational mode for `dpk`.

- **`global`** (default): Packages are installed using the standard `dart pub get` behavior (to the global pub cache).
- **`project`**: Packages are installed to the local `pub_packages` directory for patching and local modifications.

#### `scripts`

Defines custom commands that can be executed with `dpk run <script_name>`.

**Simple format:**

```yaml
scripts:
  analyze: dart analyze
```

**Advanced format with options:**

```yaml
scripts:
  test:
    command: dart test # Required
    env: # Optional environment variables
      MY_VAR: 'some_value'
      API_KEY: 'your-api-key'
    runInPackages: # For monorepos - glob patterns
      - 'packages/*'
      - '!packages/experimental_*' # Exclude pattern
    runHooksFrom: build # Inherit pre/post hooks
```

**Script Options:**

- **`command`** (Required): The shell command to execute
- **`env`**: Environment variables to set before running the script
- **`runInPackages`**: Glob patterns for workspace packages where the script should run
- **`runHooksFrom`**: Name of another script to inherit hooks from

#### `catalog`

The `catalog` property is a powerful feature for managing monorepos. It allows you to define shared configurations across multiple packages, ensuring consistency for dependencies, metadata, and more.

To enable the catalog, the `name` of your root `pubspec.yaml` must be `_`.

**Catalog Properties:**

- **`environment`**: SDK constraints for Dart and Flutter
  - `sdk`: Dart SDK version constraint
  - `flutter`: Optional Flutter SDK version constraint
- **`repository`**: Source code repository URL
- **`homepage`**: Project homepage URL
- **`issue_tracker`**: Issue tracker URL
- **`documentation`**: Documentation website URL
- **`publish_to`**: Pub server URL or `none` (defaults to `none`)
- **`topics`**: List of pub.dev categorization topics
- **`resolution`**: Dependency resolution type (`hosted` or `git`)
- **`dependencies`**: Shared dependencies across all workspace packages
- **`dev_dependencies`**: Shared dev dependencies
- **`dependency_overrides`**: Override specific dependency versions

When you run `dpk get` in a workspace with a catalog, dpk automatically updates each package's `pubspec.yaml` with the catalog configuration.

## Advanced Features

### Workspace Support

dpk automatically detects workspace configurations by looking for a `workspace` field in parent `pubspec.yaml` files. This enables:

- Running scripts across multiple packages with `runInPackages`
- Sharing dependencies and configuration via catalog
- Consistent versioning across the workspace

### Automatic Workspace Detection

dpk searches up the directory tree to find workspace roots, allowing you to run commands from any subdirectory within a workspace.

### Git Dependency Support

When using `resolution: git` in the catalog, dpk can manage git-based dependencies across your workspace:

```yaml
catalog:
  resolution: git
  dependencies:
    my_package:
      git:
        url: https://github.com/user/repo.git
        ref: main
```

### Complex Script Chaining

Scripts can be chained and share hooks using `runHooksFrom`:

```yaml
scripts:
  ci:
    command: echo "Running CI"
    runHooksFrom: test # Inherits pre:test and post:test

  pre:test: dart analyze
  post:test: dart format --set-exit-if-changed .
```

## Troubleshooting

### Common Issues

1. **Patches not applying**: Ensure you've run `dpk patch init` first and that the patches directory exists
2. **Workspace not detected**: Check that parent directories have a valid `pubspec.yaml` with a `workspace` field
3. **Environment variables not substituting**: Verify the variable is exported in your shell environment
4. **Scripts not found**: Ensure `dpk.yaml` is in the project root
