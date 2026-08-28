# Changelog

All notable changes to GitAR will be documented in this file.

The project follows semantic versioning where practical.

## Unreleased

### Added

- `gitar --options` for complete CLI option reference.
- `gitar --examples` for practical task-oriented examples.
- Repository relationship reporting after remote refresh.

### Changed

- Clarified GitAR's update-check status in the report header.
- Moved the repository name into the repository-status heading.
- `--no-sync` now preserves local repository status while skipping remote refresh.
- Show the repository name in the report header instead of the configured path value.
- Simplified `gitar -h` / `gitar --help` for quick beginner-oriented help.
- GitAR now refreshes remote information with `git fetch` without automatically pulling or moving the local branch.
- `--sync` now refreshes remote status; `--no-sync` prevents remote contact.


## [0.3.0] - 2026-08-27

### Added

- macOS support with zsh
- macOS installer PATH configuration

### Fixed

- Support BSD `date` used by macOS
- Use shell-neutral installer instructions

## [0.2.1] - 2026-08-27

### Fixed

- Ensure GitAR is available automatically in new Git Bash sessions after installation.
- Configure `.bash_profile` to load `.bashrc` when needed.

## [0.2.0] - 2026-08-26

### Added

- One-command GitAR installer
- Global `gitar` command installation
- `gitar --version`
- `gitar --doctor`
- `gitar --update`
- Monthly automatic update checks
- Exact last-update-check timestamp
- Managed-installation detection
- External user profile directory
- User profile precedence over built-in profiles
- Safe uninstall script
- Beginner-friendly non-repository guidance

### Changed

- Improved first-time onboarding
- Reorganized README around simple installation and first use
- User profiles are now stored outside the GitAR installation
- Built-in profiles remain managed by GitAR

## [0.1.0] - 2026-08-25

### Added

- Initial public release of GitAR
- Modular Bash reporting architecture
- Detailed Git commit reporting
- Daily activity summaries
- Aggregate Git activity statistics
- Feature, fix, and other commit classification
- Change-size color indicators
- Safe repository synchronization
- Calendar-day reporting windows
- Reusable report profiles
- Default profile support
- Repository-specific profiles
- Selectable report sections
- Short and long CLI arguments
- Configurable UI modes
- Optional legend and author banner
- Verbose diagnostic mode
- Shared normalized Git history data layer
- Duration-aware temporary data caching
- Git and repository preflight validation

### Tested

- Windows Git Bash
