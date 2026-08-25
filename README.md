# GitAR — Git Activity Reporter

**GitAR** is a modular Bash command-line tool for generating readable Git activity reports.

It combines detailed commit history, daily change summaries, repository synchronization, workload statistics, configurable time windows, and reusable profiles into a single report.

**Author:** Reza Moussavi  
**Version:** 0.1.0  
**License:** MIT

---

## Features

- Detailed commit activity with insertion/deletion counts
- Color-coded change-size indicators
- `feat:` and `fix:` commit highlighting
- Daily Git activity summaries
- Commit counts per active day
- Aggregate development statistics
- Largest commit and largest development day
- Daily workload distribution
- Safe Git fetch / fast-forward pull behavior
- Configurable reporting periods
- Reusable report profiles
- Selectable report sections
- Compact, normal, and quiet UI modes
- Optional report legend
- Verbose diagnostic mode
- Shared Git data cache to avoid repeated history scans

---

## Requirements

GitAR currently requires:

- Bash
- Git
- `awk`
- standard Unix command-line utilities

### Tested Platform

GitAR `v0.1.0` has been tested with:

- Windows
- Git Bash

Linux and macOS may work, but they have not yet been officially tested for this release.

---

## Quick Start

Clone the repository:

```bash
git clone https://github.com/rezamoussavi/GitAR.git
cd GitAR
```

Make GitAR executable:

```bash
chmod +x gitar
```

Run it from inside a Git repository:

```bash
/path/to/GitAR/gitar
```

GitAR's default profile uses:

```text
repo_path=.
```

so the repository in your current working directory is analyzed.

---

## Install as a Command

To run GitAR simply as:

```bash
gitar
```

place it somewhere in your `PATH`, or create a symbolic link.

For example:

```bash
mkdir -p ~/.local/bin
ln -s /path/to/GitAR/gitar ~/.local/bin/gitar
```

Ensure `~/.local/bin` is included in your `PATH`.

---

## Default Report

Running:

```bash
gitar
```

loads:

```text
profiles/default.conf
```

The default profile controls:

- repository path
- enabled report sections
- detailed commit duration
- daily summary duration
- synchronization
- legend visibility
- UI mode
- verbose mode

View the active defaults:

```bash
gitar --defaults
```

List available profiles:

```bash
gitar --profiles
```

---

## Example Report Sections

A default report may contain:

```text
Commit Details (last 7 days)

2026-08-23 22:50 :     120 : fix: correct budget position presentation [+105, -15]
2026-08-23 22:27 :   1,103 : feat: add analysis budget position presentation [+1097, -6]
```

Daily summaries:

```text
Daily Summary (last 14 days)

2026-08-23 :   4,405  [ 8 Commits ]  Lines changed [+4245, -160]
2026-08-22 :     676  [ 2 Commits ]  Lines changed [+590, -86]
```

Statistics:

```text
Statistics (last 14 days)

Total commits             : 43
Features                  : 17
Fixes                     : 13
Other                     : 13

Lines added               : 41,217
Lines deleted             : 1,904
Total lines changed       : 43,121

Largest commit            : 4,578 lines
Largest day               : 10,787 lines
Average commits / day     : 4.30
```

---

## Command-Line Options

Run:

```bash
gitar -h
```

for the complete command reference.

Common examples:

```bash
gitar
gitar -s commits
gitar -s commits,daily-summary
gitar -c 7
gitar -y 30
gitar -d 14
gitar -n
gitar -l
gitar -v
gitar -p weekly
```

---

## Report Sections

Available sections:

```text
header
sync
commits
daily-summary
statistics
```

Run only selected sections:

```bash
gitar -s commits,daily-summary
```

---

## Reporting Periods

GitAR uses calendar-day windows including today.

For example:

```bash
gitar -c 7
```

means:

> today plus the previous six calendar days.

Likewise:

```bash
gitar -y 14
```

means:

> today plus the previous thirteen calendar days.

Available duration controls include:

```text
-d, --days
-c, --commits-days
-y, --summary-days
```

---

## Profiles

Profiles are stored in:

```text
profiles/
```

The default profile is:

```text
profiles/default.conf
```

Example:

```text
repo_path=.
sections=header,sync,commits,daily-summary,statistics
commits_days=7
summary_days=14
ui=dots
sync=true
legend=false
verbose=false
```

Run another profile:

```bash
gitar -p weekly
```

or:

```bash
gitar --profile detailed
```

Profiles inherit values from `default.conf` and only need to specify values they want to override.

Command-line arguments specified after a profile override profile values:

```bash
gitar -p weekly -c 3
```

---

## Repository-Specific Profiles

You can create profiles for individual repositories.

Example:

```text
repo_path=/path/to/project
commits_days=14
summary_days=30
```

Then run:

```bash
gitar -p my-project
```

Private or machine-specific profiles can be excluded using:

```text
profiles/local.conf
profiles/private-*.conf
```

which are ignored by Git by default.

---

## Repository Synchronization

The `sync` section performs a conservative repository update:

1. `git fetch --all`
2. checks for uncommitted local changes
3. skips automatic pull if local work is present
4. otherwise attempts a fast-forward-only pull

GitAR does not automatically merge divergent branches or overwrite local work.

Disable synchronization:

```bash
gitar -n
```

or:

```bash
gitar --no-sync
```

---

## Legend

The legend is hidden by default.

Show it with:

```bash
gitar -l
```

or:

```bash
gitar --legend
```

The legend also displays the GitAR author banner.

---

## UI Modes

Available modes:

```text
dots
normal
quiet
```

Example:

```bash
gitar -u quiet
```

---

## Verbose Mode

For diagnostics:

```bash
gitar -v
```

Verbose output includes information such as:

- project directory
- selected repository
- active profile
- reporting periods
- selected sections
- temporary data-cache behavior

---

## Architecture

GitAR is designed as a small modular Bash project:

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

Main controller and executable entry point.

### `lib/`

Shared infrastructure including:

- CLI parsing
- terminal UI
- profiles
- Git data normalization
- preflight validation
- report section management

### `sections/`

Independent report components.

### `profiles/`

Default and reusable report configurations.

### Data Layer

Git history is normalized into temporary tab-separated datasets.

Different report sections can reuse those datasets instead of repeatedly executing and parsing the same Git history.

Datasets are automatically removed when GitAR exits.

---

## Contributing

Contributions are welcome.

Please read:

```text
CONTRIBUTING.md
```

before submitting issues or pull requests.

---

## Security

Please do not report security vulnerabilities in public issues.

See:

```text
SECURITY.md
```

for reporting instructions.

---

## Project Status

GitAR is currently at **v0.1.0**.

The command-line interface, report formats, and profile format may evolve while the project gains wider testing and feedback.

---

## Author

GitAR was created by **Reza Moussavi**.

---

## License

GitAR is released under the MIT License.

See `LICENSE` for details.