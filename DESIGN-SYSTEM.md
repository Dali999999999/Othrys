# Othrys — Design System

> **Version** : 2.0.0  
> **Plateforme** : Windows 11 Desktop (Fluent UI for Flutter)  
> **Direction artistique** : Cyan-Blue-Violet Brand Identity · Minimaliste professionnel · Dark-first with Light parity  
> **Dernière mise à jour** : 2026-09-13

---

## Table des matières

1. [Identité de marque & Logo](#1-identité-de-marque--logo)
2. [Philosophie & Principes directeurs](#2-philosophie--principes-directeurs)
3. [Palette de couleurs](#3-palette-de-couleurs)
4. [Échelle typographique](#4-échelle-typographique)
5. [Iconographie & Logo](#5-iconographie--logo)
6. [Spacing & Layout Grid](#6-spacing--layout-grid)
7. [Border Radius — Échelle unifiée](#7-border-radius--échelle-unifiée)
8. [Élévation & Surfaces](#8-élévation--surfaces)
9. [Composants atomiques](#9-composants-atomiques)
10. [Composants moléculaires](#10-composants-moléculaires)
11. [Patterns de page](#11-patterns-de-page)
12. [États & Feedback](#12-états--feedback)
13. [Motion & Animation](#13-motion--animation)
14. [Thème Light — Parité complète](#14-thème-light--parité-complète)
15. [Accessibilité](#15-accessibilité)
16. [Anti-patterns — Ce qui est interdit](#16-anti-patterns--ce-qui-est-interdit)

---

## 1. Identité de marque & Logo

### 1.1 Le Logo

Le logo Othrys est un **hexagone entrelacé** en 3D — deux rubans qui se croisent en formant un losange négatif au centre. Il évoque la **connexion**, l'**infrastructure** (hexagone = molécule, réseau, container) et l'**entrelacement** (tunnels SSH, flux de données).

Le logo dicte l'ensemble de la direction artistique de l'application.

### 1.2 Extraction chromatique du logo

Le logo repose sur un **dégradé tricolore continu** :

```
   Cyan (#00D4FF)
     ↓
   Bleu vif (#2979FF)
     ↓
   Violet indigo (#7C4DFF)
```

Avec des **ombres profondes** aux intersections des rubans : **navy indigo** (`#151038`).

### 1.3 Conséquences sur le Design System

| Avant (v1.0) | Après (v2.0) — Aligné logo |
|--------------|---------------------------|
| Accent principal : `Colors.teal` | Accent principal : **Brand Blue** `#2979FF` |
| Cyan informationnel seul : `#00E5FF` | Cyan = pôle lumineux du gradient brand : `#00D4FF` |
| Purple anecdotique (disk only) : `Colors.purple` | Violet = pôle profond du gradient brand : `#7C4DFF` |
| Surfaces neutres obsidian (gris pur) | Surfaces **indigo-teintées** (gris froid bleuté) harmonisant avec le logo |
| Pas de logo dans l'app | Logo intégré dans titlebar, onboarding, about, splash |
| Identité visuelle générique | Identité unique Cyan→Blue→Violet |

---

## 2. Philosophie & Principes directeurs

### Vision

Othrys est un outil DevOps d'ingénierie. Son interface doit inspirer **confiance**, **maîtrise** et **calme technique**. La palette issue du logo — une cascade de **cyan**, **bleu** et **violet** — apporte une touche **premium** et **distinctive** sans sacrifier la sobriété professionnelle.

### Les 7 Principes

| # | Principe | Description |
|---|----------|-------------|
| 1 | **Clarté fonctionnelle** | Chaque élément UI communique son rôle sans ambiguïté. Pas de décoration gratuite. |
| 2 | **Hiérarchie visuelle stricte** | L'œil doit toujours savoir où regarder. Un titre, une action primaire, un état — jamais en compétition. |
| 3 | **Cohérence systémique** | Un même concept s'exprime toujours de la même manière dans l'ensemble de l'app. |
| 4 | **Densité maîtrisée** | Un outil desktop pour ingénieurs. Dense mais aéré. Jamais surchargé, jamais vide. |
| 5 | **Dark-first, Light-ready** | Le thème sombre est primaire, mais le thème clair doit être parfaitement fonctionnel. |
| 6 | **Brand-aligned** | Chaque choix de couleur doit pouvoir être relié au gradient du logo (Cyan→Blue→Violet). |
| 7 | **Zéro hardcoded** | Chaque couleur, taille, rayon et espacement passe par un token centralisé. |

---

## 3. Palette de couleurs

### 3.1 Couleurs de marque (extraites du logo)

| Token | Hex | Rôle |
|-------|-----|------|
| `brand.cyan` | `#00D4FF` | Pôle lumineux du gradient. Données live, liens, ports, informationnel. |
| `brand.blue` | `#2979FF` | **Accent principal.** Cœur du logo. Boutons, navigation, accents actifs, FilledButton. |
| `brand.violet` | `#7C4DFF` | Pôle profond du gradient. Accent secondaire, métriques stockage, touches premium. |
| `brand.navy` | `#151038` | Ombre des intersections du logo. Utilisé pour les overlays très profonds. |

### 3.2 Le Gradient de marque

Pour les usages décoratifs **limités et contrôlés** (logo rendu, onboarding hero, selected state premium) :

```dart
static const brandGradient = LinearGradient(
  colors: [Color(0xFF00D4FF), Color(0xFF2979FF), Color(0xFF7C4DFF)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);
```

**Usage autorisé** : Logo dans titlebar, avatar onboarding, badge connexion premium.  
**Usage interdit** : Fonds de page, cards, boutons standard.

### 3.3 Surfaces (Dark Mode — Primaire)

Les surfaces adoptent un **sous-ton indigo froid** pour harmoniser avec le logo. Le gris n'est plus neutre/chaud : il tire vers le bleu nuit.

| Token | Hex | Delta vs v1.0 | Rôle |
|-------|-----|--------------|------|
| `surface.base` | `#0B0E18` | Était `#0D1117` | Canvas principal, fond d'app, terminal |
| `surface.card` | `#111628` | Était `#161B22` | Conteneurs, cartes, sections |
| `surface.elevated` | `#1A2035` | Était `#21262D` | Popups, menus, pills inactifs, survols |
| `surface.border` | `#2A3148` | Était `#30363D` | Bordures, séparateurs, contours |

> **Justification** : Le shift vers l'indigo est subtil (composante bleue augmentée de ~15%) mais crée une harmonie immédiate avec le logo Cyan→Blue→Violet. L'app ne paraît plus "GitHub-like" mais possède sa propre identité visuelle.

### 3.4 Surfaces (Light Mode)

| Token | Hex | Rôle |
|-------|-----|------|
| `surface.base` | `#F5F7FB` | Canvas principal (légèrement bleuté vs blanc pur) |
| `surface.card` | `#FFFFFF` | Conteneurs, cartes |
| `surface.elevated` | `#E8ECF4` | Popups, survols (sous-ton bleu) |
| `surface.border` | `#CDD5E0` | Bordures (sous-ton bleu) |

### 3.5 Textes — Hiérarchie à 4 niveaux

| Token | Dark Hex | Light Hex | Rôle |
|-------|----------|-----------|------|
| `text.primary` | `#F0F4FC` | `#1A1E2E` | Titres, noms, labels importants |
| `text.secondary` | `#C5CDDF` | `#242838` | Texte courant, descriptions, body |
| `text.muted` | `#8490A8` | `#556178` | Informations secondaires, placeholders |
| `text.faint` | `#5C6880` | `#6B7A92` | Timestamps, captions, métadonnées tertiaires |

> **Note** : Les couleurs de texte ont aussi été légèrement décalées vers le bleu pour s'harmoniser avec les surfaces indigo. Le gris n'est plus "chaud" mais "froid".

### 3.6 Couleurs sémantiques

| Token | Hex | Rôle |
|-------|-----|------|
| `accent.primary` | `#2979FF` | Accent Fluent UI principal (NavigationPane, FilledButton, ToggleSwitch) — **Brand Blue** |
| `accent.cyan` | `#00D4FF` | Informationnel, données live, port mappings — **Brand Cyan** |
| `accent.violet` | `#7C4DFF` | Accent secondaire, métriques stockage, touches premium — **Brand Violet** |
| `semantic.success` | `#00E676` | Connecté, running, enabled, opérations réussies |
| `semantic.warning` | `#FF9100` | Seuils élevés, reconnexion, attention requise |
| `semantic.danger` | `#FF5252` | Erreur, failed, disconnected, actions destructives |

### 3.7 Couleurs utilitaires

| Token | Hex | Rôle |
|-------|-----|------|
| `accent.blueLink` | `#58A6FF` | Raccourcis clavier, liens hypertexte, curseur terminal |

### 3.8 Couleurs d'opacité (Overlay patterns)

| Usage | Opacité |
|-------|---------|
| Badge / Pill fond sémantique | `12%` |
| Badge / Pill bordure sémantique | `35%` |
| Sélection active / Survol accent | `12%` |
| Overlay modal (LoadingOverlay) | `50%` |
| Card border active (connected) | `40%` |
| Gradient brand background (rare) | `8%` |

---

## 4. Échelle typographique

### 4.1 Police système

| Usage | Famille | Fallback |
|-------|---------|----------|
| UI générale | Segoe UI Variable (système Fluent) | Segoe UI, sans-serif |
| Monospace (terminal, code, ports, hosts) | `JetBrains Mono` | `Cascadia Code`, `Consolas`, monospace |

### 4.2 Échelle de taille

| Token | Taille | Poids | Usage |
|-------|--------|-------|-------|
| `typo.displayLarge` | 24px | Bold (700) | Titre de métrique (ex: "87%"), en-tête onboarding |
| `typo.titleLarge` | 20px | Semi-bold (600) | PageHeader titre |
| `typo.titleMedium` | 16px | Semi-bold (600) | Sous-sections, empty state titre, section card titre |
| `typo.body` | 14px | Medium (500) | Texte courant, noms de serveurs, labels d'action |
| `typo.bodySmall` | 13px | Regular (400) | Descriptions, messages log, subtitles |
| `typo.caption` | 12px | Regular (400) | Host:port, données techniques, endpoints |
| `typo.micro` | 11px | Medium (500) | Badges, tags, timestamps |
| `typo.nano` | 10px | Bold (700) | Raccourcis clavier, compteurs badge, indicateurs |

### 4.3 Règles typographiques

- `letterSpacing: -0.5` uniquement sur `displayLarge`
- `height: 1.4` pour les blocs multi-lignes
- Endpoints → `typo.caption` + monospace + `text.muted`
- **Interdit** : Aucun `TextStyle` en dur dans les vues

---

## 5. Iconographie & Logo

### 5.1 Logo dans l'application

| Emplacement | Format | Taille | Détails |
|-------------|--------|--------|---------|
| **Titlebar** | `Image.asset('assets/images/logo.png')` | 18x18px | Remplace `FluentIcons.server` en haut à gauche |
| **Onboarding hero** | `Image.asset('assets/images/logo.png')` | 64x64px | Remplace l'avatar circulaire avec icône server |
| **About section** | `Image.asset('assets/images/logo.png')` | 48x48px | À côté du nom et version |
| **App icon** | Icône Windows native | 256x256px | ICO pour la fenêtre et la barre des tâches |

### 5.2 Source d'icônes

Utilisation exclusive de `FluentIcons` (package `fluent_ui`). Aucune icône Material n'est autorisée.

### 5.3 Échelle de taille

| Token | Taille | Usage |
|-------|--------|-------|
| `icon.xs` | 10px | Icônes dans badges/pills |
| `icon.sm` | 12px | Icônes dans boutons inline |
| `icon.md` | 14px | Icônes d'action standard |
| `icon.lg` | 20px | Icônes de carte |
| `icon.xl` | 32px | Icônes d'illustration |
| `icon.hero` | 48px | Empty state illustration |

### 5.4 Mapping sémantique

| Concept | Icône | Couleur |
|---------|-------|---------|
| Serveur | `FluentIcons.server` | `brand.blue` (actif) / `text.muted` (inactif) |
| Terminal | `FluentIcons.command_prompt` | Hérité du thème |
| Fichiers | `FluentIcons.folder_open` | Hérité du thème |
| Monitoring | `FluentIcons.line_chart` | Hérité du thème |
| Docker | `FluentIcons.package` | Hérité du thème |
| Services | `FluentIcons.developer_tools` | Hérité du thème |
| Tunnels | `FluentIcons.branch_fork2` | Hérité du thème |
| Activité | `FluentIcons.history` | Hérité du thème |
| Settings | `FluentIcons.settings` | Hérité du thème |
| Connexion | `FluentIcons.plug_connected` | `semantic.success` |
| Déconnexion | `FluentIcons.plug_disconnected` | `semantic.danger` / `text.muted` |
| Suppression | `FluentIcons.delete` | `semantic.danger` |
| Dossier | `FluentIcons.folder` | `brand.cyan` |
| Fichier | `FluentIcons.page` | `text.muted` |
| Recherche | `FluentIcons.search` | `text.muted` |

---

## 6. Spacing & Layout Grid

### 6.1 Tokens d'espacement (grille 4-point)

| Token | Valeur | Usage |
|-------|--------|-------|
| `space.xxs` | 2px | Micro-ajustements |
| `space.xs` | 4px | Gap intra-composant |
| `space.sm` | 8px | Espacement dense |
| `space.md` | 12px | Espacement standard |
| `space.lg` | 16px | Padding de card |
| `space.xl` | 20px | Respiration entre groupes |
| `space.xxl` | 24px | Padding de page horizontal |
| `space.xxxl` | 32px | Padding large |

### 6.2 Layout principaux

| Zone | Dimension |
|------|-----------|
| **Titlebar** | 38px |
| **NavigationPane** | Mode `compact` |
| **Page padding** | `horizontal: 24px, vertical: 8px` |
| **Grid serveurs** | `maxCrossAxisExtent: 380, mainAxisExtent: 220, gap: 16` |

---

## 7. Border Radius — Échelle unifiée

**3 niveaux seulement.**

| Token | Valeur | Usage |
|-------|--------|-------|
| `radius.sm` | 4px | Badges, pills, tags, selection highlights |
| `radius.md` | 8px | Cards, dialogs, containers, consoles |
| `radius.pill` | 999px | Avatars, dots, compteurs arrondis |

---

## 8. Élévation & Surfaces

### 8.1 Hiérarchie des couches

```
Layer 4 — Dialogs, Flyouts     (surface.elevated + shadow)
Layer 3 — Cards, Containers     (surface.card + border)
Layer 2 — Pills, Badges, Tabs   (surface.elevated)
Layer 1 — Base Canvas            (surface.base)
```

### 8.2 Card System

| Propriété | Valeur |
|-----------|--------|
| Background | `surface.card` (theme-aware) |
| Border | `1px solid surface.border` (theme-aware) |
| Radius | `radius.md` (8px) |
| Padding | `space.lg` (16px) |
| Active variant | Border → `brand.blue @ 40%` opacity |
| Hover | Background luminosité +5% |

---

## 9. Composants atomiques

### 9.1 `AppStatusDot`

| Propriété | Valeur |
|-----------|--------|
| **Taille** | 8x8px uniforme |
| **Forme** | `BoxShape.circle` |
| **Couleurs** | `semantic.success` · `semantic.warning` · `semantic.danger` · `text.faint` (inactif) |
| **Animation** | `pulse` subtil pour `streaming` / `connecting` (1500ms loop) |

### 9.2 `AppBadge` / `AppPill`

| Propriété | Valeur |
|-----------|--------|
| **Padding** | `horizontal: 6px, vertical: 2px` |
| **Radius** | `radius.sm` (4px) |
| **Fond** | Couleur sémantique @ 12% |
| **Bordure** | Couleur sémantique @ 35%, 1px |
| **Texte** | `typo.nano` (10px), Bold, couleur sémantique |
| **Variantes** | `success` · `warning` · `danger` · `info` (brand.cyan) · `accent` (brand.blue) · `neutral` |

### 9.3 `AppShortcutBadge`

| Propriété | Valeur |
|-----------|--------|
| **Fond** | `surface.elevated` |
| **Radius** | `radius.sm` (4px) |
| **Texte** | `typo.nano`, Bold, `accent.blueLink` |

### 9.4 Boutons — Hiérarchie à 4 niveaux

| Niveau | Composant | Rôle |
|--------|-----------|------|
| **Primaire** | `FilledButton` (accent: `brand.blue`) | Action principale unique par zone |
| **Secondaire** | `Button` | Actions complémentaires |
| **Tertiaire** | `IconButton` | Actions compactes |
| **Danger** | `FilledButton` + `semantic.danger` | Actions destructives |

Icône dans bouton : `icon.sm` (12px), gap `space.sm` (6px). Pas de fontSize custom.

### 9.5 `AppBrandMark` — Rendu du logo

| Propriété | Valeur |
|-----------|--------|
| **Widget** | `Image.asset('assets/images/logo.png')` |
| **Variantes** | `titlebar` (18x18) · `hero` (64x64) · `about` (48x48) |
| **Filtres** | Aucun filtre. Le logo se lit parfaitement sur dark et light backgrounds. |

---

## 10. Composants moléculaires

### 10.1 `AppCard` — Carte standard

| Propriété | Valeur |
|-----------|--------|
| Background | `surface.card` (theme-aware) |
| Border | `1px solid surface.border` (theme-aware) |
| Active border | `brand.blue @ 40%` |
| Radius | `radius.md` (8px) |
| Padding | `space.lg` (16px) |

### 10.2 `AppConsoleBox` — Terminal / Code output

| Propriété | Valeur |
|-----------|--------|
| Background | `#0B0E18` (toujours dark — `surface.base` dark) |
| Border | `1px solid surface.border` |
| Radius | `radius.md` (8px) |
| Padding | `space.md` (12px) |
| Font | `JetBrains Mono`, 12px, `#C5CDDF` (text.secondary dark) |

### 10.3 `AppMetricCard` — KPI / Jauge

| Propriété | Valeur |
|-----------|--------|
| Container | `AppCard` standard |
| Label | `typo.caption`, `text.muted` |
| Value | `typo.displayLarge`, couleur sémantique dynamique |
| Subtitle | `typo.micro`, monospace, `text.faint` |
| Seuils | CPU > 80% → danger · RAM > 85% → warning · Disk > 90% → danger |
| Disk couleur normale | `brand.violet` (anciennement `Colors.purple`) |

### 10.4 `AppDialog` — 3 classes de taille

| Classe | Largeur | Hauteur |
|--------|---------|---------|
| `compact` | 460px | Auto |
| `standard` | 520px | Auto |
| `wide` | 740px | 480px |

### 10.5 `AppEmptyState`

| Propriété | Valeur |
|-----------|--------|
| Icône | `icon.hero` (48px), `surface.border` |
| Titre | `typo.titleMedium`, `text.secondary` |
| CTA | `FilledButton` (optionnel), accent `brand.blue` |

### 10.6 `AppSectionCard`

Remplacement unifié de `SettingsSectionCard` :
- Fond : `surface.card` (theme-aware)
- Bordure : `1px surface.border`
- Titre : `typo.body`, `text.primary`, w600

---

## 11. Patterns de page

### 11.1 Layout standard

```
+----------------------------------------------------------+
|  WindowTitleBar (38px)                                    |
|  [Logo 18x18] [Title] [Badge] ...  [Search] [CaptionBtns]|
+------+---------------------------------------------------+
| Nav  |  ScaffoldPage                                      |
| Pane |  [PageHeader: Title + CommandBar]                  |
|      |  [Content: padding 24h x 8v]                      |
+------+---------------------------------------------------+
```

### 11.2 Page header convention

- Ordre du CommandBar : `[Filtres]` → `[Secondaires]` → `[Primaire]`
- Gap : `space.sm` (8px)

### 11.3 Titlebar — Brand identity refresh

La titlebar porte maintenant l'identité de marque :
- Logo image 18x18 au lieu de l'icône server
- Titre "Othrys" en `text.primary`
- Badge connexion avec `AppBadge` (variant success)

---

## 12. États & Feedback

### 12.1 États de connexion

| État | Dot | Couleur |
|------|-----|---------|
| `connected` | Filled | `semantic.success` |
| `connecting` | Pulsing | `brand.blue` |
| `reconnecting` | Pulsing | `semantic.warning` |
| `disconnected` | Empty | `text.faint` |
| `error` | Filled | `semantic.danger` |

> **Changement** : L'état `connecting` utilise `brand.blue` au lieu de `semantic.warning` (orange). La connexion en cours est une action de marque, pas un warning.

### 12.2 Système de notifications

| Type | Widget | Sévérité |
|------|--------|----------|
| Erreur inline | `InfoBar` error | Persistant + retry |
| Erreur toast | `displayInfoBar()` error | Temporaire |
| Succès toast | `displayInfoBar()` success | Temporaire |
| Warning inline | `InfoBar` warning | Persistant |
| Confirm destructif | `ConfirmDialog` | Modal bloquant |

### 12.3 Chargement

| Contexte | Widget |
|----------|--------|
| Page complète | `Center(child: ProgressRing())` |
| Modal overlay | `LoadingOverlay` fond `#000000 @ 50%` |
| Inline bouton | `ProgressRing` 14x14 |

---

## 13. Motion & Animation

### 13.1 Principes

Subtil et fonctionnel. Courbe standard : `Curves.easeOut`.

### 13.2 Catalogue

| Animation | Durée | Contexte |
|-----------|-------|----------|
| Scroll to selection | 100ms | Command palette |
| Status dot pulse | 1500ms loop | Connecting, streaming |
| ProgressBar value | 250ms | Monitoring jauges |
| Chart data update | 250ms | CPU sparkline |
| Card hover | 150ms | Server cards |
| Tab/Dialog/Toggle | built-in Fluent | — |

---

## 14. Thème Light — Parité complète

### 14.1 Règle fondamentale

> Aucune couleur hardcodée. Tout passe par un getter theme-aware.

### 14.2 Éléments spéciaux en Light mode

| Élément | Adaptation |
|---------|------------|
| Terminal / Console | Reste en dark (`surface.base` dark toujours) |
| Logo | Se lit parfaitement sur fond clair (gradient cyan-blue-violet sur blanc) |
| Window titlebar | `surface.card` light + `text.primary` light |
| Caption buttons | `Brightness.light` |
| Surfaces | Légèrement bleutées (sous-ton froid) |

---

## 15. Accessibilité

### 15.1 Contraste

| Combinaison | Ratio | Conformité |
|-------------|-------|------------|
| `text.primary` sur `surface.base` (dark) | 15.8:1 | AAA |
| `text.muted` sur `surface.base` (dark) | 5.0:1 | AA |
| `brand.blue` sur `surface.card` (dark) | 4.8:1 | AA |
| `brand.cyan` sur `surface.card` (dark) | 7.2:1 | AAA |
| `text.primary` sur `surface.base` (light) | 15.1:1 | AAA |

### 15.2 Règles

- Contraste AA (4.5:1) minimum pour tout texte interactif
- Icônes d'action >= `icon.md` (14px)
- Status dots toujours accompagnés d'un label textuel
- Navigation clavier complète
- Focus ring visible (Fluent default)

---

## 16. Anti-patterns — Ce qui est interdit

| Interdit | Remplacement |
|----------|--------------|
| `Colors.white` en dur | `AppColors.textPrimary(context)` |
| `Color(0xFF8B949E)` en dur | `AppColors.textMuted(context)` |
| `Color(0xFF6E7681)` en dur | `AppColors.textFaint(context)` |
| `Color(0xFFC9D1D9)` en dur | `AppColors.textSecondary(context)` |
| `Color(0xFF0D1117)` en dur | `AppColors.surfaceBase(context)` |
| `Color(0xFF161B22)` en dur | `AppColors.surfaceCard(context)` |
| `Color(0xFF21262D)` en dur | `AppColors.surfaceElevated(context)` |
| `Color(0xFF30363D)` en dur | `AppColors.surfaceBorder(context)` |
| `Colors.red` (Material) | `AppColors.danger` |
| `Colors.purple` (Material) | `AppColors.brandViolet` |
| `Colors.teal` comme accent | `AppColors.brandBlue` |
| `#00E5FF` comme cyan | `AppColors.brandCyan` (`#00D4FF`) |
| `BorderRadius.circular(6/10/12)` | `AppRadius.sm(4)` ou `AppRadius.md(8)` |
| `fontSize: 11` sur Button | Style Fluent par défaut |
| `TextStyle(...)` en dur | `AppTypo.*` tokens |
| `Brightness.dark` en dur | `FluentTheme.of(context).brightness` |
| `FluentIcons.server` dans titlebar | `Image.asset('assets/images/logo.png')` |

---

> **Ce Design System v2.0 — aligné sur le logo — est la source de vérité unique pour toute décision visuelle dans Othrys.**
