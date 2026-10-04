# Scripts run in a fixed shell

dpk runs every script with `/bin/sh -c`, or `cmd.exe /d /s /c` on Windows, instead of the user's login shell from `$SHELL`. Until 0.x, dpk used `$SHELL`, so one `dpk.yaml` behaved differently for each teammate: a script that worked in zsh failed in fish or nushell, whose `-c` syntax and quoting differ, and the argument quoting dpk adds is POSIX quoting that those shells do not read. A fixed shell gives every teammate and every CI runner the same behavior, which is what npm, pnpm, and other script runners do.

The cost is that scripts cannot use features of the user's own shell, such as zsh globbing or fish functions. A script that needs another shell can call it explicitly, as in `command: zsh -c 'print -l **/*.dart'`.
