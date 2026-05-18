# Handoff — KitabLilJamie mobile app

## Overview

**KitabLilJamie** ("كتاب للجميع" — "a book for everyone") is an accessibility-first mobile reading platform targeting Moroccans with visual or hearing impairments. It is being prepared for Rabat Smart Book 2026 × UNESCO.

This handoff covers the **first interactive prototype** of the mobile app — six core screens split across two user modules:

- **Module 01 · Samia** — for visually-impaired users. A voice-driven library with an Arabic/French/Darija voice assistant ("Samia / سامية") who reads books aloud.
- **Module 02 · SignBook** — for deaf and hard-of-hearing users. A library where each book is summarised and narrated by an animated 3D avatar signing in **Moroccan Sign Language (LSM)**. Every UI icon is also explainable in LSM on long-press.

A third module ("Braille+IA") is mentioned in the project pitch but is **not** designed in this prototype.

## About the design files

The files in this bundle are **design references created in HTML/JSX** — prototypes showing intended look and behavior. They are **not** production code to copy directly.

The task is to **recreate these screens inside the target codebase's environment** (React Native, Flutter, SwiftUI, native iOS/Android, or a web app — whichever the team chooses) using its established patterns, design tokens, and libraries. If no framework has been chosen yet for the mobile app, **React Native + Expo** is the recommended target given the bilingual French/Arabic UI, accessibility requirements (TalkBack/VoiceOver), and shared codebase with web.

## Fidelity

**High-fidelity (hifi).** All colors, typography, spacing, layouts, copy, and animations are intentional and final. The developer should recreate the UI pixel-perfectly using the codebase's existing component library, applying the design tokens below.

## Tech stack used in the prototype

(For reference only — do not port directly.)

- Single HTML page (`KitabLilJamie.html`) bootstrapping React 18 via `<script type="text/babel">` with Babel Standalone.
- Components split into `screens.jsx`, `signing-avatar.jsx`, `book-covers.jsx`.
- All animations are **SMIL `<animateTransform>` on inline SVG** — no canvas, no WebGL, no GIFs. The "3D avatars" are stylised SVG jointed figures whose shoulders and elbows rotate via keyframed angles. Implementing this on native should target the equivalent (e.g. React Native + `react-native-svg` + `react-native-reanimated`, or Lottie if assets are produced).

---

## Brand & design system

### Palette

| Token | Hex | Usage |
|---|---|---|
| `bg`        | `#F6F2EB` | Primary screen background — warm cream |
| `card`      | `#FFFFFF` | Card surface on cream bg |
| `ink`       | `#1B1A17` | Primary text / dark surfaces |
| `ink2`      | `#3A352E` | Body text |
| `muted`     | `#827B6F` | Secondary text |
| `faint`     | `#B6AE9F` | Tertiary / faded text |
| `hair`      | `#E8E1D5` | 1px borders |
| `pill`      | `#EDE6D8` | Chip/pill background |
| `accent`    | `#B8552D` | Brand accent — terracotta (use sparingly; only one accent in design) |
| `accentSoft`| `#F1E2D6` | Accent highlight background (e.g. selected text in reader) |
| `dark`      | `#1B1A17` | Dark mode background (Samia listening screen) |

Background gradient for the stage area on the screen-frame page:
`radial-gradient(ellipse at 30% 0%, #F0EADD 0%, #E6DFD0 60%, #DDD5C2 100%)`

### Typography

Three families, all loaded from Google Fonts:

| Family | Weights | Usage |
|---|---|---|
| **Geist** (sans) | 300, 400, 500, 600 | All UI text |
| **Geist Mono** | 400, 500 | Eyebrows, labels, durations, breadcrumbs, badges |
| **Noto Kufi Arabic** | 400, 500, 600 | Any Arabic copy |

System fallback: `-apple-system, system-ui, sans-serif`.

Type scale used in the prototype (px, mobile 360-width frame):

