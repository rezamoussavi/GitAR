# Security Policy

## Supported Versions

GitAR is currently in early development.

Security fixes will generally be applied to the latest released version.

| Version | Supported |
| --- | --- |
| 0.1.x | Yes |
| Earlier versions | No |

## Reporting a Vulnerability

Please do not report suspected security vulnerabilities through public GitHub issues.

Until a dedicated private reporting channel is configured, contact the project maintainer directly through the contact options available on the GitHub profile of **Reza Moussavi**.

When reporting a vulnerability, please include:

- the affected GitAR version
- operating system and shell
- a description of the issue
- steps to reproduce it
- potential impact
- any suggested mitigation, if known

Please avoid including unrelated secrets, credentials, private repository contents, or sensitive personal information.

## Security Scope

GitAR interacts with local Git repositories and may execute read and synchronization operations including:

- `git log`
- `git fetch`
- `git status`
- fast-forward-only `git pull`

GitAR is intentionally designed to avoid automatic destructive merge or overwrite behavior.

Security reports involving command execution, profile parsing, repository path handling, temporary files, or unsafe Git operations are especially relevant.