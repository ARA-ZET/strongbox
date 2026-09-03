# 10 — Design System

Source of truth for all visual decisions. Always use these constants — never hardcode values.

---

## Colours (`lib/core/theme/app_colors.dart`)

```dart
class AppColors {
  // Brand
  static const navy      = Color(0xFF1A2B4A);  // Sidebar, dark buttons, headings
  static const amber     = Color(0xFFFEAE2C);  // Primary CTA, active nav, highlights
  static const amberDark = Color(0xFF6B4500);  // Text ON amber buttons

  // Backgrounds
  static const scaffold         = Color(0xFFF5F2FF);  // Page background
  static const surface          = Color(0xFFFFFFFF);  // Cards, modals
  static const surfaceContainer = Color(0xFFEFECFF);  // Table rows, input bg

  // Text
  static const textPrimary   = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF44474E);
  static const textHint      = Color(0xFF75777E);

  // Border
  static const border = Color(0xFFC5C6CF);

  // Status — background colours (for chips and banners)
  static const statusSuccessBg = Color(0xFFE8F5F0);
  static const statusWarningBg = Color(0xFFFFF3E0);
  static const statusErrorBg   = Color(0xFFFFEBEB);
  static const statusPendingBg = Color(0xFFF0F0F0);
  static const statusPastDueBg = Color(0xFFFFF0D4);

  // Status — text/icon colours
  static const statusSuccess = Color(0xFF00A858);
  static const statusWarning = Color(0xFFE67E22);
  static const statusError   = Color(0xFFBA1A1A);
  static const statusPending = Color(0xFF44474E);
  static const statusPastDue = Color(0xFF835500);

  // Overlays
  static const overlay     = Color(0x80000000);  // 50% black overlay
  static const cardShadow  = Color(0x14000000);  // 8% black shadow
}
```

---

## Typography

Font: **Inter** via `google_fonts`. Load once in `app_theme.dart`.

| Style name | Size | Weight | Use |
|---|---|---|---|
| display | 28px | Bold (700) | Page headlines |
| headline | 22px | Bold (700) | Card titles |
| title | 16px | SemiBold (600) | Section headers |
| label | 14px | Medium (500) | Table headers, chips, nav |
| body | 14px | Regular (400) | Table rows, body text |
| caption | 12px | Regular (400) | Timestamps, hints |
| overline | 11px | Medium (500) | ALL CAPS labels |

```dart
// Usage
Text('Page Title', style: Theme.of(context).textTheme.displayLarge)
// Or directly:
GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)
```

---

## Spacing

Use multiples of 4. Define as constants:

```dart
class AppSpacing {
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}
```

- **Page padding:** 24px desktop, 16px mobile
- **Card padding:** 16px
- **Section gap:** 24px between major sections
- **Item gap:** 12px between list/grid items

---

## Border Radius

```dart
class AppRadius {
  static const sm   = BorderRadius.all(Radius.circular(8));   // Inputs, buttons
  static const md   = BorderRadius.all(Radius.circular(12));  // Cards, modals
  static const lg   = BorderRadius.all(Radius.circular(16));  // Large panels
  static const pill = BorderRadius.all(Radius.circular(999)); // Status chips
}
```

---

## Elevation / Shadow

```dart
class AppShadow {
  static const card = [
    BoxShadow(blurRadius: 8, color: AppColors.cardShadow, offset: Offset(0, 2)),
  ];
  static const modal = [
    BoxShadow(blurRadius: 24, color: AppColors.cardShadow, offset: Offset(0, 8)),
  ];
}
```

---

## Buttons

### Primary Button (amber)
- Background: `AppColors.amber`
- Text: `AppColors.amberDark`
- Height: 48px
- Border radius: 8px
- Font: 14px SemiBold
- Loading state: amber `CircularProgressIndicator` replaces label

### Secondary Button (navy outline)
- Background: transparent
- Border: 1.5px `AppColors.navy`
- Text: `AppColors.navy`
- Height: 48px
- Border radius: 8px

### Destructive Button (red)
- Background: `AppColors.statusError`
- Text: white
- Height: 48px
- Border radius: 8px

### Ghost Button (text only)
- No background, no border
- Text: `AppColors.navy` or `AppColors.amber`
- Used for inline actions

### FAB (floating action)
- Background: `AppColors.amber`
- Icon: white
- Size: 56px circle

---

## Inputs

```dart
InputDecoration(
  filled: true,
  fillColor: AppColors.surfaceContainer,
  border: OutlineInputBorder(
    borderRadius: AppRadius.sm,
    borderSide: BorderSide(color: AppColors.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: AppRadius.sm,
    borderSide: BorderSide(color: AppColors.navy, width: 1.5),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
)
```

---

## Status Chips

Always use the `StatusChip` widget. Supported status strings:

| Status string | Background | Text colour |
|---|---|---|
| `completed`, `active`, `delivered`, `inStorage`, `available` | `#E8F5F0` | `#00A858` |
| `inProgress`, `inTransit`, `pendingDelivery`, `onJob` | `#FFF3E0` | `#E67E22` |
| `scheduled`, `pending`, `pendingPickup`, `assigned` | `#F0F0F0` | `#44474E` |
| `cancelled`, `critical`, `archived` | `#FFEBEB` | `#BA1A1A` |
| `pastDue`, `unpaid` | `#FFF0D4` | `#835500` |

Chip shape: full pill. Padding: 6px vertical, 12px horizontal. Font: 12px Medium.

---

## Admin Sidebar

- Width: 240px (fixed on desktop)
- Background: `AppColors.navy`
- Nav item height: 48px
- Nav item padding: 12px horizontal
- Nav item border radius: 8px
- Active state: background `AppColors.amber`, icon + text `AppColors.amberDark`
- Inactive state: icon + text white at 70% opacity

---

## Cards

```dart
Card(
  color: AppColors.surface,
  shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
  elevation: 0,
  child: DecoratedBox(
    decoration: BoxDecoration(
      boxShadow: AppShadow.card,
      borderRadius: AppRadius.md,
    ),
    child: Padding(padding: EdgeInsets.all(AppSpacing.md), child: ...),
  ),
)
```

---

## Tables

- Header row: background `AppColors.surfaceContainer`, text `AppColors.textSecondary`, 12px Medium ALL CAPS
- Data rows: white background, 12px border-bottom with `AppColors.border`
- Row hover (desktop): background `AppColors.surfaceContainer`
- Row height: 56px minimum
- Cell padding: 12px horizontal

---

## Empty States

Consistent empty state pattern:
- Centre-aligned container
- Illustration or icon (64px, grey)
- Heading (16px SemiBold, navy)
- Subtext (14px, grey)
- Optional primary action button

---

## Animations

- Page transitions: `FadeTransition` 200ms
- List item add/remove: `AnimatedList` with slide + fade 300ms
- Status chip colour change: `AnimatedContainer` 200ms
- Loading skeleton: shimmer animation using `shimmer` package (amber → light grey)
- Scanner viewfinder: pulsing border animation 1.5s loop