| Role | Size | Weight | Letter-spacing | Line-height |
|---|---|---|---|---|
| Display H1 (home title)    | 38 | 400 | -1.2 | 1.1 |
| Page H2                    | 28–32 | 400 | -0.9 to -1 | 1.15 |
| Card title                 | 16 | 500 | -0.2 | 1.2 |
| Body                       | 14–15 | 400 | normal | 1.5 |
| Reader paragraph           | 16 | 400 | normal | 1.55 |
| Meta / eyebrow (mono)      | 9–11 | 400/500 | 1.0–1.6 (uppercase) | n/a |
| Status bar                 | 15 | 600 | normal | n/a |

The display weight is intentionally light (400) with negative letter-spacing — quiet, editorial.

### Spacing & radii

| Token | Value |
|---|---|
| Screen horizontal padding | 24 or 28 px |
| Stack gap                 | 12, 14, 16, 18 px |
| Section gap               | 22–28 px |
| Card radius (large)       | 20–22 px |
| Card radius (medium)      | 14–18 px |
| Avatar tile radius        | 14 px |
| Book cover radius (small) | 6–8 px |
| Pill radius               | 99 px |

Card borders: `1px solid #E8E1D5` on cream surfaces. Dark cards on cream get no border, only shadow.

Shadows are minimal:
- Card: none, just the hair border.
- Floating pill (Samia mic): `0 8px 24px rgba(27,26,23,0.25)`
- Book cover thumbnail: `0 4px 12px rgba(40,30,20,0.18), 0 0 0 1px rgba(0,0,0,0.06)`
- Phone shell (canvas only): `0 30px 60px rgba(40,30,20,0.10), 0 0 0 8px #2a2520, 0 0 0 9px #0e0c0a`

### Iconography

All icons are inline SVG, stroked, **1.4–1.6 px stroke width**, `stroke-linecap="round"`, `stroke-linejoin="round"`. No icon font. The set used:
- chevron-left (back arrow)
- search (circle + tail)
- mic (rounded rect + arc + stem)
- play (triangle, filled)
- pause (two rounded rects, filled)
- skip ±15s (text labels in mono)
- previous/next track (vertical bar + triangle)
- meatballs (3 dots)
- arrow-right (`M1 7h19 m0 0l-6-6 m6 6l-6 6`)

No emoji.

---

## Screens

There are **6 screens** in 2 modules. Routes are organised as a tree:

```
home
├─ audioLib       (Samia · Library)
│   └─ samiaPlay  (Samia · Listening / playback)
└─ signHome       (SignBook · Home)
    └─ signLib    (SignBook · Library)
        └─ signRead (SignBook · Reader)
```

Navigation is a **stack**: forward routes push, the back chevron in the top-left pops. The prototype animates routes horizontally (380 ms `cubic-bezier(0.4, 0, 0.2, 1)`, +/− 100% translateX, slight opacity fade).

### Screen 1 — Home / Module picker (`home`)

**Purpose.** First-launch screen. User chooses a module.

