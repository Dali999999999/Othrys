# Contributing to Othrys

Thank you for your interest in contributing to **Othrys**! We are building an industrial-grade, secure, and modern desktop control center for Linux infrastructure and VPS management. 

Whether you are fixing a bug, adding a new container inspection capability, improving performance, or translating documentation, your contributions help make infrastructure management accessible and reliable for developers worldwide.

Please take a few moments to review this guide to understand our engineering conventions and development workflow.

---

## 📜 Table of Contents
- [Code of Conduct](#-code-of-conduct)
- [Development Environment Setup](#-development-environment-setup)
- [Git Workflow & Branching Strategy](#-git-workflow--branching-strategy)
- [Conventional Commits](#-conventional-commits)
- [Engineering Standards & Conventions](#-engineering-standards--conventions)
  - [1. Clean Architecture](#1-clean-architecture)
  - [2. Strict 700-Line Per File Ceiling](#2-strict-700-line-per-file-ceiling)
  - [3. Error Handling & The Result<T> Pattern](#3-error-handling--the-resultt-pattern)
  - [4. Zero Silent Catches Policy](#4-zero-silent-catches-policy)
  - [5. Internationalization (i18n)](#5-internationalization-i18n)
  - [6. Resource Lifecycle & Memory Safety](#6-resource-lifecycle--memory-safety)
- [Testing & Quality Gates](#-testing--quality-gates)
- [Submitting a Pull Request](#-submitting-a-pull-request)
- [Security Vulnerabilities](#-security-vulnerabilities)

---

## 📜 Code of Conduct

All contributors and maintainers are expected to uphold the standards outlined in our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) (Contributor Covenant v2.1). We are dedicated to providing a respectful, welcoming, and harassment-free environment for everyone.

---

## 🛠️ Development Environment Setup

### Prerequisites
Before building Othrys, ensure your local development machine meets the following prerequisites:
- **Flutter SDK**: `3.22.0` or higher ([Official Flutter Installation Guide](https://docs.flutter.dev/get-started/install)).
- **Operating System**:
  - **Windows**: Windows 10/11 with **Visual Studio 2022** (and the *"Desktop development with C++"* workload installed).
  - **macOS / Linux**: Supported for cross-compilation and testing.
- **Git**: Version `2.30+`.

### Step-by-Step Setup
1. **Fork and clone the repository**:
   ```bash
   git clone https://github.com/<your-username>/Othrys.git
   cd Othrys
   ```

2. **Navigate to the application package**:
   ```bash
   cd vpsmanager
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Verify static analysis and run the test suite**:
   ```bash
   flutter analyze
   flutter test
   ```

5. **Launch in desktop debug mode**:
   ```bash
   flutter run -d windows
   ```

---

## 🌿 Git Workflow & Branching Strategy

We follow a structured Git branching model to maintain a pristine history:

1. **Branch off `main`**: Always create a focused feature or bugfix branch:
   - `feat/<feature-name>`: New capabilities or functional enhancements
   - `fix/<bug-description>`: Bug fixes and security patches
   - `refactor/<scope>`: Code refactoring without behavioral alterations
   - `perf/<scope>`: Performance optimizations
   - `docs/<topic>`: Documentation updates
   - `test/<scope>`: New test cases or test infrastructure updates

2. **Keep branches synchronized**: Rebase onto `upstream/main` rather than creating merge commits:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

---

## 💬 Conventional Commits

We strictly adhere to the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification. Commit messages should be lowercase, imperative, and descriptive:

```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

### Allowed Types
- `feat`: A new feature for the user
- `fix`: A bug fix
- `docs`: Documentation changes only
- `style`: Formatting, missing semicolons, etc. (no code logic changes)
- `refactor`: Refactoring production code without changing behavior
- `perf`: Code changes that improve performance or reduce memory footprint
- `test`: Adding missing tests or correcting existing tests
- `chore`: Tooling, build scripts, dependencies update

### Examples
- `feat(docker): add live container memory and cpu sparkline`
- `fix(sftp): prevent duplicate connection on rapid breadcrumb click`
- `refactor(vault): decouple encryption cipher from storage engine`
- `docs(readme): add troubleshooting section for ed25519 keys`

---

## 📐 Engineering Standards & Conventions

Othrys is engineered for **industrial reliability** and long-term maintainability. Every pull request is reviewed against the following rules:

### 1. Clean Architecture
Our codebase strictly isolates responsibilities across three distinct architectural layers:
- **Domain Layer (`lib/domain/`)**: Pure Dart logic. Contains business entities, repository contracts, and domain policies. It has **zero dependencies** on Flutter, UI widgets, or external storage packages.
- **Data & Core Layer (`lib/core/`, `lib/data/`)**: Implements repository interfaces, hardware-level encryption (`cryptography`), SSH/SFTP network clients (`dartssh2`), local storage, and loggers.
- **Presentation Layer (`lib/features/`, `lib/app/`)**: Built with Windows 11 Native Fluent UI widgets (`fluent_ui`) and state management driven by Riverpod (`Notifier` / `StateNotifier`).

### 2. Strict 700-Line Per File Ceiling
- **Rule**: No individual source code file (`.dart`) may exceed **700 physical lines of code**.
- **Enforcement**: This rule is checked in CI/CD on every push and pull request.
- **Rationale**: Keeps components modular, reviewable, testable, and prevents monolithic "god objects". If a component nears 500–600 lines, proactively decompose it into sub-widgets, helper delegates, or dedicated controllers.

### 3. Error Handling & The `Result<T>` Pattern
Operations across storage, network, and system layers must return the sealed `Result<T>` monad:

```dart
// Result<T> is either Success<T> or Failure<T>
final Result<List<DockerContainer>> result = await repository.fetchContainers(serverId);

result.when(
  success: (containers) => state = state.copyWith(containers: containers),
  failure: (error) => _handleError(error),
);
```
Uncaught exceptions and runtime crashes are considered critical defects.

### 4. Zero Silent Catches Policy
- Empty catch blocks (`catch (_) {}`) are **strictly prohibited**.
- All caught exceptions must either be converted into a `Result.failure(error)` or explicitly logged:
  ```dart
  try {
    await client.connect();
  } catch (error, stackTrace) {
    AppLogger.instance.error('SSHService', 'Connection failed', error, stackTrace);
    return Result.failure(ConnectionException(error.toString()));
  }
  ```

### 5. Internationalization (i18n)
Othrys supports native English and French with 100% parity:
- **Zero hardcoded strings**: Every label, button, error message, tooltip, and dialog must use localized string lookups:
  ```dart
  Text(context.l10n.serverConnect)
  ```
- Any new user-facing text must be added to **both**:
  - `lib/core/l10n/arb/app_en.arb` (English)
  - `lib/core/l10n/arb/app_fr.arb` (French)
- Run `flutter gen-l10n` to update generated classes after modifying ARB files.

### 6. Resource Lifecycle & Memory Safety
- Any class managing background polling timers, SSH channels, SFTP streams, or TCP sockets must implement explicit disposal (`dispose()` / `cancel()`).
- Always verify widget lifecycle state before interacting with `BuildContext`:
  ```dart
  final result = await fetchMetrics();
  if (!mounted) return;
  displayNotification(context, ...);
  ```

---

## 🧪 Testing & Quality Gates

Before opening a pull request, execute all local verification steps:

```bash
cd vpsmanager

# 1. Verify static code analysis (0 errors, 0 warnings required)
flutter analyze --fatal-infos --fatal-warnings

# 2. Run automated test suite
flutter test --coverage

# 3. Check line count limit across all Dart files
python -c "
import os, sys
for root, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart') and not f.startswith('app_localizations'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as fp:
                lines = sum(1 for _ in fp)
                if lines > 700:
                    print(f'Error: {path} has {lines} lines (> 700)')
                    sys.exit(1)
print('All files meet the 700-line limit.')
"
```

---

## 🚀 Submitting a Pull Request

1. Push your branch to your GitHub fork:
   ```bash
   git push origin feat/your-feature-name
   ```
2. Open a Pull Request against `Othrys:main`.
3. Complete the [Pull Request Template](.github/pull_request_template.md).
4. Verify that all CI checks (linting, tests, line length verification) pass cleanly.
5. Address code review feedback with polite, constructive discussion.

---

## 🛡️ Security Vulnerabilities

Please **do not** open public GitHub issues for security vulnerabilities. Review our [SECURITY.md](SECURITY.md) policy for instructions on submitting private security disclosures.
