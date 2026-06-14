---
name: dpk
description: Use dpk as an end-user CLI for Dart pub workflows, scripts, hooks, project caches, catalogs, patches, and dpk-specific command behavior.
---

# dpk Skill

Use this skill when helping someone use the `dpk` CLI in a Dart package or
workspace. The guidance is for end users and agents operating the CLI, not for
modifying dpk internals.

Run this guide from the CLI with:

```bash
dpk skills
```

`dpk skills` is configless. It works even when the current directory has no
`dpk.yaml` or `pubspec.yaml`.

## What dpk Does

`dpk` wraps common `dart pub` workflows and adds project conventions:

1. `dpk.yaml` configuration with a required `version` constraint.
2. Optional project-local package cache mode.
3. Configured scripts through `dpk run`.
4. Workspace-aware script execution.
5. Catalog-driven `pubspec.yaml` edits during `dpk get`.
6. Command hooks through `before`, `after`, `pre:<command>`, and
   `post:<command>` scripts.
7. Patch workflows for packages in a project-local cache.

## Basic Setup

Create a `dpk.yaml` beside the package `pubspec.yaml`:

```yaml
version: ^0.8.0
```

Use project cache mode when dependencies should be stored in a local
`pub_packages` directory:

```yaml
version: ^0.8.0
mode: project
```

Useful global options:

```bash
dpk -C packages/app get
dpk --directory packages/app run test
dpk --cache-dir .pub-cache get
dpk --verbose get
dpk --debug run build
```

## Command Map

Dedicated dpk commands:

- `dpk init` creates `dpk.yaml`.
- `dpk skills` prints this guide.
- `dpk get` runs dpk-aware dependency resolution, catalog updates, sorting, and
  cache setup.
- `dpk run <script>` runs a script from `dpk.yaml`.
- `dpk patch init`, `dpk patch generate`, and `dpk patch apply` manage package
  patches.

Pub passthrough commands:

- `dpk add`
- `dpk bump`
- `dpk cache`
- `dpk deps`
- `dpk downgrade`
- `dpk global`
- `dpk login`
- `dpk logout`
- `dpk outdated`
- `dpk publish`
- `dpk remove`
- `dpk token`
- `dpk unpack`
- `dpk upgrade`
- `dpk update`, an alias for `dpk upgrade`
- `dpk workspace`

These passthrough commands run the matching `dart pub <command>` flow. They
also support dpk config discovery, project cache environment setup, dpk global
options, and hooks.

`dpk get` remains a dedicated dpk command because it performs extra dpk work
before and after dependency resolution.

## Dependency Commands

Add dependencies:

```bash
dpk add lints
dpk add --dev test
```

Fetch dependencies:

```bash
dpk get
dpk get --offline
dpk get --enforce-lockfile
```

Upgrade, downgrade, inspect, or remove dependencies:

```bash
dpk upgrade
dpk update
dpk downgrade
dpk outdated
dpk deps
dpk remove lints
```

Run from another directory:

```bash
dpk -C packages/my_package get
dpk -C packages/my_package add collection
```

## Scripts

Define scripts in `dpk.yaml`:

```yaml
version: ^0.8.0
scripts:
  analyze: dart analyze
  test: dart test
  build:
    command: dart run build_runner build -d
```

Run scripts:

```bash
dpk run analyze
dpk run test
dpk run build
```

Pass arguments to scripts after the script name:

```bash
dpk run test --coverage
```

Use object-form scripts when a script needs environment variables, workspace
package execution, or inherited hooks:

```yaml
version: ^0.8.0
scripts:
  test:
    command: dart test
    env:
      CI: "true"
  test_all:
    command: dart test
    runInPackages:
      - packages/*
```

When `runInPackages` is used, dpk runs the command in each matching workspace
package and sets `DPK_ROOT` to the workspace root.

## Calling dpk Scripts From Other dpk Scripts

To run one dpk script from another dpk script, write the normal CLI command in
the script body:

