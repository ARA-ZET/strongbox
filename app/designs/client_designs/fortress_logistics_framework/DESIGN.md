---
name: Fortress Logistics Framework
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
  tertiary: '#231300'
  on-tertiary: '#ffffff'
  tertiary-container: '#3e2600'
  on-tertiary-container: '#ba8943'
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
  tertiary-fixed: '#ffddb3'
  tertiary-fixed-dim: '#f4bd71'
  on-tertiary-fixed: '#291800'
  on-tertiary-fixed-variant: '#633f00'
  background: '#fcf8ff'
  on-background: '#1b1b24'
  surface-variant: '#e4e1ee'
typography:
  display:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  title:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  label:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  body:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  display-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  desktop-padding: 24px
  mobile-padding: 16px
  gutter: 16px
  component-gap: 8px
  section-gap: 32px
---

## Brand & Style
The design system for this logistics management application is built on the pillars of **security, precision, and reliability**. The brand personality is authoritative yet accessible, designed to instill confidence in users managing high-value storage and complex inventory.

The visual style is **Corporate / Modern**, emphasizing clarity and structural integrity. It utilizes a clean, systematic layout with intentional use of color to signal status and action. The interface avoids unnecessary decorative elements, focusing instead on high information density that remains readable and professional. The aesthetic response should feel stable—like a digital vault—utilizing a "Safe-to-Touch" philosophy where interactive elements are clearly defined and critical data is prioritized.

## Colors
This design system employs a high-contrast palette to differentiate between organizational structure and operational action. 

- **Primary Navy** is reserved for structural permanence: navigation bars, headers, and primary branding. It represents the "StrongBox" itself—unmoving and secure.
- **Amber & Amber Dark** serve as the functional pulse of the UI. They are used exclusively for interactive elements, primary call-to-actions, and reflecting "active" or "in-progress" states.
- **The Neutral Foundation** utilizes a cool-toned lilac-grey background (`#F5F2FF`) to reduce eye strain while maintaining a sterile, professional atmosphere. Surfaces and containers use subtle shifts in value to create hierarchy without relying on heavy borders.
- **Semantic Logic** follows a strict background-tint-to-text-contrast ratio to ensure status chips are instantly recognizable for international logistics standards.

## Typography
**Inter** is the sole typeface, chosen for its exceptional legibility in data-heavy environments. The system uses a disciplined scale to ensure information hierarchy is clear even in complex inventory lists.

- **Display & Headline:** Used for page titles and section headers. Bold weights provide the necessary "weight" to anchor the page.
- **Title & Label:** Used for card titles, form labels, and interactive components. The semi-bold and medium weights differentiate them from static body text.
- **Body & Caption:** Optimized for readability in tables and logs. 
- **Icons:** Use **Material Symbols Outlined** at a standard 20px or 24px size to maintain a lightweight, professional look that doesn't compete with text.

## Layout & Spacing
The layout follows a **Fluid Grid** model with strict margin constraints to ensure the application feels organized across all device types.

- **Desktop:** Utilizes a 12-column grid. Main content areas use 24px padding. The top navigation is fixed at 64px height.
- **Mobile:** Switches to a 4-column grid. Side margins are reduced to 16px to maximize screen real estate for data tables and lists.
- **Rhythm:** An 8px base unit governs all spatial relationships. Elements should be spaced in increments of 8px (8, 16, 24, 32, 48) to maintain vertical rhythm.

## Elevation & Depth
This design system uses a **Tonal Layering** approach combined with **Ambient Shadows** to define hierarchy.

- **Level 0 (Background):** `#F5F2FF` - The lowest layer.
- **Level 1 (Surface):** `#FFFFFF` - Used for primary cards and white-space sections. Elevated by a soft ambient shadow: `0 2px 8px rgba(0,0,0,0.08)`.
- **Level 2 (Containers):** `#EFECFF` - Used for nested elements like input fields, secondary list items, or subtle sidebar backgrounds. This is a "sunken" elevation created by color rather than shadow.
- **Interactive States:** Buttons and active cards may use a slightly deeper shadow on hover to indicate tactility.

## Shapes
The shape language balances modern approachability with industrial precision.

- **Cards:** 12px (`rounded-lg`) corner radius for a soft but structured look.
- **Buttons & Inputs:** 8px (`rounded-md`) radius. This sharper radius communicates a more "tool-like" and professional feel than fully rounded corners.
- **Status Chips:** Full pill (`rounded-full`) radius. This distinct shape allows status indicators to stand out instantly against the rectangular geometry of cards and tables.

## Components

### Shell & Navigation
- **Desktop Top Nav:** 64px height, Surface White (`#FFFFFF`). Features the "StrongBox" logo in Navy Bold with an Amber box icon. Active links are indicated by a 3px Amber bottom border.
- **Mobile Navigation:** Bottom bar for primary destinations using Amber for active icon/label states. Top AppBar remains white for consistent branding.

### Buttons & Actions
- **Primary:** Navy background with White text. Use 8px radius.
- **Secondary/Action:** Amber background with Black/Navy text for high visibility.
- **Ghost:** Border-only or text-only, used for less critical actions like "Cancel" or "Export".

### Status Chips
- **Design:** Full pill shape, Medium weight text, 14px size.
- **States:** 
  - `inStorage`: Success palette (Green).
  - `inTransit`: Amber palette.
  - `pendingPickup`: Pending/Neutral palette (Grey).
  - `alert/delayed`: Warning/Error palettes.

### Data Display
- **Cards:** White background, 12px radius, 1px Border (`#C5C6CF`), and the 8px blur shadow.
- **Input Fields:** Filled style using Surface Container (`#EFECFF`), 8px radius, with a 1px bottom border that turns Amber on focus.
- **Lists:** Clean rows with 16px vertical padding, separated by 1px Border lines. Use Text Primary for titles and Text Secondary for metadata.