# Design Principles Reference

Extended guidelines for creating distinctive, production-quality frontend designs.

## Anti-Patterns to Avoid

### "AI Slop" Characteristics

These patterns immediately signal low-effort, AI-generated design:

**Typography**
- Inter, Roboto, or Arial as primary fonts
- System font stack without intentionality
- Inconsistent font weights
- Poor line-height (too tight or too loose)

**Colors**
- Purple-to-blue gradients on white backgrounds
- Oversaturated accent colors
- No defined neutral scale
- Colors that don't relate to each other

**Layout**
- Perfectly symmetrical card grids
- Generic hero sections with centered text
- Predictable three-column features
- No visual hierarchy

**Components**
- Rounded corners on everything
- Drop shadows on every element
- Gradient buttons with white text
- Generic icon libraries without curation

## Aesthetic Directions

### Minimalist

**Philosophy**: Maximum impact through reduction

```
Typography: Single font family, limited weights
Colors: 2-3 colors maximum, generous neutrals
Spacing: Oversized margins, breathing room
Components: Stripped-down, essential elements only
Motion: Subtle, almost imperceptible
```

**Good for**: Professional services, luxury brands, portfolios

### Maximalist

**Philosophy**: Rich, layered visual experience

```
Typography: Multiple fonts with distinct personalities
Colors: Bold, saturated palette with accent pops
Spacing: Layered elements, overlapping sections
Components: Detailed, textured, elaborate
Motion: Dramatic entrances, complex transitions
```

**Good for**: Creative agencies, entertainment, fashion

### Brutalist

**Philosophy**: Raw honesty, unconventional layouts

```
Typography: Monospace or industrial fonts, extreme sizes
Colors: High contrast, often black/white with single accent
Spacing: Unconventional grids, broken alignment
Components: Exposed structure, raw elements
Motion: Abrupt, intentionally jarring
```

**Good for**: Avant-garde brands, tech startups, art

### Retro-Futuristic

**Philosophy**: Nostalgic optimism meets modern execution

```
Typography: Geometric sans-serifs, custom display fonts
Colors: Neon accents, dark backgrounds, chrome effects
Spacing: Asymmetric, dynamic compositions
Components: Rounded forms, glow effects, gradients (done right)
Motion: Smooth, futuristic transitions
```

**Good for**: Gaming, technology, entertainment

### Organic

**Philosophy**: Natural, flowing, human-centered

```
Typography: Soft serifs, handwritten accents
Colors: Earth tones, muted palette, natural gradients
Spacing: Flowing layouts, curved sections
Components: Soft edges, natural shapes, texture
Motion: Gentle, flowing animations
```

**Good for**: Wellness, sustainability, food & beverage

## Typography Deep Dive

### Font Pairing Strategies

**Contrast Pairing**: Different classifications
- Serif headlines + Sans-serif body
- Display font + Neutral text font
- Example: Playfair Display + Source Sans Pro

**Superfamily Pairing**: Same family, different styles
- Roboto + Roboto Slab
- IBM Plex Sans + IBM Plex Serif
- Works when you need subtle distinction

**Mood Pairing**: Same emotional quality
- Two geometric sans-serifs
- Two humanist fonts
- Creates cohesion, requires size/weight contrast

### Type Scale Systems

**Musical Scale (1.25 ratio)**:
```
xs: 0.64rem   (10px)
sm: 0.8rem   (13px)
base: 1rem    (16px)
lg: 1.25rem  (20px)
xl: 1.563rem (25px)
2xl: 1.953rem (31px)
3xl: 2.441rem (39px)
4xl: 3.052rem (49px)
```

**Fibonacci-inspired (1.618 ratio)**:
```
sm: 0.618rem
base: 1rem
lg: 1.618rem
xl: 2.618rem
2xl: 4.236rem
```

### Line Height Guidelines

| Text Type | Line Height |
|-----------|-------------|
| Headlines | 1.1 - 1.2 |
| Subheadlines | 1.2 - 1.3 |
| Body copy | 1.5 - 1.7 |
| UI text | 1.3 - 1.5 |
| Captions | 1.4 - 1.5 |

## Color System Architecture

### Building a Palette

**Step 1: Choose Primary**
- Should reflect brand personality
- Test at different tints/shades
- Ensure accessibility at key values

