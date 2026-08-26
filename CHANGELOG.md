# Changelog

All notable changes to GitAR will be documented in this file.

The project follows semantic versioning where practical.

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
