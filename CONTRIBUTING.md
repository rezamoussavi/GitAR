# Contributing to GitAR

Thank you for considering a contribution to GitAR.

GitAR is a small modular Bash project, and contributions that improve portability, reliability, reporting, documentation, and usability are welcome.

## Before You Start

Please check existing issues before opening a new one.

For larger changes, consider opening an issue first so the proposed behavior can be discussed before implementation.

## Development Requirements

GitAR currently requires:

- Bash
- Git
- `awk`
- standard Unix command-line utilities

The initial release is tested on Windows Git Bash.

If you test or improve GitAR on Linux or macOS, please include platform details in your contribution.

## Project Structure

```text
GitAR/
├── gitar
├── config.sh
├── lib/
├── sections/
├── profiles/
└── docs/
```

### `gitar`

Main controller and CLI entry point.

### `lib/`

Shared infrastructure such as:

- command-line parsing
- profiles
- data normalization
- terminal UI
- preflight checks
- section management

### `sections/`

Independent report sections.

A section should expose a function using the convention:

```text
section_<name>()
```

Hyphens in filenames are converted to underscores.

Example:

```text
daily-summary.sh
```

implements:

```bash
section_daily_summary()
```

### `profiles/`

Reusable configuration profiles.

`profiles/default.conf` defines the default behavior of GitAR.

Other profiles inherit the default values and only need to override what differs.

## Development Guidelines

Please try to preserve the following design principles:

- keep `gitar` small and focused on orchestration
- put shared behavior in `lib/`
- keep report logic in `sections/`
- avoid duplicating Git history parsing between sections
- reuse the normalized data layer where practical
- avoid destructive Git operations
- keep CLI behavior backward-compatible where reasonable
- use `printf` rather than relying on shell-specific `echo -e`
- keep public profiles free of personal or machine-specific paths

## Bash Syntax Check

Before submitting a change, run:

```bash
bash -n gitar
```

and:

```bash
for f in config.sh lib/*.sh sections/*.sh; do
    bash -n "$f" || echo "Syntax problem: $f"
done
```

There should be no syntax errors.

## Basic Smoke Tests

Useful commands include:

```bash
./gitar -h
./gitar --defaults
./gitar --profiles
./gitar -s commits
./gitar -s daily-summary
./gitar -s statistics
./gitar -v
```

Test profile overrides where relevant:

```bash
./gitar -p weekly -c 3
```

## Reporting Bugs

When reporting a bug, please include:

- GitAR version
- operating system
- Bash version
- Git version
- command used
- expected behavior
- actual behavior
- relevant error output

Do not include secrets, credentials, private repository contents, or sensitive paths unless they are necessary and safe to share.

## Pull Requests

A pull request should:

- describe the problem being solved
- explain the approach taken
- include relevant testing
- avoid unrelated changes
- update documentation when behavior changes

Small focused pull requests are preferred.

## Commit Messages

Clear commit messages are encouraged.

GitAR itself recognizes common prefixes such as:

```text
feat:
fix:
docs:
chore:
```

but contributors are not required to use a strict conventional-commit workflow.

## Security Issues

Do not report security vulnerabilities through public issues.

Please follow the process described in:

```text
SECURITY.md
```

## License

By contributing to GitAR, you agree that your contribution will be licensed under the MIT License used by the project.