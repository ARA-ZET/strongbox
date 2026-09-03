---
name: Logistics Operations System
colors:
  surface: '#fcf8ff'
  surface-dim: '#dad7f3'
  surface-bright: '#fcf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f2ff'
  surface-container: '#efecff'
  surface-container-high: '#e8e5ff'
  surface-container-highest: '#e2e0fc'
  on-surface: '#1a1a2e'
  on-surface-variant: '#44474e'
  inverse-surface: '#2f2e43'
  inverse-on-surface: '#f2efff'
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
  tertiary: '#001c09'
  on-tertiary: '#ffffff'
  tertiary-container: '#003316'
  on-tertiary-container: '#00a858'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#b6c6ee'
  on-primary-fixed: '#081b39'
  on-primary-fixed-variant: '#364767'
  secondary-fixed: '#ffddb4'
  secondary-fixed-dim: '#ffb955'
  on-secondary-fixed: '#291800'
  on-secondary-fixed-variant: '#633f00'
  tertiary-fixed: '#6bfe9c'
  tertiary-fixed-dim: '#4ae183'
  on-tertiary-fixed: '#00210c'
  on-tertiary-fixed-variant: '#005228'
  background: '#fcf8ff'
  on-background: '#1a1a2e'
  surface-variant: '#e2e0fc'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  3xl: 64px
  gutter: 16px
  margin: 24px
---

## Brand & Style
The design system is engineered for high-efficiency logistics and asset management. It balances a **Corporate Modern** aesthetic with a functional, operational edge, ensuring that the interface remains legible under various lighting conditions—from bright office environments to the glare of a driver's tablet in the field.

The brand personality is **authoritative yet accessible**. It communicates "reliability" through deep navies and "urgency" through high-visibility amber accents. The style utilizes clean lines, generous whitespace, and subtle depth to guide the user’s eye toward critical operational data and call-to-action triggers like QR scanning and shipment confirmation.

## Colors
The palette is rooted in a high-contrast foundation to support accessibility and quick information processing. 

- **Primary Navy:** Used for structural elements like sidebars, headers, and primary branding to instill a sense of security and establishment.
- **Accent Amber:** Reserved strictly for "Action" elements—buttons that move a process forward, QR code highlights, and critical status updates.
- **Surface Strategy:** The light-grey background (#F7F9FC) provides a soft canvas that allows pure white cards to "pop," creating a clear hierarchy of information containers.
- **Semantic Colors:** Success, Warning, and Danger colors follow standard logistics conventions to ensure drivers and operators can react to status changes without reading text.

## Typography
This design system utilizes **Inter** for its exceptional legibility and neutral, systematic tone. 

- **Headlines:** Use Bold (700) or SemiBold (600) weights to establish clear section breaks and page titles.
- **Body Text:** Use Regular (400) for all descriptive content to ensure maximum readability during long-form data entry or manifest review.
- **Labels:** Use Medium (500) or SemiBold (600) at smaller sizes for form labels, table headers, and status badges to maintain distinction from body content.
- **Mobile Scaling:** Large headlines scale down on mobile devices to prevent excessive line-breaking, ensuring that shipment IDs and tracking numbers remain on a single line where possible.

## Layout & Spacing
The layout follows a **Fluid Grid** model with fixed maximum widths for desktop reading comfort. 

- **Grid System:** A 12-column grid is used for desktop (1280px+), transitioning to an 8-column grid for tablets, and a 4-column grid for mobile.
- **The 4px Rule:** All spacing (padding, margins, gutters) must be a multiple of 4px. This ensures a mathematical harmony across the UI.
- **Operational Density:** In dashboard views, use `md` (16px) spacing for internal card padding to maximize data density. For marketing or landing pages, increase to `lg` (24px) for a more premium, airy feel.
- **Safe Areas:** On mobile, ensure a minimum horizontal margin of 16px to prevent content from hitting the edge of the device frame.

## Elevation & Depth
Depth is used functionally to indicate interactivity and "stacking" of information.

- **Level 0 (Flat):** The main application background.
- **Level 1 (Surface):** Standard cards and containers. These use a subtle ambient shadow: `0 2px 8px rgba(0,0,0,0.08)`.
- **Level 2 (Hover/Active):** Interactive elements that are lifted. Use a slightly more pronounced shadow: `0 4px 12px rgba(0,0,0,0.12)`.
- **Overlays:** Modals and dropdowns use a high-depth shadow to clearly separate the temporary UI from the underlying operational data.
- **Tonal Separation:** Use 1px borders (#E5E7EB) in conjunction with shadows to maintain structure even when shadows are less visible on certain screen types.

## Shapes
The shape language is "Soft-Modern," utilizing rounded corners to make the professional environment feel approachable and reduce visual fatigue.

- **Standard Radius:** 8px (`rounded-md`) for buttons, input fields, and small UI components.
- **Container Radius:** 12px (`rounded-lg`) for cards and primary content modules.
- **Pill Radius:** Used exclusively for status badges (e.g., "In Transit", "Delivered") to differentiate them from interactive buttons.

## Components
Consistent component behavior is vital for a system used by personnel in motion.

- **Buttons:** 
  - *Primary:* Amber background, dark navy or white text. Height: 48px for mobile-friendly tapping.
  - *Secondary:* Navy outline or transparent background with navy text.
- **Cards:** White background, 12px radius, subtle shadow. Used for shipment details, vehicle info, and driver profiles.
- **Input Fields:** 8px radius, 1px light grey border. On focus, the border transitions to Primary Navy or Amber with a subtle outer glow.
- **Chips/Badges:** Small, pill-shaped indicators. Use semantic colors (Success Green, Danger Red) with 10% opacity backgrounds and 100% opacity text for high legibility.
- **Data Tables:** Clean, border-bottom only for rows. Use `label-md` for headers in all-caps or medium-weight to ensure the data itself remains the focus.
- **QR Placeholders:** High-contrast amber border containers with a central icon, signaling where the user should interact for scanning operations.
- **Lists:** Mobile-first list items should have a minimum height of 64px to accommodate "fat-finger" interactions in the field.