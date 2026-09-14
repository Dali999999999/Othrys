import 'package:fluent_ui/fluent_ui.dart';

/// Centralized, theme-aware color palette and semantic opacity helpers.
///
/// Follows the Othrys Design System v2.0 specifications strictly
/// (Brand Identity Cyan-Blue-Violet derived from logo.png, Dark-first with Light parity).
class AppColors {
  AppColors._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Brand Colors (extraites du logo 3D entrelacé)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Pôle lumineux du gradient logo. Données live, liens, ports, informationnel.
  static const Color brandCyan = Color(0xFF00D4FF);

  /// Cœur du logo. Accent principal de l'app. Boutons, navigation, filled buttons.
  static const Color brandBlue = Color(0xFF2979FF);

  /// Pôle profond du gradient logo. Accent secondaire, métriques stockage, touches premium.
  static const Color brandViolet = Color(0xFF7C4DFF);

  /// Ombre des intersections du logo. Overlays très profonds.
  static const Color brandNavy = Color(0xFF151038);

  /// Accent principal Fluent UI (AccentColor swatch complet basé sur brandBlue).
  static final AccentColor primaryAccent = AccentColor.swatch({
    'darkest': const Color(0xFF1565C0),
    'darker': const Color(0xFF1E88E5),
    'dark': const Color(0xFF2196F3),
    'normal': brandBlue,
    'light': const Color(0xFF42A5F5),
    'lighter': const Color(0xFF64B5F6),
    'lightest': const Color(0xFF90CAF9),
  });

  /// Gradient de marque (usage limité : logo rendu, onboarding, premium touches).
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandCyan, brandBlue, brandViolet],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Semantic Colors
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Opérations réussies, running, connecté.
  static const Color success = Color(0xFF00E676);

  /// Seuils élevés, attention requise, reconnexion.
  static const Color warning = Color(0xFFFF9100);

  /// Erreurs, échecs, actions destructives.
  static const Color danger = Color(0xFFFF5252);

  /// Raccourcis clavier, liens hypertexte, curseur terminal.
  static const Color blueLink = Color(0xFF58A6FF);

  // Backward-compatibility aliases
  /// Alias rétrocompatible pour le pôle cyan.
  static const Color accentCyan = brandCyan;

  /// Alias rétrocompatible pour le bleu de lien / raccourci.
  static const Color accentBlue = blueLink;

  /// Alias rétrocompatible pour le pôle violet (métriques disque).
  static const Color accentPurple = brandViolet;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Console & Terminal (toujours dark island)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Fond pour terminaux et consoles de logs.
  static const Color consoleBackground = Color(0xFF0B0E18);

  /// Couleur de texte par défaut dans les consoles et visionneuses de code.
  static const Color consoleText = Color(0xFFC5CDDF);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Theme-aware Surfaces (Indigo-tinted)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Canvas principal, fond d'app.
  static Color surfaceBase(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0B0E18) : const Color(0xFFF5F7FB);

  /// Conteneurs, cartes, sections.
  static Color surfaceCard(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111628) : const Color(0xFFFFFFFF);

  /// Popups, menus, pills inactifs, survols.
  static Color surfaceElevated(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1A2035) : const Color(0xFFE8ECF4);

  /// Bordures, séparateurs, contours.
  static Color surfaceBorder(BuildContext context) =>
      _isDark(context) ? const Color(0xFF2A3148) : const Color(0xFFCDD5E0);

  /// Modal barrier / scrim overlay background.
  static Color modalBarrier(BuildContext context) =>
      _isDark(context) ? const Color(0x80000000) : const Color(0x33000000);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Theme-aware Text Hierarchy (Cold/Indigo-tinted greys)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Titres, noms, labels importants.
  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFF0F4FC) : const Color(0xFF1A1E2E);

  /// Texte courant, descriptions, body.
  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFC5CDDF) : const Color(0xFF242838);

  /// Informations secondaires, placeholders.
  static Color textMuted(BuildContext context) =>
      _isDark(context) ? const Color(0xFF8490A8) : const Color(0xFF556178);

  /// Timestamps, captions, métadonnées tertiaires.
  static Color textFaint(BuildContext context) =>
      _isDark(context) ? const Color(0xFF5C6880) : const Color(0xFF6B7A92);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Opacity Helpers (Overlay patterns)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Background opacity helper (12%) pour badges et pills.
  static Color badgeBackground(Color semantic) => semantic.withValues(alpha: 0.12);

  /// Border opacity helper (35%) pour badges et pills.
  static Color badgeBorder(Color semantic) => semantic.withValues(alpha: 0.35);

  /// Selection and hover background highlight opacity helper (12%).
  static Color selectionBackground(Color semantic) => semantic.withValues(alpha: 0.12);

  /// Active container border opacity helper (40%).
  static Color activeBorder(Color semantic) => semantic.withValues(alpha: 0.40);

  /// Subtle gradient tint helper (8%).
  static Color gradientTint(Color semantic) => semantic.withValues(alpha: 0.08);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Internal
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static bool _isDark(BuildContext context) =>
      FluentTheme.of(context).brightness == Brightness.dark;
}

