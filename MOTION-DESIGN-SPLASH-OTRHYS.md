# 🎬 Direction Artistique — Animation d'Ouverture « Otrhys »

> **Document** : Cahier de motion design — Splash Screen Animation  
> **Application** : Otrhys  
> **Version** : 1.0  
> **Date** : 13 Septembre 2026  
> **Durée cible** : 2.8 – 3.2 secondes  
> **Framerate** : 60 FPS  
> **Résolution cible** : Responsive (plein écran desktop, ratio 16:9 natif)

---

## Sommaire

1. [Analyse du Logo](#1-analyse-du-logo)
2. [Concept Narratif](#2-concept-narratif)
3. [Palette & Univers Graphique](#3-palette--univers-graphique)
4. [Storyboard — Les 6 Actes](#4-storyboard--les-6-actes)
5. [Timing & Courbes d'Animation](#5-timing--courbes-danimation)
6. [Typographie & Logotype Hybride](#6-typographie--logotype-hybride)
7. [Effets Visuels & Particules](#7-effets-visuels--particules)
8. [Pas de Son](#8-pas-de-son)
9. [Spécifications Techniques Flutter](#9-spécifications-techniques-flutter)
10. [Références Visuelles](#10-références-visuelles)

---

## 1. Analyse du Logo

![Logo Otrhys](C:/Users/dalin/.gemini/antigravity/brain/73a5357d-69a4-4966-88ce-8fbd1bb4e4d9/logo.png)

### 1.1 Déconstruction Morphologique

Le logo Otrhys est un **hexagone entrelacé en 3D** composé de :

| Élément | Description | Signification |
|---------|-------------|---------------|
| **Ruban supérieur** | Chevron orienté vers le haut, gradient **cyan → bleu vif** | Aspiration, élévation, infrastructure cloud |
| **Ruban inférieur** | Chevron orienté vers le bas, gradient **bleu profond → violet** | Fondation, profondeur, robustesse |
| **Entrelacement** | Les deux rubans se croisent avec un passage dessus/dessous | Connexion, réseau, tunnels, flux de données |
| **Losange central** | Espace négatif formé par l'intersection | Ouverture, portail, point d'accès |
| **Zones d'ombre** | Navy profond (`#151038`) aux intersections | Profondeur 3D, sophistication |

### 1.2 ADN Chromatique

Le logo repose sur un **gradient tricolore continu**, qui constitue l'ADN visuel de toute l'animation :

```
  ╔═══════════════════════════════════════════╗
  ║                                           ║
  ║   Cyan (#00D4FF)                          ║
  ║     ↘                                     ║
  ║       Bleu vif (#2979FF) ← CŒUR          ║
  ║         ↘                                 ║
  ║           Violet indigo (#7C4DFF)         ║
  ║                                           ║
  ║   Ombre intersection : Navy (#151038)     ║
  ║                                           ║
  ╚═══════════════════════════════════════════╝
```

### 1.3 Propriétés Géométriques Clés

- **Symétrie hexagonale** : 6 côtés, angles à 120°
- **Rotation implicite** : Les rubans créent un mouvement giratoire visuel
- **Volumétrie** : Le dégradé simule une profondeur 3D sans être réellement en 3D
- **Entrelacement Möbius** : Les rubans passent alternativement dessus et dessous, créant un effet de ruban infini

> [!IMPORTANT]
> L'animation doit **décomposer** puis **recomposer** ces éléments. On ne fait pas « apparaître » un logo statique — on le **construit** devant les yeux de l'utilisateur.

---

## 2. Concept Narratif

### 2.1 Métaphore : « La Convergence »

L'animation raconte l'histoire de **deux flux d'énergie** (les rubans) qui voyagent depuis l'immensité du réseau pour converger au centre de l'écran, s'entrelacer, et former le symbole d'Otrhys — le point de contrôle.

**Narration en 3 temps :**

```
 ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
 │   GENÈSE    │ ──→ │  FORMATION  │ ──→ │ RÉVÉLATION  │
 │             │     │             │     │             │
 │ Le vide     │     │ Les rubans  │     │ Le logo     │
 │ s'éveille,  │     │ convergent, │     │ GLISSE pour │
 │ l'énergie   │     │ s'entrelacent│    │ devenir le  │
 │ émerge      │     │ et se       │     │ "O" et les  │
 │             │     │ verrouillent│     │ lettres     │
 │             │     │             │     │ TRHYS       │
 │             │     │             │     │ apparaissent│
 └─────────────┘     └─────────────┘     └─────────────┘
    0.0 — 0.8s         0.8 — 2.0s         2.0 — 3.0s
```

> [!IMPORTANT]
> **Choix créatif clé** : Le logo ne reste pas au-dessus du texte. Il **EST** la lettre "O" du mot OTRHYS. Lors de la révélation, le logo glisse depuis le centre vers sa position de première lettre, puis les lettres « TRHYS » apparaissent à sa droite. Cela crée un **logotype hybride** (icône + texte fusionnés) extrêmement distinctif.

### 2.2 Ton & Émotion

| Attribut | Cible |
|----------|-------|
| **Mood** | Confiance technologique, précision, premium |
| **Tempo** | Rapide mais élégant — jamais précipité |
| **Densité** | Minimaliste — peu d'éléments, mais chacun est magnifié |
| **Feeling** | « Mon outil est prêt, il est puissant et il est beau » |
| **Son** | **Aucun** — l'animation est 100% visuelle, silencieuse |

---

## 3. Palette & Univers Graphique

### 3.1 Fond d'écran — Le Canvas

Le fond n'est **jamais noir pur**. Il utilise la couleur `surface.base` du design system, teintée d'indigo :

```
Fond principal : #0B0E18 (Indigo-noir profond)
```

Ce choix crée une **profondeur atmosphérique** qui permet aux couleurs du logo de rayonner naturellement.

### 3.2 Palette de l'animation

| Rôle | Couleur | Hex | Usage dans l'animation |
|------|---------|-----|------------------------|
| **Énergie primaire** | Cyan lumineux | `#00D4FF` | Ruban supérieur, particules lumineuses, glow principal |
| **Cœur de marque** | Bleu vif | `#2979FF` | Point de fusion central, flash d'entrelacement |
| **Énergie profonde** | Violet indigo | `#7C4DFF` | Ruban inférieur, traînées particules, halo secondaire |
| **Ombre structurelle** | Navy profond | `#151038` | Zones d'intersection des rubans, ombres portées |
| **Canvas** | Indigo-noir | `#0B0E18` | Fond d'écran |
| **Texte** | Blanc froid | `#F0F4FC` | Logotype "OTRHYS" |
| **Accent glow** | Blanc pur | `#FFFFFF` @ 60% | Flash de verrouillage, halos lumineux |

### 3.3 Gradients Dynamiques

Trois gradients sont utilisés pendant l'animation :

```dart
// Gradient du ruban supérieur (gauche → droite)
LinearGradient(
  colors: [Color(0xFF00D4FF), Color(0xFF2979FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Gradient du ruban inférieur (gauche → droite)
LinearGradient(
  colors: [Color(0xFF2979FF), Color(0xFF7C4DFF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Gradient ambiant radial (fond)
RadialGradient(
  colors: [Color(0xFF2979FF).withOpacity(0.08), Colors.transparent],
  radius: 0.6,
)
```

---

## 4. Storyboard — Les 6 Actes

![Storyboard de l'animation splash](C:/Users/dalin/.gemini/antigravity/brain/73a5357d-69a4-4966-88ce-8fbd1bb4e4d9/splash_animation_storyboard_1789326996828.jpg)

> [!NOTE]
> Chaque acte est décrit frame par frame. Les timings sont indicatifs en secondes et en frames (à 60 FPS).

---

### ACTE 1 — « Le Vide Éveillé »
**Durée : 0.0s → 0.5s (frames 0–30)**

```
┌──────────────────────────────────────────┐
│                                          │
│                                          │
│                                          │
│               ·  ✦  ·                    │
│              ·  (○)  ·                   │  Halo radial doux
│               ·  ✦  ·                    │  au centre
│                                          │
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

**Description :**
- L'écran est sur fond `#0B0E18`
- Un **halo radial bleu très subtil** (`#2979FF` @ 5% opacité) pulse doucement au centre exact de l'écran
- Quelques **micro-particules lumineuses** (3-5 points de 1-2px) flottent lentement dans un rayon de 40px autour du centre
- Le halo respire : opacité 3% → 8% → 3% sur un cycle de 800ms
- Sensation : quelque chose va se passer, l'énergie s'accumule

**Paramètres techniques :**

| Propriété | Valeur |
|-----------|--------|
| Halo couleur | `#2979FF` @ 5-8% |
| Halo rayon | 80px → 120px (pulsation) |
| Particules | 5 points, 1-2px, `#00D4FF` @ 30% |
| Mouvement particules | Brownien lent, vitesse 0.3px/frame |
| Courbe halo | `Curves.easeInOut` (respiration) |

---

### ACTE 2 — « L'Émergence des Rubans »
**Durée : 0.5s → 1.2s (frames 30–72)**

```
┌──────────────────────────────────────────┐
│  ╲                                       │
│    ╲ ═══ Ruban Cyan                      │
│      ╲                                   │
│        ╲          ╱                      │
│          ╲      ╱                        │
│            ╲  ╱   ← Point de rencontre   │
│              ╳                           │
│            ╱  ╲                          │
│          ╱      ╲                        │
│                    ╲ ═══ Ruban Violet     │
│                      ╲                   │
└──────────────────────────────────────────┘
```

**Description :**
- **Frame 30-40** : Depuis le coin **haut-droit**, un ruban lumineux **cyan** (`#00D4FF` → `#2979FF`) commence à se dessiner. Il trace un arc en direction du centre. Sa tête est lumineuse, sa queue s'estompe en laissant une traînée de particules scintillantes.
- **Frame 35-45** : Depuis le coin **bas-gauche**, un ruban **violet** (`#2979FF` → `#7C4DFF`) émerge symétriquement, convergent vers le centre.
- Les rubans ont une épaisseur de ~40px avec des bords adoucis (blur 4px sur les contours)
- Chaque ruban laisse derrière lui une **traînée de particules** (20-30 points scintillants) qui s'estompent en 300ms
- Le halo central s'intensifie à mesure que les rubans approchent (8% → 15%)

**Paramètres techniques :**

| Propriété | Valeur |
|-----------|--------|
| Ruban épaisseur | 40px, bords blur 4px |
| Vitesse entrée | Accélération `Curves.easeOutCubic` |
| Traînée particules | 25 points, 1-3px, durée vie 300ms |
| Offset entrée Cyan | Depuis haut-droit (-200, -200) → centre |
| Offset entrée Violet | Depuis bas-gauche (+200, +200) → centre |
| Décalage entre rubans | 100ms (le cyan commence en premier) |

---

### ACTE 3 — « L'Entrelacement »
**Durée : 1.2s → 1.8s (frames 72–108)**

```
┌──────────────────────────────────────────┐
│                                          │
│                                          │
│           ╱‾‾‾‾╲                         │
│         ╱   __   ╲                       │
│        │  ╱    ╲  │   ← Les rubans       │
│        │ │  ◇◇  │ │     s'enroulent      │
│        │  ╲____╱  │     en hexagone      │
│         ╲        ╱                       │
│           ╲____╱                         │
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

**Description :**
- C'est le **moment clé** de l'animation — le plus spectaculaire
- Les deux rubans, arrivés au centre, commencent à **s'enrouler l'un autour de l'autre**
- Ils décrivent le tracé de l'hexagone, en passant alternativement **dessus et dessous**
- La rotation est fluide, presque organique — pas mécanique
- Aux points d'intersection, un bref **flash lumineux blanc** (`#FFFFFF` @ 60%, 50ms) souligne le croisement
- Les ombres navy (`#151038`) apparaissent progressivement aux zones de chevauchement

**Phases de l'entrelacement :**

| Phase | Frames | Action |
|-------|--------|--------|
| 3a | 72–84 | Les rubans se courbent, amorcent la forme hexagonale |
| 3b | 84–96 | Premier croisement — flash #1. Le ruban cyan passe sous le violet |
| 3c | 96–108 | Second croisement — flash #2. La forme se verrouille |

**Paramètres techniques :**

| Propriété | Valeur |
|-----------|--------|
| Rotation des rubans | Courbe `Curves.easeInOutCubic` |
| Flash intersection | `#FFFFFF` @ 60%, rayon 20px, durée 80ms, `Curves.easeOut` |
| Apparition ombres | Fade-in 200ms, `#151038` @ 80% |
| Taille hexagone cible | 120x120px (logo final) |
| Scale pendant formation | 1.15x → 1.0x (léger overshoot) |

---

### ACTE 4 — « Le Verrouillage »
**Durée : 1.8s → 2.2s (frames 108–132)**

```
┌──────────────────────────────────────────┐
│                                          │
│                                          │
│                                          │
│              ╭──────╮                    │
│             ╱  ╲  ╱  ╲                   │
│            │    ◇◇    │  ← Logo formé    │
│             ╲  ╱  ╲  ╱     + Onde de     │
│              ╰──────╯       choc         │
│          ～～～～～～～～～～～～               │
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

**Description :**
- Le logo est maintenant **formé** — les rubans sont en place
- Un **pulse d'onde de choc** (shockwave) circulaire part du centre vers l'extérieur
  - Anneau fin (2px) de couleur `#2979FF` @ 40%
  - S'étend de rayon 0 → 300px en 400ms
  - Opacité 40% → 0% pendant l'expansion
- Le logo effectue un micro **bounce** : scale 1.08x → 1.0x en 200ms (`Curves.elasticOut`)
- Les dernières particules se dissipent autour du logo
- Un **glow ambiant** se stabilise autour du logo : RadialGradient, `#2979FF` @ 8%, rayon 180px

**Paramètres techniques :**

| Propriété | Valeur |
|-----------|--------|
| Shockwave | Anneau 2px, `#2979FF` @ 40%→0%, rayon 0→300px, 400ms |
| Logo bounce | Scale 1.08→1.0, `Curves.elasticOut`, 200ms |
| Glow stabilisé | RadialGradient `#2979FF` @ 8%, rayon 180px |
| Particules restantes | Fade-out 300ms |

---

### ACTE 5 — « La Fusion Typographique »
**Durée : 2.2s → 2.8s (frames 132–168)**

```
┌──────────────────────────────────────────┐
│                                          │
│                                          │
│                                          │
│                                          │
│                                          │
│        [LOGO] T R H Y S                 │  ← Le logo GLISSE vers
│                                          │     la gauche et les lettres
│                                          │     apparaissent à droite
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

**Description — Le moment signature de l'animation :**
- Le logo, jusqu'ici **centré** à l'écran, commence à **glisser vers la gauche** pour prendre sa place de lettre "O"
- Ce glissement est accompagné d'un **léger scale-down** : le logo passe de 120x120px à **36x36px** (taille cohérente avec le texte de 28px) pendant le déplacement
- Simultanément, les lettres « **T R H Y S** » apparaissent une par une à droite du logo en **cascade séquentielle** (stagger) :
  - Chaque lettre : fade-in 0%→100% + slide-up de +10px → 0px
  - Délai entre chaque lettre : **60ms** (stagger)
  - Durée d'animation par lettre : **250ms**
- Le tout se retrouve **centré horizontalement** dans l'écran une fois complet
- Le logo dans sa position finale fait office de "O" — sa forme hexagonale arrondie s'y prête naturellement

**Séquençage détaillé :**

| Temps relatif | Action |
|---------------|--------|
| +0ms | Le logo commence son glissement vers la gauche + scale-down |
| +150ms | Le logo atteint sa position finale (première lettre) |
| +200ms | Lettre « T » apparaît |
| +260ms | Lettre « R » apparaît |
| +320ms | Lettre « H » apparaît |
| +380ms | Lettre « Y » apparaît |
| +440ms | Lettre « S » apparaît |

**Paramètres techniques :**

| Propriété | Valeur |
|-----------|--------|
| Logo déplacement | Centre → position "O" (calculé dynamiquement), `Curves.easeInOutCubic`, 300ms |
| Logo scale | 120px → 36px, synchronisé avec le déplacement |
| Stagger lettres | 60ms entre chaque, `Curves.easeOut` |
| Fade-in lettres | 0%→100%, 250ms |
| Slide-up lettres | +10px→0px, 250ms |
| Couleur lettres | `#F0F4FC` (text.primary dark) |
| Alignement vertical | Le centre vertical du logo (36px) s'aligne avec le centre vertical des lettres (28px) |

---

### ACTE 6 — « L'Attente & la Transition »
**Durée : 2.8s → 3.2s (frames 168–192)**

```
┌──────────────────────────────────────────┐
│                                          │
│                                          │
│                                          │
│                                          │
│                                          │
│        [LOGO] T R H Y S                 │  ← État de repos
│                                          │     puis fade-out total
│                                          │
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

**Description :**
- **État de repos** (400ms) : Le logotype hybride (logo + TRHYS) est stable au centre de l'écran. Le glow ambiant respire très subtilement (opacité 6%↔10%, cycle 2000ms).
- **Transition de sortie** : L'ensemble (logotype complet + glow) effectue :
  - **Scale-up** : 1.0x → 1.05x en 300ms
  - **Fade-out** : 100% → 0% en 300ms
  - Simultanément, le fond `#0B0E18` fade vers le fond de l'app (ou reste si identique)

**Paramètres techniques :**

| Propriété | Valeur |
|-----------|--------|
| Repos | 400ms, glow breathing 6%↔10% |
| Scale-out | 1.0→1.05, 300ms, `Curves.easeIn` |
| Fade-out | 100%→0%, 300ms, `Curves.easeIn` |
| Transition vers app | Crossfade 200ms ou navigation push |

---

## 5. Timing & Courbes d'Animation

### 5.1 Timeline Maître

```
0.0s        0.5s        1.0s        1.5s        2.0s        2.5s        3.0s
 │           │           │           │           │           │           │
 ├───────────┤           │           │           │           │           │
 │  ACTE 1   │           │           │           │           │           │
 │  Vide     │           │           │           │           │           │
 │  Éveillé  │           │           │           │           │           │
 │           ├───────────────────────┤           │           │           │
 │           │      ACTE 2           │           │           │           │
 │           │  Émergence Rubans     │           │           │           │
 │           │                       ├───────────┤           │           │
 │           │                       │  ACTE 3   │           │           │
 │           │                       │  Entrelac.│           │           │
 │           │                       │           ├───────────┤           │
 │           │                       │           │  ACTE 4   │           │
 │           │                       │           │  Verrou.  │           │
 │           │                       │           │           ├───────────┤
 │           │                       │           │           │  ACTE 5-6 │
 │           │                       │           │           │  Nom +    │
 │           │                       │           │           │  Sortie   │
 └───────────┴───────────────────────┴───────────┴───────────┴───────────┘
```

### 5.2 Courbes d'Easing

| Mouvement | Courbe Flutter | Justification |
|-----------|---------------|---------------|
| Halo respiration | `Curves.easeInOut` | Naturel, organique, symétrique |
| Entrée des rubans | `Curves.easeOutCubic` | Arrivée rapide, décélération douce |
| Rotation entrelacement | `Curves.easeInOutCubic` | Accélère au milieu, doux aux extrémités |
| Flash intersection | `Curves.easeOut` | Apparition instantanée, disparition douce |
| Logo bounce | `Curves.elasticOut` | Rebond mécanique satisfaisant |
| Shockwave expansion | `Curves.easeOut` | Rapide au début, dissipation progressive |
| Texte fade-in | `Curves.easeOut` | Apparition naturelle |
| Texte slide-up | `Curves.easeOut` | Mouvement ascendant élégant |
| Sortie scale | `Curves.easeIn` | Accélération vers la fin |

### 5.3 Règle d'Or du Timing

> [!TIP]
> **Règle des 300ms** : Aucune animation individuelle ne doit dépasser 500ms ni être plus courte que 80ms. Les animations entre 200-400ms sont le sweet spot pour que l'œil perçoive sans s'impatienter.

---

## 6. Typographie & Logotype Hybride

### 6.1 Le Logotype « [Logo]TRHYS »

> [!IMPORTANT]
> Le logo **remplace** la lettre "O". On n'écrit jamais "OTRHYS" en texte pur dans le splash. C'est toujours : **[icône logo] + T R H Y S**.

| Propriété | Valeur | Justification |
|-----------|--------|---------------|
| **Police des lettres** | `Segoe UI Variable` | Cohérence avec le design system Fluent |
| **Poids** | Semi-bold (600) | Assez fort pour se lire, pas trop lourd |
| **Taille texte** | 28px | Lisible sans dominer le logo-icône |
| **Taille logo (dans le mot)** | 36×36px | Légèrement plus grand que les lettres pour compenser la densité optique |
| **Couleur lettres** | `#F0F4FC` | text.primary — blanc froid harmonisé |
| **Letter spacing** | 5.0px | Effet premium, respiration entre les lettres |
| **Casse** | MAJUSCULES | Renforce l'identité de marque |

### 6.2 Composition du Logotype

```
     ┌────────────────────────────────────────┐
     │                                        │
     │   ┌──────┐                             │
     │   │ LOGO │  T   R   H   Y   S         │
     │   │36x36 │  ↑   ↑   ↑   ↑   ↑         │
     │   └──────┘  28px Semi-bold #F0F4FC     │
     │      ↑                                 │
     │   Le logo                              │
     │   remplace                             │
     │   le "O"      ←── 5px letter spacing   │
     │                                        │
     │   Gap logo↔T : 5px (même letter spacing)│
     │                                        │
     └────────────────────────────────────────┘
```

- Le **logo** est aligné verticalement au centre avec les lettres (baseline optique)
- Le gap entre le logo et le "T" est identique au `letterSpacing` (5px) pour une cohérence visuelle
- L'ensemble est **centré horizontalement** dans l'écran

---

## 7. Effets Visuels & Particules

### 7.1 Système de Particules

Deux types de particules coexistent dans l'animation :

#### Type A — Micro-particules ambiantes
| Propriété | Valeur |
|-----------|--------|
| Nombre | 5–8 |
| Taille | 1–2px |
| Couleur | `#00D4FF` @ 20-40% |
| Mouvement | Brownien lent (0.2-0.5px/frame) |
| Durée vie | Permanentes pendant Actes 1-3 |
| Fade-out | 500ms après Acte 4 |

#### Type B — Particules de traînée
| Propriété | Valeur |
|-----------|--------|
| Nombre | 20–30 par ruban |
| Taille | 1–3px |
| Couleur | Gradient du ruban parent (cyan ou violet) @ 40-80% |
| Mouvement | Émises depuis la tête du ruban, décélèrent |
| Durée vie | 200-400ms |
| Behaviour | Scintillement (opacité 40%↔80% aléatoire) |

### 7.2 Glow & Bloom

| Effet | Implémentation | Paramètres |
|-------|---------------|------------|
| **Halo central** | `BoxDecoration` + `RadialGradient` | `#2979FF`, rayon 80-180px, opacité 3-15% |
| **Glow ruban** | `BoxShadow` ou `BackdropFilter` | Blur 12px, couleur du ruban @ 30% |
| **Flash intersection** | `Container` animé | `#FFFFFF` @ 60%, rayon 20px, 80ms |
| **Shockwave** | `CustomPainter` + `drawCircle` | Stroke 2px, `#2979FF` @ 40%→0%, rayon 0→300px |

### 7.3 Profondeur & Ombres

Les ombres navy (`#151038`) aux intersections des rubans créent la volumétrie 3D du logo. Elles apparaissent en fade-in (200ms) lors de l'Acte 3 et restent présentes dans l'état final.

---

## 8. Pas de Son

> [!NOTE]
> **Décision créative** : L'animation est **100% visuelle**, sans aucun son ni haptic. Le silence renforce l'élégance et évite les nuisances en environnement professionnel. L'impact visuel se suffit à lui-même.

---

## 9. Spécifications Techniques Flutter

### 9.1 Architecture Widget

```dart
class SplashScreen extends StatefulWidget {
  // Widget principal du splash
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  // Controllers nécessaires :
  late AnimationController _haloController;      // Acte 1 : respiration
  late AnimationController _ribbonController;     // Acte 2 : entrée rubans
  late AnimationController _interweaveController; // Acte 3 : entrelacement
  late AnimationController _lockController;       // Acte 4 : verrouillage
  late AnimationController _textController;       // Acte 5 : révélation nom
  late AnimationController _exitController;       // Acte 6 : sortie
  
  // Chainage séquentiel via .addStatusListener
}
```

### 9.2 Rendu Custom

L'animation des rubans et de l'entrelacement nécessite un **CustomPainter** :

```dart
class SplashPainter extends CustomPainter {
  final double ribbonProgress;      // 0.0 → 1.0
  final double interweaveProgress;  // 0.0 → 1.0
  final double shockwaveProgress;   // 0.0 → 1.0
  
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dessiner le halo radial
    // 2. Dessiner les particules
    // 3. Dessiner les rubans (Path + gradient shader)
    // 4. Dessiner les zones d'ombre (intersection)
    // 5. Dessiner le flash / shockwave
  }
}
```

### 9.3 Considérations de Performance

| Aspect | Recommandation |
|--------|----------------|
| **RepaintBoundary** | Encapsuler le `CustomPaint` dans un `RepaintBoundary` |
| **shouldRepaint** | Retourner `true` uniquement quand les valeurs changent |
| **Image caching** | Pré-charger `logo.png` dans `precacheImage()` au `initState` |
| **Particules** | Maximum 40 particules simultanées |
| **Shader** | Utiliser `Paint()..shader` pour les gradients sur Path |
| **Frame budget** | Rester sous 16ms/frame pour maintenir 60 FPS |

### 9.4 Navigation Post-Splash

```dart
// À la fin de l'Acte 6, naviguer vers l'app
_exitController.addStatusListener((status) {
  if (status == AnimationStatus.completed) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainApp(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
});
```

### 9.5 Approche Simplifiée Alternative

Si la complexité du `CustomPainter` avec entrelacement est trop élevée, une **approche simplifiée** reste fidèle à l'esprit :

```
Simplification possible :
1. Acte 1 : Halo + particules → identique
2. Acte 2-3 : Remplacer les rubans animés par le logo.png 
   qui se construit via un ClipPath animé (révélation progressive)
3. Acte 4 : Shockwave + bounce → identique  
4. Acte 5-6 : Texte + sortie → identique
```

Cette approche utilise l'image `logo.png` elle-même, révélée progressivement par un masque animé (de haut-droite et bas-gauche simultanément), plutôt que de redessiner les rubans from scratch.

---

## 10. Références Visuelles

### 10.1 Inspirations Motion Design

| Référence | Ce qu'on retient |
|-----------|-----------------|
| **Logo Apple (keynotes)** | La simplicité, un seul objet, parfaitement animé |
| **Notion splash** | Le rythme : apparition → pause → transition. Pas de surcharge. |
| **Stripe branding** | Les gradients vivants, les couleurs qui respirent |
| **Figma loading** | Le logo qui se construit — les formes qui convergent |
| **Xbox Series X boot** | Le son + le visuel synchronisés, sensation de puissance maîtrisée |

### 10.2 Ce qu'on Évite

| Anti-pattern | Pourquoi |
|-------------|----------|
| ❌ Logo qui tourne sur lui-même | Générique, prévisible, amateur |
| ❌ Bounce excessif | Feeling « jouet », pas pro |
| ❌ Trop de texte | Le splash n'est pas un onboarding |
| ❌ Chargement visible | Le splash est une animation, pas un écran de chargement |
| ❌ Durée > 4 secondes | L'utilisateur s'impatiente au-delà de 3.5s |
| ❌ Fond noir pur `#000000` | Trop dur, pas d'atmosphère, dissonant avec le design system |

---

## Récapitulatif — Fiche Technique Express

| Paramètre | Valeur |
|-----------|--------|
| **Durée totale** | 3.0s (± 0.2s) |
| **Framerate** | 60 FPS |
| **Fond** | `#0B0E18` |
| **Couleurs clés** | `#00D4FF`, `#2979FF`, `#7C4DFF`, `#151038` |
| **Logo taille animée** | 120 × 120px → 36 × 36px (scale-down dans le logotype) |
| **Logotype** | [Logo]TRHYS — le logo **est** le "O" |
| **Texte TRHYS** | 28px, Semi-bold, `#F0F4FC`, spacing 5px |
| **Actes** | 6 (Vide → Rubans → Entrelacement → Lock → Fusion typo → Sortie) |
| **Transition sortie** | Scale 1.05x + fade-out 300ms |
| **Easing principal** | `Curves.easeOutCubic` (entrées), `Curves.elasticOut` (bounce) |
| **Particules max** | 40 simultanées |
| **Son** | **Aucun** — animation 100% visuelle |

---

> [!IMPORTANT]
> Ce document est la **source de vérité** pour l'animation d'ouverture d'Otrhys. Chaque frame, chaque couleur, chaque timing doit être implémenté tel que décrit ici. Les ajustements fins (±50ms, ±5% opacité) sont autorisés lors de l'implémentation pour « sentir » le rythme, mais la structure en 6 actes et la direction artistique sont **verrouillées**.