```yaml
version: ^0.8.0
scripts:
  clean: dart run build_runner clean
  build:
    command: |
      dpk run clean
      dart run build_runner build -d
  publish:
    command: |
      dpk run build
      dpk publish
```

Use `dpk run <script>` explicitly. Do not call the script by bare name.

## Hooks

Scripts named `pre:<command>` and `post:<command>` run around matching dpk
commands:

```yaml
version: ^0.8.0
scripts:
  pre:get: echo "Before get"
  post:get: echo "After get"
```

Use `before` and `after` for shared hooks. They can target selected scripts:

```yaml
version: ^0.8.0
scripts:
  before:
    scripts:
      - test
      - build
    command: echo "Before selected scripts"
  after:
    scripts:
      - test
      - build
    command: echo "After selected scripts"
  test: dart test
  build: dart run build_runner build -d
```

Or target every hookable command with `all: true`:

```yaml
version: ^0.8.0
scripts:
  before:
    all: true
    command: echo "Before everything"
  after:
    all: true
    command: echo "After everything"
```

Hook order for most hookable commands is:

1. `before`
2. `pre:<command>`
3. the requested command
4. `post:<command>`
5. `after`

`dpk get` is special because scripts such as builds often require packages to
be fetched first. For `get`, matching `before` hooks are promoted into the
post-get phase:

1. `pre:get`
2. `dart pub get`
3. `before`
4. `post:get`
5. `after`

Hook scripts do not recursively hook `before`, `after`, `pre:*`, or `post:*`
themselves. If a `before` or `after` hook runs a script that would trigger the
same hook again, dpk skips the recursive hook and reports that it avoided an
infinite hook loop. This allows patterns such as running a build before other
scripts:

```yaml
version: ^0.8.0
scripts:
  before:
    scripts:
      - analyze
      - get
      - publish
      - watch
    command: dpk run build
  build: dart run build_runner build -d
  analyze: dart analyze
```

## Workspace Scripts

Use `runInPackages` to run a script across matching workspace packages:

```yaml
version: ^0.8.0
scripts:
  test_all:
    command: dart test
    runInPackages:
      - packages/*
```

Package-level `dpk.yaml` files can define package-specific scripts. Root
scripts are inherited by workspace packages, and package scripts take precedence
when names conflict.

## Catalog and Pubspec Updates

Use the catalog when dependencies should be managed centrally. During `dpk get`,
dpk can update matching dependency entries in root and workspace
`pubspec.yaml` files before running pub.

Example:

```yaml
version: ^0.8.0
catalog:
  dependencies:
    collection: ^1.19.1
  dev_dependencies:
    test: ^1.25.15
sortPubspec: true
```

Catalog-managed dependency comments may use placeholders such as
`DPK_PACKAGE_NAME`, `DPK_PACKAGE_VERSION`, and `DPK_PACKAGE_PATH` in configured
repository, issue tracker, or documentation links.

## Project Cache Mode

Project cache mode stores pub packages in a local cache instead of the default
global pub cache:

```yaml
version: ^0.8.0
mode: project
```

When project mode is enabled, dpk sets `PUB_CACHE` for dependency commands and
scripted pub flows that need the project cache.

## Patches

Patch commands require project cache mode:

```yaml
version: ^0.8.0
mode: project
```

Typical patch flow:

```bash
dpk get
dpk patch init
# edit packages under pub_packages
dpk patch generate
dpk patch apply
```

Use `--force` with `patch apply` only when it is acceptable to discard local
changes in the patch cache before applying saved patches:

```bash
dpk patch apply --force
```

## Agent Workflow

When operating dpk for a user:

1. Inspect `dpk.yaml` and `pubspec.yaml` first.
2. Run `dpk skills` when exact CLI behavior is needed.
3. Prefer `dpk add`, `dpk remove`, `dpk get`, and other dpk commands over
   direct `dart pub` calls when the project is configured for dpk.
4. Use `dpk run <script>` for configured workflows.
5. Use `dpk -C <directory>` instead of changing directories when running a
   command in another package.
