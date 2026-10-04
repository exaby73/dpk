# dpk options go before the command

dpk reads its own options, such as `-C`, `-v`, and `--help`, only before the command name. Every argument after the command name belongs to the command and reaches it unchanged. Until 0.x, dpk scanned the whole command line for its options, so `dpk run test -v` lost `-v` to dpk, `dpk run test --coverage` failed as an unknown option, and `dpk run build --version` printed dpk's version instead of running the script.

The alternative was to keep scanning and require `--` before script arguments, as `dpk run test -- --coverage`. That is easy to forget, and npm, pnpm, and `git -C` all treat options after the command as the command's. With this rule, `dpk add http -C packages/a` passes `-C` to `dart pub add`, so dpk's own `-C` has to come first: `dpk -C packages/a add http`. dpk still drops one leading `--` after a script name, so old command lines keep working.
