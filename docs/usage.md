# Usage

## Default

```bash
gitar
```

## Help

```bash
gitar -h
gitar --help
```

## Profiles

List profiles:

```bash
gitar --profiles
```

Run a profile:

```bash
gitar -p weekly
gitar --profile detailed
```

Show defaults:

```bash
gitar --defaults
```

## Sections

```bash
gitar -s commits
gitar -s commits,daily-summary
gitar -s header,commits,statistics
```

Available sections:

- header
- sync
- commits
- daily-summary
- statistics

## Durations

```bash
gitar -d 30
gitar -c 7
gitar -y 14
```

`-d` changes all time-based durations.

`-c` controls detailed commits.

`-y` controls daily summary and statistics.

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

## Legend

Hidden by default:

```bash
gitar
```

Show:

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

Later arguments override earlier configuration.

Example:

```bash
gitar -p weekly -c 3
```

loads the weekly profile and then changes the commit-detail duration to three calendar days.
