# GitAR — Git Activity Reporter

**GitAR** is a Bash command-line tool that turns Git history into a readable activity report.

It is designed for people who want useful Git reporting without working directly with long or complicated `git log` commands.

GitAR can show:

- recent commits
- lines added and deleted
- daily activity summaries
- feature and fix activity
- workload statistics
- largest commits and development days
- configurable reporting periods
- reusable report profiles

**Author:** Reza Moussavi  
**License:** MIT

---

# Quick Start

GitAR currently supports **Windows with Git Bash**.

If you already have Git for Windows installed, Git Bash is normally included.

## 1. Install GitAR

Open **Git Bash** and run:

```bash
curl -fsSL https://raw.githubusercontent.com/rezamoussavi/GitAR/main/install.sh | bash
```

The installer:

- downloads GitAR
- installs the `gitar` command
- makes it available from your terminal
- prepares your personal profile directory

If the installer asks you to open a new Git Bash terminal, close and reopen Git Bash before continuing.

---

## 2. Open Your Git Project

Move into any Git repository.

For example:

```bash
cd /path/to/your-project
```

---

## 3. Run GitAR

```bash
gitar
```

That's it.

GitAR will generate a report for the Git repository in your current folder.

---

# First-Time Help

Check that GitAR is installed correctly:

```bash
gitar --doctor
```

Show the installed version:

```bash
gitar --version
```

Show command-line help:

```bash
gitar -h
```

List available report profiles:

```bash
gitar --profiles
```

---

# Example Output

A GitAR report may include sections such as:

```text
Timestamp         : 2026-08-26 01:10
Repo              : .
Last update check : 2026-08-26 01:02:53
Customize         : gitar -h
```

Commit activity:

```text
Commit Details (last 7 days)

2026-08-23 22:50 :     120 : fix: correct budget position presentation [+105, -15]
2026-08-23 22:27 :   1,103 : feat: add analysis budget position presentation [+1097, -6]
```

Daily activity:

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

# Requirements

GitAR currently requires:

- Git
- Bash
- `awk`
- standard Unix command-line utilities

## Tested Platform

The current release has been tested on:

- Windows
- Git Bash

Native PowerShell is not currently supported.

Linux and macOS may work, but they have not yet been officially tested.

---

# Updating GitAR

GitAR can update installations created by `install.sh`.

Run:

```bash
gitar --update
```

GitAR also performs a lightweight automatic update check at most once per calendar month.

The automatic check:

- does not install anything
- does not interrupt your report
- only checks whether a newer GitAR version may be available
- records the exact time of the most recent check

If an update is available, GitAR will tell you to run:

```bash
gitar --update
```

You can see the last automatic check using:

```bash
gitar --doctor
```

---

# Uninstalling GitAR

From a cloned GitAR repository, run:

```bash
./uninstall.sh
```

The uninstaller removes:

- the installed GitAR application
- the global `gitar` command
- GitAR's update-check state

Your personal profiles are preserved.

This allows you to reinstall GitAR later without losing your configuration.

## Remove Personal Profiles Too

If you want to permanently remove your personal GitAR configuration as well:

```bash
rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/gitar"
```

**Warning:** this permanently removes your personal GitAR profiles.

---

# Default Report

Running:

```bash
gitar
```

uses GitAR's built-in default profile.

The default profile controls:

- repository path
- enabled report sections
- detailed commit duration
- daily summary duration
- synchronization
- legend visibility
- UI mode
- verbose mode

View the default settings:

```bash
gitar --defaults
```

---

# Command-Line Options

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
gitar --doctor
gitar --version
gitar --update
```

---

# Report Sections

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

# Reporting Periods

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

# Profiles

GitAR supports both built-in and personal profiles.

List them with:

```bash
gitar --profiles
```

## Built-In Profiles

GitAR includes:

```text
default
weekly
detailed
```

The built-in default profile is part of the GitAR installation.

## Personal Profiles

Your own profiles are stored outside the GitAR installation:

```text
~/.config/gitar/profiles/
```

or, when `XDG_CONFIG_HOME` is configured:

```text
$XDG_CONFIG_HOME/gitar/profiles/
```

This keeps your own configuration safe when GitAR is updated.

Example personal profile:

```text
repo_path=/path/to/project
commits_days=14
summary_days=30
sync=false
```

Save it as:

```text
~/.config/gitar/profiles/my-project.conf
```

Then run:

```bash
gitar -p my-project
```

Personal profiles inherit unspecified values from GitAR's built-in default profile.

---

# Profile Precedence

When loading a named profile, GitAR checks:

```text
1. Personal profile directory
2. Built-in profile directory
```

This means a personal profile may intentionally override a built-in profile with the same name.

For example:

```text
~/.config/gitar/profiles/weekly.conf
```

will override GitAR's built-in `weekly` profile.

The built-in `default` profile cannot be replaced by a personal `default.conf`.

Command-line arguments applied after a profile override the profile value.

Example:

```bash
gitar -p weekly -c 3
```

loads the `weekly` profile, then changes the commit reporting period to 3 days.

---

# Repository Synchronization

The `sync` section performs a conservative repository update:

1. runs `git fetch --all`
2. checks for uncommitted local changes
3. skips automatic pull when local work is present
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

# Legend

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

# UI Modes

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

# Verbose Mode

For diagnostic information:

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

# Development Installation

If you prefer to clone and run GitAR manually instead of using the installer:

```bash
git clone https://github.com/rezamoussavi/GitAR.git
cd GitAR
chmod +x gitar
./gitar
```

For normal users, the one-command installer is recommended.

---

# Architecture

GitAR is designed as a modular Bash project:

```text
GitAR/
├── gitar
├── install.sh
├── uninstall.sh
├── VERSION
├── config.sh
├── lib/
├── sections/
├── profiles/
└── docs/
```

## `gitar`

Main controller and executable entry point.

## `lib/`

Shared infrastructure including:

- CLI parsing
- terminal UI
- profiles
- Git data normalization
- preflight validation
- update management
- environment diagnostics
- report section management

## `sections/`

Independent report components.

## `profiles/`

Built-in report profiles.

User-created profiles are stored outside the installation.

## Data Layer

Git history is normalized into temporary tab-separated datasets.

Different report sections can reuse those datasets instead of repeatedly executing and parsing the same Git history.

Datasets are automatically removed when GitAR exits.

---

# Contributing

Contributions are welcome.

Please read:

```text
CONTRIBUTING.md
```

before submitting issues or pull requests.

---

# Security

Please do not report security vulnerabilities in public issues.

See:

```text
SECURITY.md
```

for reporting instructions.

---

# Project Status

GitAR is currently an early public release.

The command-line interface, report formats, installer behavior, and profile format may continue to evolve while the project gains wider testing and feedback.

---

# Author

GitAR was created by **Reza Moussavi**.

---

# License

GitAR is released under the MIT License.

See `LICENSE` for details.