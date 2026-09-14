# Othrys — Protocole d'Exécution du Design System v2.0

> **Réf.** : DESIGN-SYSTEM.md v2.0 (aligné logo)  
> **Objectif** : Implémenter le Design System brand-aligned dans le code Flutter existant  
> **Approche** : Bottom-up (fondations -> atomiques -> moléculaires -> theme -> vues -> polish)  
> **Dernière mise à jour** : 2026-09-13

---

## Table des matières

- [Phase 0 — Préparation & Assets](#phase-0--préparation--assets)
- [Phase 1 — Fondation : Tokens & Helpers](#phase-1--fondation--tokens--helpers)
- [Phase 2 — Composants atomiques](#phase-2--composants-atomiques)
- [Phase 3 — Composants moléculaires](#phase-3--composants-moléculaires)
- [Phase 4 — Refonte du Theme Engine](#phase-4--refonte-du-theme-engine)
- [Phase 5 — Migration des vues](#phase-5--migration-des-vues)
- [Phase 6 — Polissage & Animation](#phase-6--polissage--animation)
- [Phase 7 — Vérification & QA](#phase-7--vérification--qa)

---

## Phase 0 — Préparation & Assets

### P0-T01 · Installer la police JetBrains Mono

**Fichier** : `pubspec.yaml` + `assets/fonts/`

1. Télécharger JetBrains Mono depuis https://www.jetbrains.com/lp/mono/ (Regular, Medium, Bold)
2. Placer les fichiers `.ttf` dans `vpsmanager/assets/fonts/`
3. Déclarer dans `pubspec.yaml` :
   ```yaml
   flutter:
     fonts:
       - family: JetBrainsMono
         fonts:
           - asset: assets/fonts/JetBrainsMono-Regular.ttf
           - asset: assets/fonts/JetBrainsMono-Medium.ttf
             weight: 500
           - asset: assets/fonts/JetBrainsMono-Bold.ttf
             weight: 700
   ```

### P0-T02 · Déclarer le logo dans les assets

**Fichier** : `pubspec.yaml`

Le logo est déjà copié dans `vpsmanager/assets/images/logo.png`.

Ajouter dans la section `flutter:` :
```yaml
flutter:
  assets:
    - assets/images/logo.png
```

### P0-T03 · Créer l'arborescence Design System

```
lib/app/theme/
├── app_theme.dart           (EXISTANT — refactorisé en Phase 4)
├── app_colors.dart          (NOUVEAU — Phase 1)
├── app_typography.dart      (NOUVEAU — Phase 1)
├── app_spacing.dart         (NOUVEAU — Phase 1)
├── app_radius.dart          (NOUVEAU — Phase 1)
├── app_icons.dart           (NOUVEAU — Phase 1)
└── app_dialog_sizes.dart    (NOUVEAU — Phase 1)

lib/shared/widgets/
├── (existants conservés)
├── app_status_dot.dart      (NOUVEAU — Phase 2)
├── app_badge.dart           (NOUVEAU — Phase 2)
├── app_shortcut_badge.dart  (NOUVEAU — Phase 2)
├── app_brand_mark.dart      (NOUVEAU — Phase 2)
├── app_card.dart            (NOUVEAU — Phase 3)
├── app_console_box.dart     (NOUVEAU — Phase 3)
├── app_metric_card.dart     (NOUVEAU — Phase 3)
├── app_empty_state.dart     (NOUVEAU — Phase 3)
└── app_section_card.dart    (NOUVEAU — Phase 3)
```

---

## Phase 1 — Fondation : Tokens & Helpers

### P1-T01 · `app_colors.dart` — Palette centralisée brand-aligned

**Fichier** : `lib/app/theme/app_colors.dart`  
**Statut** : NOUVEAU

```dart
import 'package:fluent_ui/fluent_ui.dart';

class AppColors {
  AppColors._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Brand Colors (extraites du logo Cyan→Blue→Violet)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Pôle lumineux du gradient logo. Données live, liens, ports.
  static const Color brandCyan = Color(0xFF00D4FF);

  /// Cœur du logo. Accent principal de l'app. Boutons, navigation.
  static const Color brandBlue = Color(0xFF2979FF);

  /// Pôle profond du gradient logo. Accent secondaire, métriques stockage.
  static const Color brandViolet = Color(0xFF7C4DFF);

  /// Ombre des intersections du logo. Overlays très profonds.
  static const Color brandNavy = Color(0xFF151038);

  /// Accent principal Fluent UI (AccentColor)
  static final AccentColor primaryAccent = AccentColor.swatch({
    'darkest': const Color(0xFF1565C0),
    'darker': const Color(0xFF1E88E5),
    'dark': const Color(0xFF2196F3),
    'normal': brandBlue,
    'light': const Color(0xFF42A5F5),
    'lighter': const Color(0xFF64B5F6),
    'lightest': const Color(0xFF90CAF9),
  });

  /// Gradient de marque (usage limité : logo rendu, onboarding, premium touches)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandCyan, brandBlue, brandViolet],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Semantic Colors
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFF9100);
  static const Color danger = Color(0xFFFF5252);
  static const Color blueLink = Color(0xFF58A6FF);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Console (toujours dark, même en thème light)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const Color consoleBackground = Color(0xFF0B0E18);
  static const Color consoleText = Color(0xFFC5CDDF);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Theme-aware Surfaces (Indigo-tinted)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Color surfaceBase(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0B0E18) : const Color(0xFFF5F7FB);

  static Color surfaceCard(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111628) : const Color(0xFFFFFFFF);

  static Color surfaceElevated(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1A2035) : const Color(0xFFE8ECF4);

  static Color surfaceBorder(BuildContext context) =>
      _isDark(context) ? const Color(0xFF2A3148) : const Color(0xFFCDD5E0);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Theme-aware Text Hierarchy (Cold/Indigo-tinted greys)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFF0F4FC) : const Color(0xFF1A1E2E);

  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFC5CDDF) : const Color(0xFF242838);

  static Color textMuted(BuildContext context) =>
      _isDark(context) ? const Color(0xFF8490A8) : const Color(0xFF556178);

  static Color textFaint(BuildContext context) =>
      _isDark(context) ? const Color(0xFF5C6880) : const Color(0xFF6B7A92);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Opacity Helpers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Color badgeBackground(Color semantic) => semantic.withOpacity(0.12);
  static Color badgeBorder(Color semantic) => semantic.withOpacity(0.35);
  static Color selectionBackground(Color semantic) => semantic.withOpacity(0.12);
  static Color activeBorder(Color semantic) => semantic.withOpacity(0.40);
  static Color gradientTint(Color semantic) => semantic.withOpacity(0.08);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Internal
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static bool _isDark(BuildContext context) =>
      FluentTheme.of(context).brightness == Brightness.dark;
}
```

**Points clés v2.0** :
- `brandBlue` remplace `Colors.teal` comme accent principal
- `brandCyan` remplace l'ancien `#00E5FF` (léger décalage vers `#00D4FF` pour matcher le logo)
- `brandViolet` promu de couleur anecdotique à couleur de marque
- Toutes les surfaces ont un sous-ton indigo (plus de gris neutre)
- Tous les textes ont un sous-ton froid (cohérence avec surfaces)
- `primaryAccent` est un `AccentColor.swatch` complet basé sur `brandBlue`

---

### P1-T02 · `app_typography.dart` — Échelle typographique

**Fichier** : `lib/app/theme/app_typography.dart`  
**Statut** : NOUVEAU

```dart
import 'package:fluent_ui/fluent_ui.dart';
import 'app_colors.dart';

class AppTypo {
  AppTypo._();

  static const String fontMono = 'JetBrainsMono';
  static const String fontMonoFallback = 'Consolas';

  static TextStyle displayLarge(BuildContext context) => TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary(context), letterSpacing: -0.5,
  );

  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary(context),
  );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary(context),
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary(context),
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.textMuted(context),
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textFaint(context),
  );

  static TextStyle micro(BuildContext context) => TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textMuted(context),
  );

  static TextStyle nano(BuildContext context) => TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: AppColors.textFaint(context),
  );

  // ━━ Monospace Variants ━━

  static TextStyle code(BuildContext context) => const TextStyle(
    fontFamily: fontMono,
    fontFamilyFallback: [fontMonoFallback, 'monospace'],
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.consoleText,
  );

  static TextStyle codeMuted(BuildContext context) => TextStyle(
    fontFamily: fontMono,
    fontFamilyFallback: const [fontMonoFallback, 'monospace'],
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textMuted(context),
  );

  static TextStyle codeAccent(BuildContext context) => const TextStyle(
    fontFamily: fontMono,
    fontFamilyFallback: [fontMonoFallback, 'monospace'],
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.brandCyan,
  );
}
```

---

### P1-T03 · `app_spacing.dart`

**Fichier** : `lib/app/theme/app_spacing.dart` — NOUVEAU

```dart
import 'package:fluent_ui/fluent_ui.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const EdgeInsets pageContent =
      EdgeInsets.symmetric(horizontal: xxl, vertical: sm);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets badgePadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 2);
  static const EdgeInsets consolePadding = EdgeInsets.all(md);
}
```

---

### P1-T04 · `app_radius.dart`

**Fichier** : `lib/app/theme/app_radius.dart` — NOUVEAU

```dart
import 'package:fluent_ui/fluent_ui.dart';

class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double md = 8.0;
  static const double pill = 999.0;

  static final BorderRadius borderSm = BorderRadius.circular(sm);
  static final BorderRadius borderMd = BorderRadius.circular(md);
  static final BorderRadius borderPill = BorderRadius.circular(pill);
}
```

---

### P1-T05 · `app_icons.dart`

**Fichier** : `lib/app/theme/app_icons.dart` — NOUVEAU

```dart
class AppIconSize {
  AppIconSize._();

  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 32.0;
  static const double hero = 48.0;
}
```

---

### P1-T06 · `app_dialog_sizes.dart`

**Fichier** : `lib/app/theme/app_dialog_sizes.dart` — NOUVEAU

```dart
class AppDialogSize {
  AppDialogSize._();

  static const double compactWidth = 460.0;
  static const double standardWidth = 520.0;
  static const double wideWidth = 740.0;
  static const double wideHeight = 480.0;
}
```

---

## Phase 2 — Composants atomiques

### P2-T01 · `AppStatusDot`

**Fichier** : `lib/shared/widgets/app_status_dot.dart` — NOUVEAU

- Enum `StatusDotVariant { success, warning, danger, inactive, info }`
- Taille fixe 8x8, `BoxShape.circle`
- Prop `bool pulsing` (default false) — animation opacité 0.4→1.0, 1500ms, loop
- Couleurs :
  - `success` → `AppColors.success`
  - `warning` → `AppColors.warning`
  - `danger` → `AppColors.danger`
  - `inactive` → `AppColors.textFaint(context)`
  - `info` → `AppColors.brandCyan`

---

### P2-T02 · `AppBadge`

**Fichier** : `lib/shared/widgets/app_badge.dart` — NOUVEAU

- Enum `AppBadgeVariant { success, warning, danger, info, accent, neutral }`
- Padding `AppSpacing.badgePadding`, radius `AppRadius.borderSm`
- Fond : `badgeBackground(semanticColor)` / `surfaceElevated` pour neutral
- Bordure : `badgeBorder(semanticColor)` / aucune pour neutral
- Texte : `AppTypo.nano` + couleur sémantique
- Mapping v2.0 :
  - `info` → `AppColors.brandCyan`
  - `accent` → `AppColors.brandBlue` (NOUVEAU : pour les badges d'action brand)
  - `neutral` → `AppColors.surfaceElevated(context)`

---

### P2-T03 · `AppShortcutBadge`

**Fichier** : `lib/shared/widgets/app_shortcut_badge.dart` — NOUVEAU

- Fond `surfaceElevated`, radius `AppRadius.borderSm`
- Texte `AppTypo.nano` + `AppColors.blueLink`

---

### P2-T04 · `AppBrandMark` — NOUVEAU (v2.0)

**Fichier** : `lib/shared/widgets/app_brand_mark.dart` — NOUVEAU

Widget pour afficher le logo de manière normalisée :

```dart
class AppBrandMark extends StatelessWidget {
  final double size;
  const AppBrandMark({super.key, this.size = 18});

  const AppBrandMark.titlebar({super.key}) : size = 18;
  const AppBrandMark.hero({super.key}) : size = 64;
  const AppBrandMark.about({super.key}) : size = 48;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
    );
  }
}
```

---

## Phase 3 — Composants moléculaires

### P3-T01 · `AppCard`

**Fichier** : `lib/shared/widgets/app_card.dart` — NOUVEAU

- Fond : `AppColors.surfaceCard(context)`
- Border : `isActive` ? `AppColors.activeBorder(AppColors.brandBlue)` : `AppColors.surfaceBorder(context)`
- Radius : `AppRadius.borderMd`
- **Changement v2.0** : L'active border utilise `brandBlue` au lieu de cyan

---

### P3-T02 · `AppConsoleBox`

**Fichier** : `lib/shared/widgets/app_console_box.dart` — NOUVEAU

- Fond : `AppColors.consoleBackground` (toujours `#0B0E18`)
- Border : `AppColors.surfaceBorder(context)`
- Radius : `AppRadius.borderMd`
- Font : `AppTypo.code(context)` (JetBrains Mono, couleur `#C5CDDF`)

---

### P3-T03 · `AppMetricCard`

**Fichier** : `lib/shared/widgets/app_metric_card.dart` — NOUVEAU

- Container `AppCard`
- **Changement v2.0** : Disk normal color = `AppColors.brandViolet` (brand aligned, remplace `Colors.purple`)

---

### P3-T04 · `AppEmptyState`

**Fichier** : `lib/shared/widgets/app_empty_state.dart` — NOUVEAU

Identique v1.0, pas de changement.

---

### P3-T05 · `AppSectionCard`

**Fichier** : `lib/shared/widgets/app_section_card.dart` — NOUVEAU

Remplace `SettingsSectionCard`. Identique v1.0, pas de changement.

---

## Phase 4 — Refonte du Theme Engine

### P4-T01 · Refactoriser `app_theme.dart`

**Fichier** : `lib/app/theme/app_theme.dart` — MODIFIER

**Changements v2.0 :**

1. Supprimer toutes les constantes de couleur (migrées vers `AppColors`)
2. **Remplacer `Colors.teal`** par `AppColors.primaryAccent` dans les deux factories
3. Mettre à jour `scaffoldBackgroundColor` :
   - Dark : `Color(0xFF0B0E18)` (était `0xFF0D1117`)
   - Light : `Color(0xFFF5F7FB)` (était `0xFFF6F8FA`)
4. Mettre à jour `cardColor` :
   - Dark : `Color(0xFF111628)` (était `0xFF161B22`)
5. Mettre à jour `menuColor` :
   - Dark : `Color(0xFF1A2035)` (était `0xFF21262D`)
6. Exporter tous les fichiers tokens :
   ```dart
   export 'app_colors.dart';
   export 'app_typography.dart';
   export 'app_spacing.dart';
   export 'app_radius.dart';
   export 'app_icons.dart';
   export 'app_dialog_sizes.dart';
   ```

---

### P4-T02 · Fixer le container root dans `app.dart`

**Fichier** : `lib/app/app.dart` — MODIFIER

```dart
// AVANT :
Container(color: AppTheme.background, ...)

// APRÈS :
Container(color: AppColors.surfaceBase(context), ...)
```

---

### P4-T03 · Fixer Caption Buttons brightness

**Fichier** : `lib/app/window/window_titlebar.dart` — MODIFIER

Remplacer les 3 `brightness: Brightness.dark` par :
```dart
brightness: FluentTheme.of(context).brightness
```

---

### P4-T04 · Terminal theme (console reste dark)

**Fichier** : `lib/features/terminal/widgets/terminal_theme_data.dart` — MODIFIER

Mettre à jour les couleurs du terminal pour utiliser les nouvelles valeurs indigo-teintées :
- Background : `0xFF0B0E18` (était `0xFF0D1117`)
- Foreground : `0xFFF0F4FC` (était `0xFFE6EDF3`)
- Cursor/Blue : inchangé `0xFF58A6FF`

---

## Phase 5 — Migration des vues

> **Règle** : Chaque fichier modifié élimine TOUTES les couleurs hardcodées, TOUS les `BorderRadius` non conformes, TOUTES les incohérences. Les remplacements suivent les nouvelles valeurs brand-aligned v2.0.

### P5-T01 · Migrer `window_titlebar.dart` — BRAND IDENTITY

**Fichier** : `lib/app/window/window_titlebar.dart`

C'est la migration la plus importante car la titlebar porte désormais l'identité de marque.

| Remplacement | Avant | Après |
|-------------|-------|-------|
| **Logo** (le plus important) | `Icon(FluentIcons.server, size: 16, color: AppTheme.accentCyan)` | `const AppBrandMark.titlebar()` (18x18 logo image) |
| Fond | `AppTheme.background` | `AppColors.surfaceBase(context)` |
| Titre style | `Color(0xFFE6EDF3)` | `AppTypo.caption(context).copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))` |
| Badge connexion dot | `Container(width: 6, height: 6)` | `AppStatusDot(variant: success)` (8x8) |
| Badge compteur | Construction manuelle | Tokens `AppTypo.nano` + `AppColors.success` |
| Badge fond | `AppTheme.successGreen.withValues(alpha: 0.15)` | `AppColors.badgeBackground(AppColors.success)` |
| Search button fond | `AppTheme.cardBackground` | `AppColors.surfaceCard(context)` |
| Search texte | `Color(0xFF8B949E)` | `AppColors.textMuted(context)` |
| Shortcut Ctrl+K | Manuel `Color(0xFF58A6FF)` | `AppShortcutBadge(shortcut: 'Ctrl+K')` |
| Caption brightness | `Brightness.dark` | `FluentTheme.of(context).brightness` |

---

### P5-T02 · Migrer `servers_view.dart`

| Remplacement | Avant | Après |
|-------------|-------|-------|
| Card container | `Card(backgroundColor: AppTheme.cardBackground)` | `AppCard(isActive: isConnected)` |
| Active border | `accentCyan @ 50%` | `AppColors.activeBorder(AppColors.brandBlue)` (40%) |
| Status dot | Inline 8x8 `Color(0xFF484F58)` | `AppStatusDot(variant: ...)` |
| Icon container radius | `circular(6)` | `AppRadius.borderSm` (4px) |
| Server name | `Colors.white` | `AppColors.textPrimary(context)` |
| Endpoint | `Color(0xFF8B949E), 'Consolas'` | `AppTypo.codeMuted(context)` |
| Group badge | Manuel | `AppBadge(label: group, variant: info)` — uses `brandCyan` |
| Connected icon bg | `successGreen.withValues(alpha: 0.15)` | `AppColors.badgeBackground(AppColors.success)` |
| Server icon actif | `AppTheme.accentCyan` | `AppColors.brandBlue` |
| Delete icon | `AppTheme.errorRed` | `AppColors.danger` |
| Empty state | Manuel | `AppEmptyState(...)` |

---

### P5-T03 · Migrer `monitoring_view.dart`

| Remplacement | Avant | Après |
|-------------|-------|-------|
| Metric cards | `_buildMetricCard` | `AppMetricCard` widget |
| CPU trend card | `Card(bg: cardBackground)` | `AppCard()` |
| Trend title | `Colors.white` | `AppColors.textPrimary(context)` |
| Uptime badge | Manuel | `AppBadge(label: uptime, variant: neutral)` |
| **Disk color** | `Colors.purple` | `AppColors.brandViolet` |
| CPU default color | `AppTheme.accentCyan` | `AppColors.brandCyan` |
| Chart grid | `AppTheme.border` | `AppColors.surfaceBorder(context)` |
| Chart fill | `accentCyan @ 15%` | `AppColors.selectionBackground(AppColors.brandCyan)` |

---

### P5-T04 · Migrer Docker (5 fichiers)

**Fichiers** : `docker_view.dart`, `docker_logs_dialog.dart`, `docker_container_tile.dart`, `docker_not_installed_view.dart`, `docker_compose_tab.dart`

| Remplacement | Avant | Après |
|-------------|-------|-------|
| Tab bg selected | `AppTheme.cardBackground` | `AppColors.surfaceCard(context)` |
| Tab text inactive | `Color(0xFF8B949E)` | `AppColors.textMuted(context)` |
| Tab text active | `Colors.white` | `AppColors.textPrimary(context)` |
| Count badge active bg | `accentCyan @ 20%` | `AppColors.badgeBackground(AppColors.brandCyan)` |
| Count badge active text | `AppTheme.accentCyan` | `AppColors.brandCyan` |
| Count badge radius | `circular(10)` | `AppRadius.borderPill` |
| Count badge inactive bg | `Color(0xFF21262D)` | `AppColors.surfaceElevated(context)` |
| Docker dot | Inline 8x8 | `AppStatusDot(variant: ...)` |
| Button `fontSize: 11` | Hardcodé | Supprimer (default Fluent) |
| Delete icon size 12 | Incohérent | `AppIconSize.md` (14) |
| Logs console | Manuel `Container(Color(0xFF0D1117))` | `AppConsoleBox(content: logs)` |
| Compose output | Manuel | `AppConsoleBox(content: output)` |
| Not installed card | Manuel Container | `AppCard()` + `AppEmptyState` + `AppConsoleBox` |
| Warning icon | `AppTheme.warningOrange` | `AppColors.warning` |

---

### P5-T05 · Migrer `services_view.dart`

| Remplacement | Avant | Après |
|-------------|-------|-------|
| Status dot | Inline 8x8 | `AppStatusDot(variant: ...)` |
| Enabled badge | Manuel Container | `AppBadge(variant: success, icon: FluentIcons.check_mark)` |
| Disabled badge | Manuel `Color(0xFF21262D)` | `AppBadge(variant: neutral, icon: FluentIcons.power_button)` |
| Unit name font | `'Consolas'` | `AppTypo.fontMono` |
| Subtitle | `Color(0xFF8B949E)` | `AppTypo.micro(context)` |
| Button `fontSize: 11` | Hardcodé | Supprimer |
| Journal console | `Container(Color(0xFF0D1117))` | `AppConsoleBox(content: logs)` |
| Stop bg | `AppTheme.errorRed` | `AppColors.danger` |
| Start bg | `AppTheme.successGreen` | `AppColors.success` |
| Emoji `⚠️` | String prefix | Icône `FluentIcons.warning` |

---

### P5-T06 · Migrer `tunnels_view.dart`

| Remplacement | Avant | Après |
|-------------|-------|-------|
| Card | `Card(bg: cardBackground)` | `AppCard()` |
| Status dot **10x10** | `Container(width:10)` | `AppStatusDot(variant: ...)` (8x8) |
| Inactive dot | `Color(0xFF6E7681)` | `StatusDotVariant.inactive` |
| Tunnel name | `Colors.white` | `AppColors.textPrimary(context)` |
| Type badge | Manuel radius 4 | `AppBadge(variant: info)` — uses `brandCyan` |
| Port mapping | `accentCyan, 'Consolas'` | `AppTypo.codeAccent(context)` — uses `brandCyan` |
| Delete icon | `AppTheme.errorRed` | `AppColors.danger` |

---

### P5-T07 · Migrer File Manager (4 fichiers)

| Remplacement | Avant | Après |
|-------------|-------|-------|
| Empty text | `Color(0xFF8B949E)` | `AppTypo.bodySmall(context)` |
| Breadcrumb bg | `AppTheme.elevatedBackground` | `AppColors.surfaceElevated(context)` |
| Separator `/` | `Color(0xFF6E7681)` | `AppColors.textFaint(context)` |
| Folder icon | `AppTheme.accentCyan` | `AppColors.brandCyan` |
| File icon | `Color(0xFF8B949E)` | `AppColors.textMuted(context)` |
| Action icons size | 12 | `AppIconSize.md` (14) |
| Subtitle | `Color(0xFF6E7681)` | `AppColors.textFaint(context)` |
| Editor dialog width | Absent | `AppDialogSize.wideWidth` |

---

### P5-T08 · Migrer `activity_feed_view.dart`

| Remplacement | Avant | Après |
|-------------|-------|-------|
| Status dot | Inline 8x8 | `AppStatusDot(variant: ...)` |
| Category badge | Manuel | `AppBadge(variant: ...)` |
| `_getLevelColor` info | `AppTheme.accentCyan` | `AppColors.brandCyan` |
| Message | `Colors.white` | `AppColors.textPrimary(context)` |
| Timestamp | `Color(0xFF6E7681)` | `AppColors.textFaint(context)` |
| Empty text | `Color(0xFF8B949E)` | `AppTypo.bodySmall(context)` |

---

### P5-T09 · Migrer `command_palette_modal.dart`

| Remplacement | Avant | Après |
|-------------|-------|-------|
| Dialog width | 560 | `AppDialogSize.standardWidth` (520) |
| Esc badge | Manuel | `AppShortcutBadge(shortcut: ...)` |
| Selection bg | `accentCyan @ 15%` | `AppColors.selectionBackground(AppColors.brandBlue)` |
| Selection border | `accentCyan @ 40%` | `AppColors.activeBorder(AppColors.brandBlue)` |
| Section header | `Color(0xFF6E7681)` | `AppColors.textFaint(context)` |
| Item title | `Colors.white` | `AppColors.textPrimary(context)` |
| Item subtitle | `Color(0xFF8B949E)` | `AppColors.textMuted(context)` |
| Server icon color | `AppTheme.accentCyan` | `AppColors.brandCyan` |
| Disconnect icon | `AppTheme.errorRed` | `AppColors.danger` |
| Container radius | `circular(4)` | `AppRadius.borderSm` |

**Changement v2.0** : La sélection dans la palette de commandes utilise `brandBlue` au lieu de `accentCyan`. C'est l'accent primaire.

---

### P5-T10 · Migrer `welcome_view.dart` — BRAND IDENTITY

**Fichier** : `lib/features/onboarding/welcome_view.dart`

C'est la page de première impression. Le logo doit briller.

| Remplacement | Avant | Après |
|-------------|-------|-------|
| **Hero avatar** | `Container(circle) + Icon(FluentIcons.server, 32)` | `const AppBrandMark.hero()` (logo 64x64) |
| Avatar fond circle | `accentCyan @ 15% + border 30%` | **Supprimer** le cercle de fond. Le logo a déjà son propre fond transparent. |
| Fond container | `AppTheme.background` | `AppColors.surfaceBase(context)` |
| Card bg | `AppTheme.cardBackground` | `AppColors.surfaceCard(context)` |
| Card border | `AppTheme.border` | `AppColors.surfaceBorder(context)` |
| Card radius | `circular(12)` | `AppRadius.borderMd` (8px) |
| Titre | `Colors.white` | `AppTypo.titleLarge(context)` |
| Subtitle | `Color(0xFF8B949E)` | `AppTypo.bodySmall(context)` |
| Badge icons | `Color(0xFFC9D1D9)` | `AppColors.textSecondary(context)` |
| Badge text | `Color(0xFF8B949E)` | `AppTypo.micro(context)` |

---

### P5-T11 · Migrer Settings (3 fichiers)

| Remplacement | Avant | Après |
|-------------|-------|-------|
| `SettingsSectionCard` | Ancien widget | `AppSectionCard` (P3-T05) |
| About titre | `Colors.white` | `AppColors.textPrimary(context)` |
| About texte | `Color(0xFF8B949E)` | `AppTypo.caption(context)` |
| **About logo** | Absent | Ajouter `AppBrandMark.about()` (48x48) à côté du nom et version |
| About lien | `AppTheme.accentCyan` | `AppColors.brandCyan` |
| Preview font | `'Consolas'` | `AppTypo.fontMono` |
| Preview color | `Color(0xFF8B949E)` | `AppColors.textMuted(context)` |

---

### P5-T12 · Migrer `terminal_tab_view.dart`

| Avant | Après |
|-------|-------|
| `Color(0xFF0D1117)` | `AppColors.consoleBackground` |

---

### P5-T13 · Migrer `terminal_theme_data.dart`

| Avant | Après |
|-------|-------|
| Background `0xFF0D1117` | `0xFF0B0E18` (nouvelle surface.base dark) |
| Foreground `0xFFE6EDF3` | `0xFFF0F4FC` (nouveau text.primary dark) |
| Cursor `0xFF58A6FF` | Inchangé |

---

### P5-T14 · Migrer `terminal_context_menu.dart`

| Avant | Après |
|-------|-------|
| `Color(0xFF8B949E)` | `AppColors.textMuted(context)` |
| `TextStyle(fontSize: 11)` | `AppTypo.micro(context)` |

---

### P5-T15 · Migrer shared widgets

| Widget | Changement |
|--------|-----------|
| `connection_guard.dart` | Icon color → `AppColors.surfaceBorder(context)`, text → `AppColors.textMuted(context)` |
| `loading_overlay.dart` | Backdrop → `Colors.black.withOpacity(0.50)`, message → `AppColors.textPrimary(context)` |
| `confirm_dialog.dart` | Danger bg → `AppColors.danger` |

---

### P5-T16 · Migrer `server_dialog.dart` + widgets

| Avant | Après |
|-------|-------|
| Dialog width `480` | `AppDialogSize.standardWidth` |
| `Colors.red` | `AppColors.danger` |
| Validation `fontSize: 11` | `AppTypo.micro(context).copyWith(color: AppColors.danger)` |
| Server icon color `FluentIcons.server` | Keep icon but color → `AppColors.brandBlue` |

---

### P5-T17 · Migrer `tunnel_dialog.dart`

| Avant | Après |
|-------|-------|
| Dialog width `440` | `AppDialogSize.compactWidth` |

---

### P5-T18 · Migrer `app.dart` — TabErrorBoundary + root

| Avant | Après |
|-------|-------|
| `AppTheme.errorRed` | `AppColors.danger` |
| `Colors.white` | `AppColors.textPrimary(context)` |
| `Color(0xFF8B949E)` | `AppColors.textMuted(context)` |
| `AppTheme.background` root | `AppColors.surfaceBase(context)` |

---

## Phase 6 — Polissage & Animation

### P6-T01 · Pulse animation `AppStatusDot`

Implémentation `AnimationController` 1500ms `easeInOut` loop, opacité 0.4→1.0.

### P6-T02 · Hover effect `AppCard`

`MouseRegion` + `AnimatedContainer` : luminosité fond +5%, transition 150ms `easeOut`.

### P6-T03 · Smooth transitions métriques

`ProgressBar` values animées, `AnimatedDefaultTextStyle` pour les valeurs numériques.

---

## Phase 7 — Vérification & QA

### P7-T01 · Audit couleurs hardcodées

```bash
grep -rn "Color(0xFF" lib/features/ lib/shared/ lib/app/
grep -rn "Colors.white\|Colors.red\|Colors.purple\|Colors.teal" lib/features/ lib/shared/ lib/app/
```
Résultat attendu : ZÉRO occurrence (sauf `app_colors.dart`, `app_theme.dart`, `terminal_theme_data.dart`).

### P7-T02 · Audit border radius

```bash
grep -rn "BorderRadius.circular" lib/features/ lib/shared/ lib/app/
```
Résultat attendu : Aucune occurrence hors des fichiers tokens.

### P7-T03 · Audit TextStyle hardcodées

```bash
grep -rn "TextStyle(" lib/features/ lib/shared/
```
Résultat attendu : Uniquement des `.copyWith()` sur `AppTypo.*`.

### P7-T04 · Audit logo & brand colors

Vérifier que :
- Le logo 18x18 s'affiche dans la titlebar
- Le logo 64x64 s'affiche dans l'onboarding
- Le logo 48x48 s'affiche dans les settings > About
- L'accent primaire Fluent est `brandBlue` (#2979FF) et non teal
- Les active borders des cards sont `brandBlue`
- Les sélections dans la command palette sont `brandBlue`

### P7-T05 · Test Dark Mode complet

Naviguer dans les 9 onglets. Vérifier :
- Surfaces indigo-teintées (pas de gris neutre pur)
- Le logo est visible et net sur fond sombre
- Les badges utilisent les bonnes couleurs brand

### P7-T06 · Test Light Mode complet

Naviguer dans les 9 onglets. Vérifier :
- Aucun texte blanc sur fond blanc
- Le logo se lit parfaitement sur fond clair
- Les surfaces ont un sous-ton bleuté subtil
- Le terminal reste sombre

### P7-T07 · `flutter analyze` + `flutter test`

Résultat attendu : 0 warnings, 100% tests pass.

### P7-T08 · `flutter build windows --release`

Résultat attendu : Build réussi.

---

## Résumé des fichiers impactés v2.0

### Fichiers NOUVEAUX : 15

| # | Fichier | Phase |
|---|---------|-------|
| 1 | `assets/images/logo.png` | P0-T02 |
| 2 | `assets/fonts/JetBrainsMono-*.ttf` | P0-T01 |
| 3 | `lib/app/theme/app_colors.dart` | P1-T01 |
| 4 | `lib/app/theme/app_typography.dart` | P1-T02 |
| 5 | `lib/app/theme/app_spacing.dart` | P1-T03 |
| 6 | `lib/app/theme/app_radius.dart` | P1-T04 |
| 7 | `lib/app/theme/app_icons.dart` | P1-T05 |
| 8 | `lib/app/theme/app_dialog_sizes.dart` | P1-T06 |
| 9 | `lib/shared/widgets/app_status_dot.dart` | P2-T01 |
| 10 | `lib/shared/widgets/app_badge.dart` | P2-T02 |
| 11 | `lib/shared/widgets/app_shortcut_badge.dart` | P2-T03 |
| 12 | `lib/shared/widgets/app_brand_mark.dart` | P2-T04 |
| 13 | `lib/shared/widgets/app_card.dart` | P3-T01 |
| 14 | `lib/shared/widgets/app_console_box.dart` | P3-T02 |
| 15 | `lib/shared/widgets/app_metric_card.dart` | P3-T03 |
| 16 | `lib/shared/widgets/app_empty_state.dart` | P3-T04 |
| 17 | `lib/shared/widgets/app_section_card.dart` | P3-T05 |

### Fichiers MODIFIÉS : 32

| # | Fichier | Phase |
|---|---------|-------|
| 1 | `pubspec.yaml` | P0-T01, P0-T02 |
| 2 | `lib/app/theme/app_theme.dart` | P4-T01 |
| 3 | `lib/app/app.dart` | P4-T02, P5-T18 |
| 4 | `lib/app/window/window_titlebar.dart` | P4-T03, P5-T01 |
| 5 | `lib/features/terminal/widgets/terminal_theme_data.dart` | P4-T04, P5-T13 |
| 6 | `lib/features/servers/servers_view.dart` | P5-T02 |
| 7 | `lib/features/monitoring/monitoring_view.dart` | P5-T03 |
| 8 | `lib/features/docker/docker_view.dart` | P5-T04 |
| 9 | `lib/features/docker/docker_logs_dialog.dart` | P5-T04 |
| 10 | `lib/features/docker/widgets/docker_container_tile.dart` | P5-T04 |
| 11 | `lib/features/docker/widgets/docker_not_installed_view.dart` | P5-T04 |
| 12 | `lib/features/docker/widgets/docker_compose_tab.dart` | P5-T04 |
| 13 | `lib/features/services/services_view.dart` | P5-T05 |
| 14 | `lib/features/port_forwarding/tunnels_view.dart` | P5-T06 |
| 15 | `lib/features/file_manager/file_manager_view.dart` | P5-T07 |
| 16 | `lib/features/file_manager/widgets/sftp_breadcrumb_bar.dart` | P5-T07 |
| 17 | `lib/features/file_manager/widgets/sftp_file_list_tile.dart` | P5-T07 |
| 18 | `lib/features/file_manager/widgets/sftp_file_editor_dialog.dart` | P5-T07 |
| 19 | `lib/features/activity/activity_feed_view.dart` | P5-T08 |
| 20 | `lib/features/command_palette/command_palette_modal.dart` | P5-T09 |
| 21 | `lib/features/onboarding/welcome_view.dart` | P5-T10 |
| 22 | `lib/features/settings/settings_view.dart` | P5-T11 |
| 23 | `lib/features/settings/widgets/settings_section_card.dart` | P5-T11 |
| 24 | `lib/features/settings/widgets/backup_restore_card.dart` | P5-T11 |
| 25 | `lib/features/terminal/widgets/terminal_tab_view.dart` | P5-T12 |
| 26 | `lib/features/terminal/widgets/terminal_context_menu.dart` | P5-T14 |
| 27 | `lib/shared/widgets/connection_guard.dart` | P5-T15 |
| 28 | `lib/shared/widgets/loading_overlay.dart` | P5-T15 |
| 29 | `lib/shared/widgets/confirm_dialog.dart` | P5-T15 |
| 30 | `lib/features/servers/server_dialog.dart` | P5-T16 |
| 31 | `lib/features/servers/widgets/server_auth_fields.dart` | P5-T16 |
| 32 | `lib/features/port_forwarding/tunnel_dialog.dart` | P5-T17 |

---

## Changements clés v1.0 → v2.0 (résumé)

| Aspect | v1.0 | v2.0 (aligné logo) |
|--------|------|---------------------|
| **Accent principal** | `Colors.teal` | `#2979FF` (Brand Blue du logo) |
| **Cyan** | `#00E5FF` | `#00D4FF` (Brand Cyan du logo) |
| **Purple** | `Colors.purple` (anecdotique) | `#7C4DFF` (Brand Violet du logo) |
| **Surfaces dark** | `#0D1117` etc. (gris neutre) | `#0B0E18` etc. (indigo-teinté) |
| **Surfaces light** | `#F6F8FA` etc. (gris neutre) | `#F5F7FB` etc. (bleuté subtil) |
| **Textes** | Gris neutre chaud | Gris froid/indigo-teinté |
| **Titlebar logo** | `FluentIcons.server` icône | `logo.png` image 18x18 |
| **Onboarding hero** | Cercle + icône server | Logo 64x64 |
| **About logo** | Absent | Logo 48x48 |
| **Active borders** | Cyan `#00E5FF` | Brand Blue `#2979FF` |
| **Command palette selection** | Cyan | Brand Blue |
| **Connecting state** | Orange (warning) | Brand Blue (action de marque) |
| **Nouveau composant** | — | `AppBrandMark` widget |
| **Nouveau token** | — | `brandGradient` (Cyan→Blue→Violet) |

---

> **Ce protocole v2.0 aligne chaque pixel de l'application avec l'identité visuelle du logo.**
> L'accent principal est Brand Blue. Le gradient Cyan→Blue→Violet traverse l'application comme une signature.
