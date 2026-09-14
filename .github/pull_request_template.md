## 📝 Description
Provide a clear and concise summary of the changes introduced in this pull request and their engineering rationale.

Fixes #(issue)

---

## 🏷️ Type of Change
- [ ] 🐛 Bug fix (non-breaking change resolving an issue)
- [ ] ✨ New feature (non-breaking change adding functionality)
- [ ] ♻️ Architecture refactor or performance optimization
- [ ] 🔒 Security patch or vulnerability fix
- [ ] 🌐 Internationalization / localization update
- [ ] 📚 Documentation enhancement

---

## 📐 Engineering & Quality Checklist
Please ensure your contribution strictly complies with the Othrys engineering standards before submitting:

- [ ] **700-Line Ceiling Rule**: No modified or newly added Dart file exceeds **700 lines of code**.
- [ ] **Clean Architecture Compliance**: Proper separation of concerns maintained across Presentation, Domain, and Data/Core layers.
- [ ] **Zero Silent Catches**: Swallowing exceptions (`catch (_) {}`) is strictly prohibited; all caught exceptions are explicitly logged via `AppLogger` and returned via `Result<T>` (`Success` / `Failure`).
- [ ] **i18n Parity**: Zero hardcoded user-facing strings; all UI text is localized in both `lib/core/l10n/arb/app_en.arb` and `lib/core/l10n/arb/app_fr.arb`.
- [ ] **Asynchronous Safety**: State updates or context accesses after `await` calls are properly guarded with `if (!mounted) return;`.
- [ ] **Testing**: Added or updated unit/widget tests in `test/` for new logic or regression prevention.
- [ ] **Static Code Analysis**: `flutter analyze` passes with **0 errors and 0 warnings**.
- [ ] **Automated Test Suite**: `flutter test` executes with **100% passing tests**.

---

## 📸 Visual Verification (If Applicable)
For user interface changes, attach screenshots or short screen captures demonstrating the new or updated UI in both Light and Dark themes.
