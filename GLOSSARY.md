# dpk

dpk is a package manager for Dart. It wraps `dart pub` and adds scripts, hooks, catalogs, and dependency patches.

## Language

### Commands and scripts

**Command**:
A built-in dpk CLI command, such as `get`, `add`, or `run`.
_Avoid_: built-in script

**Pub command**:
A command that runs a `dart pub` command, such as `get`, `add`, or `upgrade`.
_Avoid_: pub wrapper command

**Passthrough command**:
A pub command that dpk forwards to `dart pub` with no dpk-specific behavior beyond config discovery, hooks, and project cache setup.

**Script**:
A named entry under `scripts` in `dpk.yaml` that runs a shell command.
_Avoid_: task

**Hook**:
A script that runs around a command or another script.
_Avoid_: script hook, command hook

**Pre and post hooks**:
Hooks named `pre:<name>` and `post:<name>`. They run directly before and after the hook target `<name>`.

**Shared hook**:
The `before` or `after` hook. It runs around every hook target it lists, or around all of them.

**Hook target**:
The command or script that a hook runs around.
_Avoid_: hookable command

### Workspaces

**Workspace root**:
The directory whose `pubspec.yaml` lists the workspace and whose `dpk.yaml` holds the shared configuration.
_Avoid_: monorepo root

**Workspace package**:
A package listed in the workspace, other than the workspace root.
_Avoid_: member, subpackage

**Catalog**:
Shared package metadata and dependency versions, defined at the workspace root, that dpk applies to each workspace package.
_Avoid_: catalog mode

**Catalog dependency**:
A dependency whose version the catalog sets. dpk updates it only in workspace packages that already depend on it.
_Avoid_: shared dependency

### Dependency storage

**Global mode**:
The default mode, where pub stores packages in the global pub cache.

**Project mode**:
The mode where dpk stores packages in the project cache so that you can patch them.
_Avoid_: project cache mode

**Project cache**:
The `pub_packages/` directory where project mode stores packages.
_Avoid_: patch cache, local cache, pub_packages directory

**Patch**:
A file in `patches/` that records your changes to one package in the project cache.
_Avoid_: diff
