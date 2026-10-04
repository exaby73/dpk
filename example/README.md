# dpk example

This example sets up a pub workspace with two packages, a catalog, and scripts that run across the packages.

## Files

`pubspec.yaml` at the workspace root:

```yaml
name: my_workspace
publish_to: none
environment:
  sdk: ^3.11.0
```

`dpk.yaml` at the workspace root:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/exaby73/dpk/main/schema/dpk.schema.json
version: ^1.0.0
sort_pubspec: true

workspace:
  - packages/*

catalog:
  environment:
    sdk: ^3.11.0
  repository: https://github.com/me/my_workspace/tree/main/DPK_PACKAGE_PATH
  dependencies:
    http: ^1.2.0
    test: ^1.25.0

scripts:
  analyze:
    command: dart analyze
    description: Analyze every package.
  test:
    command: dart test
    description: Run the tests in every package.
    run_in_packages: [packages/*]
    fail_fast: true
  pre:test: dpk run analyze
```

`packages/core/pubspec.yaml` and `packages/app/pubspec.yaml`, each with `resolution: workspace`:

```yaml
name: core
resolution: workspace
dependencies:
  http: any
dev_dependencies:
  test: any
```

## Commands

```bash
dpk get                       # write the workspace list, apply the catalog, get dependencies
dpk get --check               # in CI: fail if dpk get would change a file
dpk run                       # list the scripts
dpk run test                  # analyze, then test every package in parallel
dpk run --filter core test    # test one package
dpk exec -- dart format .     # run any command in every package
dpk list --graph              # show the packages and their dependencies
dpk release version --dry-run # preview versions and changelogs from Conventional Commits
```