**Layout (top → bottom):**
1. Top row: `Kitab Lil Jamie` (mono eyebrow, ink-muted) on the left, `كتاب للجميع` (Noto Kufi Arabic, muted) on the right.
2. Hero block, 60 px down:
   - H1 "Chaque livre," then on a new line "*pour chacun.*" — the second word/phrase is in `accent` (#B8552D), italic.
   - Subtitle (15 px ink2, max-width 260 px): "Choisissez votre porte d'entrée vers la bibliothèque."
3. Flexbox spacer pushes the two module cards to the bottom (32 px padding-bottom).
4. Two **ModuleCard** components, stacked, 14 px gap:
   - **Card 01 — Samia (primary, dark)**: background `#1B1A17`, text `#F6F2EB`. Layout: mono `01` index · title `Samia` (22 px medium) inline-baseline with tag `· Mal-voyants` (mono, uppercased) · subtitle `Lecture vocale · arabe, français, darija`. Right-side arrow-right icon in `#F6F2EB`.
   - **Card 02 — SignBook (secondary, white)**: `#FFFFFF` bg, `#1B1A17` text, `1px solid #E8E1D5` border. Same internal layout. Tag `· Sourds & malentendants`. Subtitle `Livres en langue des signes marocaine`. Right-side arrow-right icon in `#1B1A17`.

Tapping a card pushes the corresponding module's home route.

### Screen 2 — Samia · Library (`audioLib`)

**Purpose.** Visually-impaired user picks a book to listen to. Touch targets are large; the floating mic pill at the bottom is always present.

**Layout:**
1. Header row: back chevron · centered mono eyebrow `Samia · Bibliothèque` · search icon.
2. H2 (32 px, weight 400, letter-spacing -1): `Que souhaitez-vous écouter ?`
3. Subtitle (14 px, muted): `Touchez un livre, ou dites « Samia, lis-moi… »`
4. List of **4 book rows**, 12 px gap, each row:
   - 56 × 72 px book thumbnail (rounded 6 px) — colored block specific to the book, with the title in 7 px white text bottom-left:
     | Book | Color | Author | Duration | Category | Chapter (Samia's response context) |
     |---|---|---|---|---|---|
     | Le Pain Nu        | `#B8552D` | Mohamed Choukri    | 6h 12min | Roman  | Chapitre trois |
     | L'Enfant de Sable | `#3D5141` | Tahar Ben Jelloun  | 4h 48min | Roman  | Chapitre un |
     | Moroccan Tales    | `#2E3540` | Anthologie         | 2h 30min | Récits | Premier récit |
     | Le Passé Simple   | `#7A4D2B` | Driss Chraïbi      | 7h 05min | Roman  | Première partie |
   - Title (16 px medium) · author (13 px muted) · duration pill (mono 10 px, on `#EDE6D8`) · category (mono 10 px faint)
   - 38 px round play button (terracotta for the first item, ink for the rest). White play glyph.
5. **Floating "Parler à Samia" pill** anchored at `bottom: 28px`, centered. Dark ink background, white text, 99 px radius. Contains a small terracotta circle with a mic icon, then `Parler à Samia` (14 px medium), then `سامية` in Arabic (14 px, opacity 0.7).

Tapping any row, the play button, or the floating pill navigates to `samiaPlay` and **passes the book object as a route param**.

### Screen 3 — Samia · Listening (`samiaPlay`)

**Purpose.** Voice-controlled playback. Dark mode for low-vision contrast.

**Layout** (background `#1B1A17`, text `#F6F2EB`):
1. Header: back chevron (white) · centered mono `En cours · {book.t}` (truncated with ellipsis) · right-side `● écoute` (terracotta dot + mono label).
2. **Waveform** — 28 vertical bars, 3 px wide, 5 px gap, 2 px radius. Heights from a fixed array `[12,18,26,38,52,68,80,94,72,58,46,32,20,28,42,60,76,88,96,82,66,48,30,22,16,24,32,18]`. The first 18 bars are terracotta `#B8552D`; the rest are `rgba(246,242,235,0.25)`. 120 px height, 40 px margin-bottom. In a production build this should react to actual audio amplitude.
3. Mono eyebrow `Vous avez dit`.
4. **Quoted user phrase** (26 px, weight 400, letter-spacing -0.8):
   > « Samia, lis-moi *{book.chapter.toLowerCase()}* de *{book.t}*. »
   The chapter is in terracotta; the book title is in light cream `rgba(246,242,235,0.85)`. The quote marks `«»` are non-breaking-spaced.
5. **Samia response card** — semi-transparent dark surface, 14 px radius, 1 px translucent border. Mono `Samia →` eyebrow + body:
   > D'accord. Je commence {chapter} de {book.t}, en darija. Dites « pause » à tout moment.
6. **Bottom control row** (paddingBottom: 36 px) — flex row, space-between:
   - Previous track icon (48 px ghost button)
   - `−15s` label button (48 px)
   - **Center play/pause button** — 76 px round, terracotta, two-ring outer glow (`0 0 0 8px rgba(184,85,45,0.18), 0 0 0 16px rgba(184,85,45,0.08)`). Two pause bars when playing.
   - `+15s` button
   - Next track button

### Screen 4 — SignBook · Home (`signHome`)

**Purpose.** Entry point for deaf users. Each navigation tile has an animated avatar signing the tile's meaning. Tiles support long-press → enlarged avatar explanation (not implemented in prototype; build as a separate modal).

**Layout:**
1. Header: back chevron · `SignBook` mono eyebrow · 36 px placeholder.
2. Greeting block: H2 `Bonjour Yasmine.` (30 px, weight 400, -0.9 letter-spacing) + subtitle `Appuyez longuement sur une icône — un avatar l'explique en LSM.`
3. **2 × 2 grid of tiles**, 14 px gap, each tile:
   - 110 px square thumbnail with **`<SigningAvatar>`** loop inside. Alternating tile bg `#F1ECE2` / `#EDE6D8`.
   - Bottom row: title (16 px medium) + Arabic translation (12 px, muted, `Noto Kufi Arabic`, RTL).
   - Top-right "LSM" badge — dark pill, mono 9 px.
   - Tiles (in order, with their LSM-explainer avatar variant + Arabic):
     - **Bibliothèque** / كتب — variant `open` (palette `cream`)
     - **Mes lectures** / قراءاتي — variant `heart` (palette `warm`)
     - **Apprendre** / تعلم — variant `spell` (palette `cream`)
     - **Réglages** / إعدادات — variant `point` (palette `warm`)
4. **"Signe du jour" card** — dark ink, full-width, 22 px radius. 54 × 54 dark mini-stage on the left with a `read`-variant avatar in `dark` palette (no glow). Right: mono eyebrow `Signe du jour` + value `« Lire »` (17 px medium). Arrow-right at far right.

Only the **Bibliothèque** tile is interactive in the prototype (taps push `signLib`). The others should open the LSM-explainer overlay in production.

### Screen 5 — SignBook · Library (`signLib`)

**Purpose.** Pick a book to read in LSM.

**Layout:**
1. Header: back chevron · `Bibliothèque · LSM` eyebrow · 36 px placeholder.
2. H2 `Choisissez un livre.` + second line in muted color `L'avatar le racontera.`
3. **Filter chip row** — `Tous` (active, dark fill), `Jeunesse`, `Classique`, `Poésie`, `Récits` — 7 × 12 px padding, 99 px radius, 12 px font, weight 500. Chips are visual only in the prototype.
4. **3 book cards**, 14 px gap, each card a horizontal flex row:
   - 92 × 116 px **BookCover** on the left (8 px radius, light shadow). Cover designs are typographic and unique per book (see "Book covers" below). A 24 px terracotta-tinted dark play dot is overlaid bottom-right.
   - Right column: title (16 px medium) · author (13 px muted) · category pill + chapter-count mono · **"Lire en LSM →" button** (dark ink, white text, 99 px pill, 12 px font, 7×14 padding, self-aligned to flex-start).

Books:
| Book | Author | Tag | Chapters | Reader avatar variant | Reader palette |
|---|---|---|---|---|---|
| Le Petit Prince  | Antoine de Saint-Exupéry | Jeunesse  | 12 chap. | `wave`  | `cream` |
| Hayy Ibn Yaqdhan | Ibn Tufayl               | Classique | 8 chap.  | `think` | `warm` |
| Souffles         | Abdellatif Laâbi         | Poésie    | 24 poèmes| `poem`  | `cool` |

Tapping a card pushes `signRead` and passes the full book object (with its excerpt + variant).

### Screen 6 — SignBook · Reader (`signRead`)

**Purpose.** Read the book paragraph-by-paragraph with synchronised LSM avatar.

**Layout:**
1. Header: back chevron · left-aligned group containing a small 26 × 34 px book-cover thumbnail (3 px radius) + a 2-line block (`En lecture` mono + book title) · meatballs menu on the right.
2. **Avatar stage** — full-width, 340 px tall, 22 px radius. Background gradient `linear-gradient(180deg, #ECE5D6 0%, #DACDB1 100%)`. Top-left `● AVATAR 3D · LSM` badge (dark pill, mono). Top-right `0.8×` speed pill. Centered `<SigningAvatar>` using the book's variant + palette.
3. **Current paragraph** block (flex-grow):
   - Mono eyebrow with `{book.chapter}` (uppercased).
   - Paragraph styled as 3-span: `pre` text in `faint` color, `hi` (the word currently being signed) wrapped in `accentSoft` background pill, `post` text in `faint`. 16 px, line-height 1.55, `text-wrap: pretty`.
4. **Progress + transport** (paddingBottom 28 px):
   - 3 px progress bar, hair-color track, accent fill. The prototype hard-codes 34%.
   - Row: `04:12` mono · previous (36 px ghost) · 52 px ink play/pause · next (36 px ghost) · `12:48` mono.

Book excerpts (truncated for brevity — re-use the prototype's data as-is):

- **Le Petit Prince** — `Chapitre 1 · paragraphe 3` · "Lorsque j'avais six ans j'ai vu, une fois, **[une magnifique image]**, dans un livre sur la forêt vierge…"
- **Hayy Ibn Yaqdhan** — `Prologue · paragraphe 1` · "Nos pieux ancêtres … racontent qu'il existe, parmi les îles de l'Inde, **[une île déserte]** placée sous l'équateur…"
- **Souffles** — `Poème · « Race »` · "Je suis né d'une terre qui ne connaît pas ses frontières, **[fils du vent]** et de l'orange amère…"

The bracketed `[…]` portion is the `hi` span — the word the avatar is currently signing. In a production build this should advance with the avatar's animation.

---

## The animated avatar

`signing-avatar.jsx` defines `<SigningAvatar variant palette delay glow showLabel label />`. It renders an inline SVG of a stylised seated/standing figure (head, torso, two jointed arms) and animates the shoulder + elbow rotations using SMIL `<animateTransform type="rotate">`. Both arms loop on the same duration with eased keyframes. The head also has a tiny vertical bob.

### Variants

Each variant is a set of keyframe rotations for the four joints (`shoulderL`, `shoulderR`, `elbowL`, `elbowR`). Use these as motion intent — when re-implementing in the target codebase consider either:
- **Lottie** files produced from After Effects (high fidelity, designer-controlled).
- **Native skeletal animation** (e.g. `react-native-reanimated` with rotation drivers on a jointed `<Svg>`).
- **Pre-rendered MP4 / WebM** loops with transparent background.

| Variant | Loop dur | Motion intent | Used by |
|---|---|---|---|
| `open`  | 2.8 s | Both arms open outward — "opening a book" | SignBook Home tile #1 (Bibliothèque), Reader fallback |
| `heart` | 3.2 s | Left hand to chest, right hand small | Home tile #2 (Mes lectures) |
| `spell` | 1.6 s | Both hands quick finger-spelling near chest | Home tile #3 (Apprendre) |
| `point` | 3.0 s | Right hand sweeps, left still — "adjust / point" | Home tile #4 (Réglages) |
| `read`  | 2.6 s | Both hands cradle a book | "Signe du jour" mini |
| `wave`  | 2.0 s | Big right-hand wave | Reader · Le Petit Prince |
| `think` | 3.4 s | Right hand to chin, slow | Reader · Hayy Ibn Yaqdhan |
| `poem`  | 4.0 s | Both arms wide and slow sweep | Reader · Souffles |

### Palettes

`SIGN_PALETTES` defines bg/glow/skin/cloth/shadow per palette:
- `cream` — bg `#ECE5D6`, glow `#B8552D`, skin `#9A6E4A`, cloth `#1B1A17`
- `warm` — bg `#E8DEC8`, glow `#B8552D`, skin `#A4754E`, cloth `#2A211A`
- `cool` — bg `#DFDDD2`, glow `#5B6E5A`, skin `#8A6648`, cloth `#1B1A17`
- `dusk` — bg `#3A342D`, glow `#B8552D`, skin `#B98A66`, cloth `#0E0C0A`
- `dark` — bg `#1B1A17`, glow `#B8552D`, skin `#B98A66`, cloth `#0E0C0A`

A radial accent-tinted glow (`radial-gradient(ellipse at 50% 78%, {glow}22 0%, transparent 60%)`) is layered under the figure unless `glow={false}`.

### Joints (SVG coordinate space, `viewBox 0 0 160 240`)

- Left shoulder pivot: `(50, 88)` — `transform-origin` for `shoulderL`
- Right shoulder pivot: `(110, 88)`
- Left elbow pivot: `(50, 130)` — relative to the unrotated parent
- Right elbow pivot: `(110, 130)`

Each shoulder group rotates the whole arm (upper arm + nested elbow group). The elbow group is nested inside the shoulder group, so its rotation composes with the shoulder rotation. Forearm thickness 18 px stroke, upper arm 22 px, drawn as `<line>` with `stroke-linecap="round"`. Hand is an 11 px circle with a small 4 px finger stub below.

A bottom ellipse `(80, 222) rx=38 ry=5` acts as a ground shadow, filtered by `drop-shadow`.

---

## Book covers

`book-covers.jsx` defines `<BookCover book size="lg|sm" />`. Each book has a dedicated render function. All covers are **original typographic designs**, not reproductions of any publisher's artwork — the brief deliberately avoids copyright issues. The developer can later swap any of these for officially-licensed cover artwork by replacing the corresponding renderer.

| Book id | Design |
|---|---|
| `prince` | Gradient `linear-gradient(180deg, #1A3454 0%, #2A4D74 55%, #6B5A8F 80%, #C28B4E 100%)` (night-sky to dawn-horizon). Cream `#F4E9C1` text. Five small stars at fixed positions. A 48 px planet (terracotta circle + faded ellipse ring) with a tiny stick-figure on top at 38% vertical. Title bottom-left, italic, two lines: "Le Petit / Prince". Author below in mono. |
| `hayy`   | Gradient `linear-gradient(160deg, #E4CFA8 0%, #C7A074 55%, #9C7045 100%)`. Ink `#2A1A0A` text. A 54 px Moroccan geometric motif at 18% top: nested rotated squares + crossing axes + center dot. Behind the title, the Arabic `حي بن يقظان` at 54% in Noto Kufi Arabic, 60% opacity. Title bottom-left "Hayy Ibn / Yaqdhan". Author: "Ibn Tufayl · XIIᵉ s." |
| `souffles` | Solid burgundy `#7A1925`. Cream `#F4ECD8` text. Four wavy SVG paths drawn as a quiet pattern at 45% opacity. A horizontal hairline at 30% vertical. Top mono: "Nº 01 · 1966". Bottom title: lowercase italic `souffles` at 22 px, weight 600. Author "A. Laâbi" mono. |
| `default` | Cream block with title + author in standard styling. Fallback. |

Both `lg` and `sm` sizes are supported via a `scale` factor (0.55 for `sm`).

---

## Interactions & behavior

### Navigation

- Stack-based router (push/pop). Each route can carry a `params` object — used for the selected book on `samiaPlay` and `signRead`.
- Routes: see the tree at the top of the "Screens" section.
- Animation: 380 ms slide, `cubic-bezier(0.4, 0, 0.2, 1)`. Forward = new screen slides in from the right (translateX 100% → 0); back = it slides in from the left. The outgoing screen mirror-slides off.
- During the transition, both screens are mounted; after `420` ms they collapse to just the current screen. (A few ms of buffer beyond the CSS transition prevents flicker.)
- A "↺ Recommencer" affordance resets the stack to `[home]`.

### Tap targets

- All cards, buttons, and tiles are tappable surfaces with `cursor: pointer; user-select: none`.
- All controls assume ≥ 44 px hit target (book row play buttons are 38 px in the design, but the entire row is tappable — the button itself stops propagation).

### Voice / accessibility (Samia)

Voice input is **not** implemented in the prototype. In production, the "Parler à Samia" pill on `audioLib` should open the mic flow. The "samiaPlay" screen mock illustrates the intended dialog: a literal echo of the user's phrase + Samia's confirmation. The waveform should react to mic level in input mode and to playback level in playing mode.

### LSM avatar advance

The reader screen statically highlights one word (`book.excerpt.hi`). In production the highlighted span should sync with the avatar's animation — either driven by frame markers on the Lottie/MP4 or by paragraph timing. The 34% progress bar is hard-coded.

### Long-press to explain (SignBook)

Tiles on `signHome` advertise "Appuyez longuement sur une icône — un avatar l'explique en LSM." The interaction itself is **not** implemented in the prototype. Build it as a bottom-sheet/full-screen modal containing an enlarged version of that tile's `<SigningAvatar>` with optional caption.

### Tap-priority rule (audio library)

On the audio library row, tapping the row OR the play button both go to `samiaPlay`. The button's `onClick` uses `e.stopPropagation()` to avoid the wrapper handler running twice — preserve this behaviour.

---

## State management

The prototype uses one local React state:
- `stack: Array<{ id: string, params: object }>` — the navigation stack.
- `transitioning: { from, to, dir } | null` — drives the cross-fade.

In production this should be replaced by the platform's router (React Navigation, SwiftUI `NavigationStack`, Flutter `Navigator 2.0`, etc.). The `params` object flows through to the destination screen — Samia's playing screen and the SignBook reader both read `nav.params.book`.

No global state, no auth, no data fetching is shown. The book catalogue is hard-coded in `screens.jsx` (`S2_AudioLibrary` and `S5_SignLibrary`). In production this should come from a backend or local DB.

---

## Localisation

Copy is **French** with **Arabic** secondary labels where shown:

| FR | AR |
|---|---|
| Kitab Lil Jamie | كتاب للجميع |
| Bibliothèque | كتب |
| Mes lectures | قراءاتي |
| Apprendre | تعلم |
| Réglages | إعدادات |
| Samia | سامية |

Arabic uses `direction: rtl` and Noto Kufi Arabic. The app should support full RTL layouts when Arabic is the primary language (not implemented in the prototype — the prototype always displays French as the primary direction).

Voice assistant supports French, classical Arabic, and **Darija** (Moroccan Arabic). The "Samia" voice-listening screen explicitly mentions Darija.

---

## Accessibility commitments

This app is **for** users with disabilities — accessibility is the product, not a checkbox. Notes for the developer:

- **Voice control** (Samia module): every action reachable by speech. Screen reader (VoiceOver/TalkBack) labels on all touch targets.
- **High-contrast / large-text modes**: type scale should be a setting, not fixed. The visible 16–32 px body sizes in the prototype are the default; users must be able to increase.
- **Touch targets ≥ 44 × 44 px**.
- **Avatar contrast**: the LSM avatar must be readable against its stage in any palette. The default stage gradient + drop-shadow give clear silhouette legibility.
- **No emoji** anywhere (some screen readers handle them inconsistently).
- **Reduced-motion**: SigningAvatar animations should pause / degrade to a static pose when `prefers-reduced-motion: reduce`. Currently the prototype always animates.

---

## Files in this bundle

```
prototype/
├── KitabLilJamie.html                   ← interactive prototype (main entry)
├── KitabLilJamie v1 (overview).html     ← original 6-screen flat overview (canvas)
├── screens.jsx                          ← all 6 screens
├── signing-avatar.jsx                   ← <SigningAvatar> component + variants + palettes
├── book-covers.jsx                      ← <BookCover> with per-book renderers
└── design-canvas.jsx                    ← used only by the v1 overview file
```

Open `KitabLilJamie.html` in any modern browser. The Babel transform is in-page, no build step.

---

## Out of scope (mentioned in pitch but **not** designed)

- **Module 03 · Braille+IA** — photo-to-Braille OCR pipeline. Not designed.
- **Onboarding flow** — first-launch language/accessibility chooser.
- **Authentication / accounts**.
- **Book ingestion / upload** for librarians or content partners.
- **Settings screens** beyond the placeholder tile.
- **Offline behaviour** for users without internet.
- **Real LSM lexicon** — the avatar's eight variants are motion intent, not actual signed words.

The developer should flag any of these to the design team before implementation work begins.