**Step 2: Choose Secondary**
- Complement or contrast primary
- Different hue for visual interest
- Used for accents, CTAs, highlights

**Step 3: Define Semantic Colors**
```css
--color-success: #10B981;  /* Green - positive actions */
--color-warning: #F59E0B;  /* Amber - caution states */
--color-error: #EF4444;    /* Red - errors, destructive */
--color-info: #3B82F6;     /* Blue - informational */
```

**Step 4: Build Neutral Scale**
```css
/* 10 steps from near-white to near-black */
--neutral-50: #FAFAFA;
--neutral-100: #F5F5F5;
--neutral-200: #E5E5E5;
--neutral-300: #D4D4D4;
--neutral-400: #A3A3A3;
--neutral-500: #737373;
--neutral-600: #525252;
--neutral-700: #404040;
--neutral-800: #262626;
--neutral-900: #171717;
```

### Color Accessibility

**WCAG Contrast Ratios**:
- **AA Large Text**: 3:1 minimum
- **AA Normal Text**: 4.5:1 minimum
- **AAA Large Text**: 4.5:1 minimum
- **AAA Normal Text**: 7:1 minimum

**Testing Tools**:
- WebAIM Contrast Checker
- Stark (Figma plugin)
- axe DevTools

## Motion Design

### Timing Functions

**Standard Easing** (Material Design):
```css
--ease-standard: cubic-bezier(0.4, 0.0, 0.2, 1);
--ease-decelerate: cubic-bezier(0.0, 0.0, 0.2, 1);
--ease-accelerate: cubic-bezier(0.4, 0.0, 1, 1);
```

**Playful Easing**:
```css
--ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);
--ease-elastic: cubic-bezier(0.175, 0.885, 0.32, 1.275);
```

### Duration Scale

```css
--duration-instant: 0ms;     /* State changes */
--duration-quick: 100ms;     /* Micro-interactions */
--duration-fast: 150ms;      /* Small transitions */
--duration-normal: 250ms;    /* Standard transitions */
--duration-slow: 400ms;      /* Complex transitions */
--duration-slower: 700ms;    /* Page transitions */
```

### Animation Patterns

**Enter Animations**:
- Fade in + slight upward movement
- Scale from 0.95 to 1.0
- Slide in from direction of origin

**Exit Animations**:
- Fade out (faster than enter)
- Scale down slightly
- Slide toward destination

**Reduced Motion**:
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Component Patterns

### Button Hierarchy

```
Primary: Solid background, high contrast
Secondary: Outlined or subtle background
Tertiary/Ghost: Text only, minimal chrome
Destructive: Red tones, clear warning
```

### Input States

```
Default: Subtle border, clear affordance
Hover: Slightly darker border
Focus: Ring or border highlight, clear
Filled: Indicates content present
Error: Red border + error message
Disabled: Reduced opacity, no interaction
```

### Card Patterns

```
Elevated: Box shadow, floats above surface
Outlined: Border, same level as surface
Filled: Background color, grouped content
Interactive: Hover state, cursor pointer
```

## Responsive Design

### Breakpoint Strategy

**Mobile-First Approach**:
```css
/* Base styles for mobile */
.component { ... }

/* Tablet and up */
@media (min-width: 768px) { ... }

/* Desktop and up */
@media (min-width: 1024px) { ... }

/* Large desktop */
@media (min-width: 1280px) { ... }
```

### Common Breakpoints

| Name | Width | Target |
|------|-------|--------|
| sm | 640px | Large phones |
| md | 768px | Tablets |
| lg | 1024px | Laptops |
| xl | 1280px | Desktops |
| 2xl | 1536px | Large screens |

## Accessibility Checklist

### Visual
- [ ] Color contrast meets WCAG AA (4.5:1)
- [ ] Text is resizable to 200%
- [ ] Focus indicators visible
- [ ] No color-only information

### Keyboard
- [ ] All interactive elements focusable
- [ ] Logical focus order
- [ ] No keyboard traps
- [ ] Skip links for navigation

### Screen Reader
- [ ] Semantic HTML structure
- [ ] ARIA labels where needed
- [ ] Alt text for images
- [ ] Form labels associated

### Cognitive
- [ ] Clear visual hierarchy
- [ ] Consistent navigation
- [ ] Error messages helpful
- [ ] No auto-playing media
