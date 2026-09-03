---
name: Premium Residential Valet
colors:
  surface: '#fcf8ff'
  surface-dim: '#dbd8e5'
  surface-bright: '#fcf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f2ff'
  surface-container: '#efecf9'
  surface-container-high: '#e9e6f3'
  surface-container-highest: '#e4e1ee'
  on-surface: '#1b1b24'
  on-surface-variant: '#44474e'
  inverse-surface: '#302f39'
  inverse-on-surface: '#f2effc'
  outline: '#75777e'
  outline-variant: '#c5c6cf'
  surface-tint: '#4e5e80'
  primary: '#031634'
  on-primary: '#ffffff'
  primary-container: '#1a2b4a'
  on-primary-container: '#8293b7'
  inverse-primary: '#b6c6ee'
  secondary: '#835500'
  on-secondary: '#ffffff'
  secondary-container: '#feae2c'
  on-secondary-container: '#6b4500'
  tertiary: '#221400'
  on-tertiary: '#ffffff'
  tertiary-container: '#3d2700'
  on-tertiary-container: '#af8d5b'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#b6c6ee'
  on-primary-fixed: '#081b39'
  on-primary-fixed-variant: '#364767'
  secondary-fixed: '#ffddb4'
  secondary-fixed-dim: '#ffb954'
  on-secondary-fixed: '#291800'
  on-secondary-fixed-variant: '#633f00'
  tertiary-fixed: '#ffddaf'
  tertiary-fixed-dim: '#e7c18a'
  on-tertiary-fixed: '#281800'
  on-tertiary-fixed-variant: '#5c4217'
  background: '#fcf8ff'
  on-background: '#1b1b24'
  surface-variant: '#e4e1ee'
  action-text: '#6B4500'
  surface-white: '#FFFFFF'
  lavender-haze: '#F5F2FF'
typography:
  display-bold:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-h1:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-h1-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-h2:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: '1.3'
  headline-h3:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: '1.4'
  body-main:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-strong:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: '1.6'
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-max: 1200px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style

The brand identity is centered on the concept of "The Extended Closet"—a premium, domestic-focused valet service that feels like a natural extension of a high-end Cape Town residence. It avoids the cold, industrial aesthetic of traditional self-storage in favor of a warm, sophisticated, and highly trustworthy experience.

The design style is **Corporate / Modern** with a **Tactile** edge. It utilizes generous whitespace, soft lavender-tinted foundations, and crisp white surfaces to create a sense of cleanliness and organization. The visual language evokes the feeling of a concierge service rather than a warehouse operation, emphasizing security through "Navy" depth and accessibility through "Amber" highlights.

## Colors

The palette is anchored by **Navy (#1A2B4A)**, used to establish authority, security, and professional trust. It serves as the primary brand color for logos, headers, and primary navigation elements.

**Amber (#FEAE2C)** is the high-energy functional color, reserved exclusively for primary actions, call-to-action buttons, and critical highlights. To ensure maximum legibility and a premium feel, Amber elements utilize **Dark Amber (#6B4500)** for text and iconography instead of pure black or white.

The background strategy uses **Lavender-tinted White (#F5F2FF)** for page-level backgrounds to provide a soft, domestic warmth, while **Pure White (#FFFFFF)** is used for content cards and foreground containers to create a "lifted" and organized appearance.

## Typography

This design system exclusively employs **Inter** to maintain a clean, modern, and highly legible interface. The typographic hierarchy is designed to feel structured yet approachable.

- **Display & Headlines:** Use Bold weights (700) for high-level marketing statements. Tighten letter spacing slightly on larger sizes to maintain a premium, editorial feel.
- **Body Text:** Standardized at 16px with a generous 1.6 line height to ensure readability across all demographics.
- **Labels:** Small, uppercase labels are used for category tags or "step" indicators to provide a functional layer without cluttering the visual field.

## Layout & Spacing

The layout follows a **Fixed Grid** philosophy on desktop to maintain a contained, boutique feel. The content is centered within a 1200px container.

- **Grid:** A 12-column grid is used for desktop, transitioning to a single-column stack on mobile. 
- **Rhythm:** An 8px base unit governs all padding and margins. Vertical section spacing should be generous (80px–120px on desktop) to evoke a sense of "luxury space."
- **Surfaces:** Use the "Lavender Haze" for the outer canvas and "Pure White" for content blocks to define structure without needing heavy lines.

## Elevation & Depth

Hierarchy is achieved through **Tonal Layering** and **Ambient Shadows**. 

1.  **Level 0 (Canvas):** The lavender-tinted background (#F5F2FF).
2.  **Level 1 (Cards):** Pure white surfaces (#FFFFFF) featuring a very soft, diffused shadow (0px 4px 20px, 4% opacity Navy) to suggest they are sitting just above the canvas.
3.  **Level 2 (Interactive):** Hover states on cards or buttons increase the shadow spread and slightly shift the Y-offset to provide tactile feedback.

Avoid heavy borders; use subtle 1px "Navy" strokes at 10% opacity only when necessary to define boundaries between two white elements.

## Shapes

The shape language is sophisticated and modern, using specific radii to differentiate between structural elements and interactive controls.

- **Cards/Containers:** A 12px corner radius is the standard for all content modules, providing a soft, approachable domestic feel.
- **Buttons:** An 8px corner radius is used to give actions a slightly more precise, "tool-like" appearance compared to the softer containers.
- **Chips/Badges:** These are always full-pill shaped, signifying they are metadata or secondary interactive elements.

## Components

- **Buttons:** Primary buttons use the Amber (#FEAE2C) fill with Dark Amber (#6B4500) text. The height should be a substantial 48px or 56px to feel premium. Secondary buttons use a Navy outline with Navy text.
- **Input Fields:** Use white backgrounds with an 8px radius. The border should be a subtle 1px stroke of Navy at 15% opacity, turning to full-strength Amber on focus.
- **Cards:** White containers with a 12px radius. Internal padding should be at least 32px to maintain a high-end feel.
- **Chips:** Full-pill shaped. Use Navy backgrounds with White text for "Status" and light Lavender backgrounds with Navy text for "Categories."
- **Valet-Specific UI:** Progress indicators for storage pickups should use Navy tracks with Amber active states to emphasize movement and completion.