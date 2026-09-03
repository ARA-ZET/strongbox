---
name: Valet Custodian
colors:
  surface: '#fbf8fc'
  surface-dim: '#dbd9dc'
  surface-bright: '#fbf8fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f6'
  surface-container: '#efedf0'
  surface-container-high: '#e9e7eb'
  surface-container-highest: '#e4e2e5'
  on-surface: '#1b1b1e'
  on-surface-variant: '#44474e'
  inverse-surface: '#303033'
  inverse-on-surface: '#f2f0f3'
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
  background: '#fbf8fc'
  on-background: '#1b1b1e'
  surface-variant: '#e4e2e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
  title-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  caption-xs:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  page_padding: 24px
  stack_sm: 8px
  stack_md: 16px
  stack_lg: 24px
  gutter: 16px
  container_max: 1200px
---

## Brand & Style
The design system for this valet storage platform prioritizes a sense of security, organization, and effortless logistics. The brand personality is **Professional, Dependable, and Systematic**, catering to urban dwellers and businesses who require off-site storage without the friction of traditional self-storage.

The visual style is **Corporate / Modern**, leaning into high-utility layouts and a structured grid that evokes the feeling of a well-managed warehouse. We utilize a clean, systematic approach where whitespace and clear information hierarchy reassure the user that their physical belongings are in safe hands. The interface remains approachable through the use of soft background tints and high-contrast call-to-actions.

## Colors
The palette is anchored by **Navy (#1A2B4A)** to establish authority and trust. **Amber (#FEAE2C)** serves as the primary action color, providing a warm, high-visibility contrast that guides users toward key tasks like booking or item retrieval.

- **Foundations:** The background uses a very subtle lavender-tinted neutral to differentiate from pure white surfaces and containers, enhancing the layered feel of the UI.
- **Feedback:** Semantic colors for Success, Warning, and Error include dedicated light background tints for high-readability alert banners and status indicators.
- **Currency:** All financial data must be localized to South African Rand (R), utilizing the Text Primary color for amounts to ensure prominence.

## Typography
The design system exclusively utilizes **Inter** to maintain a neutral, systematic, and utilitarian aesthetic. This typeface ensures maximum legibility for logistical data, such as tracking numbers and inventory lists.

- **Hierarchy:** Display and Headline levels use Bold weights to create clear section anchoring. Titles use SemiBold for a distinct but less aggressive emphasis.
- **Utility:** Captions and Labels are used for metadata, status timestamps, and secondary inventory details.
- **Icons:** We use **Material Symbols Outlined** at a standard 20px or 24px size, aligned with the baseline of the text.

## Layout & Spacing
This design system employs a **Fluid Grid** with fixed outer margins. The layout is optimized for high-density information management while maintaining "breathability" through consistent padding.

- **Page Structure:** A standard 24px padding is applied to the main viewport edges.
- **Grid:** On desktop, a 12-column grid is used with 16px gutters. On mobile, this collapses to a single column with the same 24px side margins.
- **Vertical Rhythm:** Components are spaced using a base-8 increment system (8px, 16px, 24px, 48px) to ensure mathematical harmony across the dashboard.

## Elevation & Depth
Hierarchy is established through **Tonal Layers** and subtle **Ambient Shadows**. This approach ensures the UI feels tactile without being distracting.

- **Surface Tiers:** The `background` serves as the lowest level. `Surface Container` acts as a middle-tier grouping element for related items. `Surface` (White) is reserved for the highest-level interactive cards and modals.
- **Shadows:** We use a single, soft elevation profile for interactive cards: `0 2px 8px rgba(0,0,0,0.08)`. This provides enough lift to suggest "pick-up" or "interactivity" suitable for a valet service metaphor.
- **Borders:** Low-contrast outlines using the `border` color are used on input fields and secondary buttons to maintain structure without adding visual weight.

## Shapes
The shape language is varied to create clear functional distinction between component types.

- **Cards:** Use a 12px radius to feel friendly and approachable, containing inventory items or subscription details.
- **Buttons:** Use a tighter 8px radius to signify a more precise, actionable target.
- **Chips & Tags:** Use a full pill radius to differentiate them from buttons, serving as status indicators (e.g., "In Transit", "Stored").

## Components
- **Buttons:** Primary buttons use the Navy background with White text, or Amber background with Navy text for high-priority CTAs. They feature 8px corners and 16px horizontal padding.
- **Inventory Cards:** These utilize the 12px radius and the defined ambient shadow. They should feature a clear image thumbnail, title, and a status chip.
- **Chips:** Full pill-shaped elements. Use semantic background colors (Success/Warning/Error) with dark text for status tracking.
- **Input Fields:** 8px radius with a 1px border. Focus states should use a 2px Navy border to indicate active data entry.
- **Lists:** Use the `Surface Container` for list item hover states. Each row should have a subtle 1px bottom border for clear separation in dense data views.
- **Checkboxes & Radios:** Use the Navy color for the selected state to maintain brand consistency.