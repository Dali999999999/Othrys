# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.0] - 2026-09-12

### Initial Industrial-Grade Release (Release Gate MVP)

#### Added
- **Security Architecture**:
  - Hardware-backed AES-256-GCM encrypted persistence vault with PBKDF2 (100,000 rounds) key derivation.
  - Strict host key validation with Trust On First Use (TOFU) and MITM attack detection (`HostKeyStore`).
  - Command argument injection sanitizer (`CommandSanitizer`).
  - Elimination of all silent catches across the entire codebase with structured `AppLogger` recording.
- **Clean Architecture & Refactoring**:
  - Full domain separation: Entities, Repositories, Use Cases, and Presentation controllers.
  - Functional error handling via the sealed `Result<T>` monad (`Success` / `Failure`).
  - 100% adherence to the 700-line per file ceiling across all source code.
- **Multi-Session Terminal**:
  - Interactive multi-tab PTY terminal powered by `xterm.dart` and `dartssh2`.
  - Dynamic PTY window resize debouncing with `LayoutBuilder`.
  - Copy/paste shortcuts, buffer clear, and tab lifecycle management.
- **Docker & Compose Manager**:
  - Real-time container inventory, status badges, and port mappings.
  - Streaming live container logs with pause/resume and autoscroll.
  - Container lifecycle operations with confirmation guards.
  - Automatic detection of Docker Compose files and directories.
- **Systemd Service Manager**:
  - System service discovery, filtering, and state visualization.
  - Boot enablement toggling (`systemctl enable/disable`).
  - Protected operations with double-confirmation dialog for critical infrastructure units.
  - Remote `journalctl` error log viewer with one-click clipboard copy.
- **Interactive SFTP File Explorer**:
  - Clickable dual-mode breadcrumb navigation bar and directory path editor.
  - Remote file download and upload with a 100 MB safety guard rail.
  - Remote file and directory renaming.
- **SSH Port Forwarding & Tunnels**:
  - Local, Remote, and Dynamic (SOCKS5) port forwarding.
  - Live bi-directional background socket piping with bandwidth/byte counters.
  - Background reconnection watchdog and graceful socket teardown.
- **Real-Time System Monitoring**:
  - Live CPU load, RAM usage, and disk space gauges.
  - 60-second real-time historical CPU sparkline chart.
  - Configurable polling interval (3 to 30 seconds).
- **Command Palette & Keyboard Control**:
  - Global Command Palette (`Ctrl+P` / `Cmd+P`) with fuzzy filtering.
  - Full keyboard navigation (Up, Down, Enter, Esc) for instant server navigation and actions.
- **Internationalization (i18n)**:
  - 100% bilingual parity in French (`fr`) and English (`en`).
  - Runtime language switcher with immediate UI re-rendering.
- **Onboarding & Settings**:
  - First-launch welcome experience with guided server setup.
  - Settings manager with theme switcher (Dark, Light, System), terminal font size slider, and backup export/import.
- **Automated Testing Suite**:
  - 110+ automated unit, widget, and repository tests with 100% pass rate.
  - CI/CD workflow automation for continuous testing and Windows binary release packaging.
