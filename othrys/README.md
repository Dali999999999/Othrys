# Othrys (Desktop Client)

This directory contains the primary Flutter and Dart client implementation for **Othrys**, an industrial-grade desktop suite for Linux infrastructure and VPS management.

For overall architectural documentation, product vision, security guarantees, and community standards, please refer to the project's root [README.md](../README.md).

---

## 🏗️ Package Structure

```
othrys/
├── lib/
│   ├── app/           # App root, Fluent theme tokens, window chrome, and routing
│   ├── core/          # Encryption vault, SSH/SFTP services, local storage, i18n
│   ├── domain/        # Pure domain entities, repository contracts, Result<T> monad
│   ├── features/      # Feature modules (terminal, docker, systemd, sftp, tunnels, settings)
│   └── shared/        # Reusable Fluent UI widgets, cards, badges, and brand assets
├── test/              # Unit, widget, and repository test suites (110+ tests)
├── windows/           # Windows 11 C++ desktop runner and native window integration
└── pubspec.yaml       # Dependencies, assets, and Flutter configuration
```

---

## 🛠️ Local Developer Commands

All commands should be executed from within this directory (`othrys/`):

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Code Generation (i18n)
```bash
flutter gen-l10n
```

### 3. Static Analysis
Verify that zero warnings and zero linter hints are reported:
```bash
flutter analyze --fatal-infos --fatal-warnings
```

### 4. Automated Tests
Run the complete unit and widget test suite:
```bash
flutter test
```

### 5. Run Application (Windows)
```bash
flutter run -d windows
```

### 6. Build Production Release Bundle
```bash
flutter build windows --release
```
The output binary will be located in:
`build/windows/x64/runner/Release/`
