# AGENTS.md

Follow these rules when working in this repository:

1. Use `dpk add` for dependency additions. If a forwarded pub option is needed, prefer first-class `dpk` support and use `--` only as a temporary escape hatch.
2. Keep CLI changes covered by tests. Prefer GWT-style `group`/`test` structure and use `test_descriptor` for temporary package/workspace fixtures.
3. Do not run broad format commands over dependency caches such as `pub_packages`. Format targeted project paths, for example `dart format bin lib test`.
4. When generating a commit message or PR title, use the Git Committer skill rules.
