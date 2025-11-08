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
