---
name: dpk
description: Use the dpk Dart CLI to manage dependencies, run scripts, use project-local package caches, and generate/apply package patches.
---

# dpk Skill

Use this skill when helping someone use the `dpk` CLI in a Dart package or
workspace.

## What dpk Does

`dpk` is a Dart package-management helper that wraps common `dart pub`
workflows and adds:

1. `dpk.yaml` configuration with a required `version` constraint.
2. Optional project-local package cache mode.
3. Configured scripts through `dpk run`.
4. Workspace-aware script execution.
5. Catalog-driven pubspec edits.
6. Patch workflows for packages in a project-local cache.

## Basic Setup

Create a `dpk.yaml` beside the package `pubspec.yaml`:

```yaml
version: ^0.6.0
```

Use project cache mode when dependencies should be stored in a local
`pub_packages` directory:

```yaml
version: ^0.6.0
mode: project
```

## Common Commands

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

Upgrade or downgrade dependencies:

```bash
dpk upgrade
dpk downgrade
```

Run from another directory:

```bash
dpk -C packages/my_package get
```

## Scripts

Define scripts in `dpk.yaml`:

```yaml
version: ^0.6.0
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
```

Pass arguments to scripts after the script name:

```bash
dpk run test --coverage
```

## Hooks

Scripts named `pre:<command>` and `post:<command>` run around matching dpk
commands when configured:

```yaml
version: ^0.6.0
scripts:
  pre:get: echo "Before get"
  post:get: echo "After get"
```

## Workspace Scripts

Use `runInPackages` to run a script across matching workspace packages:

```yaml
version: ^0.6.0
scripts:
  test_all:
    command: dart test
    runInPackages:
      - packages/*
```

## Patches

Patch commands require project cache mode:

```yaml
version: ^0.6.0
mode: project
```

Typical patch flow:

```bash
dpk get
dpk patch init
# edit packages under pub_packages
dpk patch generate
dpk patch apply --force
```

Use `--force` with `patch apply` only when it is acceptable to discard local
changes in the patch cache before applying saved patches.
