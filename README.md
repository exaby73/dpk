## Getting started with patches

Generate the `pub_packages` directory.

```bash
dpk pub get
```

### Initialize patches.

```bash
dpk patch init
```

This will intialize a git repository in the `pub_packages` directory, and add one commit with the initial state of the dependencies.

### Generate the patch files after you've made changes to the dependencies.

```bash
dpk patch generate
```

This will generate a patch file for each dependency that has changed using the `git diff` command. This will delete any existing patch files before generating new ones, so if you have any unapplied patches, apply them first, else you will lose them.

### Apply the patch files to the dependencies.

```bash
dpk patch apply
```

This will apply the patch files to the dependencies. It will undo all previous applied patches, then apply the new ones. Therefore, this can also be used to delete patches by deleting any patch file and running this command.
