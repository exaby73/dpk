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
