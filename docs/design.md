# Git Activity Reporter Design

## Purpose

A modular Bash-based Git reporting system.

The project is designed as a collection of independent report sections controlled by a main execution script.

---

# Architecture

```
gitar
|
|-- config.sh
|
|-- lib/
|    |-- arguments.sh
|    |-- colors.sh
|    |-- ui.sh
|    |-- helpers.sh
|    |-- logger.sh
|
|-- sections/
     |-- header.sh
     |-- sync.sh
     |-- commits.sh
     |-- daily-summary.sh
     |-- statistics.sh
```

---

# Design Principles

## 1. Main controller

gitar controls execution flow.

Sections should not know about command line arguments.

---

## 2. Modular sections

Each report component is independent.

Examples:

- repository synchronization
- commit details
- daily statistics
- future analytics

---

## 3. Shared UI layer

All visual output goes through lib/ui.sh.

Sections should not directly implement:

- colors
- progress indicators
- spinners
- animations

---

## 4. Configuration driven

Default values live in config.sh.

Examples:

- repository path
- date ranges
- enabled sections
- UI mode

---

## 5. Command line overrides

Runtime arguments override defaults.

Examples:

```
--days 30
--sections commits,daily-summary
--no-sync
--ui dots
```

---

# Initial Sections

## Header

Displays:

- report title
- timestamp
- repository

## Sync

Handles:

- fetch
- pull safety
- local changes detection

## Commits

Displays detailed commits.

Default:

7 days

## Daily Summary

Displays daily changes.

Default:

14 days

---

# Future Ideas

- branch statistics
- contributors
- largest commits
- AI generated summaries
- markdown output
- HTML reports