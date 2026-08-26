# Usage

## Basic

Run GitAR in the current Git repository:

```bash
gitar
```

Help:

```bash
gitar -h
gitar --help
```

Version:

```bash
gitar --version
```

Environment check:

```bash
gitar --doctor
```

Update a managed installation:

```bash
gitar --update
```

## Profiles

List built-in and user profiles:

```bash
gitar --profiles
```

Run a profile:

```bash
gitar -p weekly
gitar --profile detailed
```

Show built-in defaults:

```bash
gitar --defaults
```

User profiles are stored in:

```text
~/.config/gitar/profiles/
```

or:

```text
$XDG_CONFIG_HOME/gitar/profiles/
```

User profiles take precedence over built-in profiles with the same name. The built-in `default` profile is always controlled by GitAR.

## Sections

Run selected report sections:

```bash
gitar -s commits
gitar -s commits,daily-summary
gitar -s header,commits,statistics
```

Available sections:

```text
header
sync
commits
daily-summary
statistics
```

## Durations

```bash
gitar -d 30
gitar -c 7
gitar -y 14
```

- `-d` sets all time-based durations.
- `-c` sets commit-detail duration.
- `-y` sets daily-summary and statistics duration.

Durations are calendar-day windows including today.

## Synchronization

Disable synchronization:

```bash
gitar -n
gitar --no-sync
```

Enable explicitly:

```bash
gitar --sync
```

GitAR uses conservative synchronization and avoids destructive merge behavior.

## Legend

Show the normally hidden legend:

```bash
gitar -l
gitar --legend
```

Hide explicitly:

```bash
gitar --no-legend
```

## UI

```bash
gitar -u dots
gitar -u normal
gitar -u quiet
```

## Verbose

```bash
gitar -v
```

## Overrides

Later command-line arguments override earlier profile values.

Example:

```bash
gitar -p weekly -c 3
```

loads the `weekly` profile, then changes commit-detail duration to three calendar days.