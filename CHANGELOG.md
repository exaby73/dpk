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
