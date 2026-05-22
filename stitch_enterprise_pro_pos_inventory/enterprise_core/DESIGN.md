---
name: Enterprise Core
colors:
  surface: '#fbf8ff'
  surface-dim: '#dbd9e2'
  surface-bright: '#fbf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f2fc'
  surface-container: '#efedf6'
  surface-container-high: '#e9e7f0'
  surface-container-highest: '#e3e1ea'
  on-surface: '#1a1b22'
  on-surface-variant: '#454652'
  inverse-surface: '#2f3037'
  inverse-on-surface: '#f2eff9'
  outline: '#757684'
  outline-variant: '#c5c5d4'
  surface-tint: '#4355b9'
  primary: '#24389c'
  on-primary: '#ffffff'
  primary-container: '#3f51b5'
  on-primary-container: '#cacfff'
  inverse-primary: '#bac3ff'
  secondary: '#006b5e'
  on-secondary: '#ffffff'
  secondary-container: '#94f0df'
  on-secondary-container: '#006f62'
  tertiary: '#6c3400'
  on-tertiary: '#ffffff'
  tertiary-container: '#8f4700'
  on-tertiary-container: '#ffc7a2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dee0ff'
  primary-fixed-dim: '#bac3ff'
  on-primary-fixed: '#00105c'
  on-primary-fixed-variant: '#293ca0'
  secondary-fixed: '#97f3e2'
  secondary-fixed-dim: '#7ad7c6'
  on-secondary-fixed: '#00201b'
  on-secondary-fixed-variant: '#005047'
  tertiary-fixed: '#ffdcc6'
  tertiary-fixed-dim: '#ffb784'
  on-tertiary-fixed: '#301400'
  on-tertiary-fixed-variant: '#713700'
  background: '#fbf8ff'
  on-background: '#1a1b22'
  surface-variant: '#e3e1ea'
typography:
  display-price:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  numeric-data:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 24px
---

## Brand & Style

The design system is engineered for high-velocity enterprise environments where accuracy and speed are non-negotiable. It serves retail staff, warehouse managers, and business owners who require a reliable, professional tool that minimizes cognitive load.

The visual style is **Corporate Modern** with a focus on functional clarity. It prioritizes information density without sacrificing legibility. The interface utilizes a structured hierarchy, ample tap targets for mobile use, and a rhythmic layout that feels systematic and stable. The aesthetic is "utilitarian-premium"—it looks sophisticated but functions with the efficiency of a high-performance instrument.

## Colors

The palette is anchored by **Deep Indigo** for primary actions and brand presence, conveying stability and trust. **Professional Teal** is used for secondary interactive elements and filtering. 

Functionality is color-coded to reduce errors:
- **Emerald Green** specifically denotes income, successful transactions, and "In Stock" statuses.
- **Crimson** is reserved for outcome, deletions, and critical "Out of Stock" errors.
- **Amber** provides immediate visual feedback for low-stock thresholds.

For the Dark Mode implementation, surfaces use a high-contrast charcoal (#121212) rather than pure black to reduce eye strain during night shifts, maintaining accessibility compliant with WCAG AA standards.

## Typography

**Inter** is the sole typeface, chosen for its exceptional legibility and neutral character. 

Key typographic rules:
- **Price Display:** Use `display-price` for checkout totals. Ensure the currency symbol is slightly smaller or lighter in weight than the value.
- **Numeric Data:** Always enable "Tabular Numerals" (tnum) for inventory counts and tables to ensure numbers align vertically for quick scanning.
- **Labels:** Use `label-md` in all-caps for section headers and metadata tags to differentiate them from actionable body text.

## Layout & Spacing

The system uses a **Fluid Grid** model based on a 4px baseline.

- **Mobile (Portrait):** A single-column vertical stack with 16px side margins. Items like inventory cards span the full width.
- **Tablet (Landscape):** A dual-pane master-detail layout. The left pane (approx. 33% width) handles navigation or list-view items, while the right pane (approx. 66% width) displays item details or the active shopping cart.
- **Touch Targets:** All interactive elements maintain a minimum height of 48px to accommodate rapid use in physical environments.
- **Gaps:** Use `md` (16px) for standard spacing between related components and `lg` (24px) to separate distinct functional sections.

## Elevation & Depth

Depth is used sparingly and purposefully to indicate interactivity and hierarchy:

- **Level 0 (Flat):** Used for the main background surface.
- **Level 1 (Subtle):** Used for inventory cards and list items. Defined by a soft, 4px blur shadow with 5% opacity and a 1px neutral border (#E2E8F0).
- **Level 2 (Active):** Used for modals, bottom sheets, and the active cart summary. This uses a 12px blur shadow with 10% opacity.
- **Selection State:** Rather than heavy shadows, selected items are indicated by a 2px Primary Indigo inner stroke and a subtle background tint (5% opacity of the primary color).

## Shapes

The shape language is **Soft (0.25rem)**, reflecting a professional and structured environment. 

- **Cards/Containers:** Use `rounded-lg` (0.5rem) to provide a modern feel without looking overly casual.
- **Buttons:** Apply `rounded-md` (0.25rem). Do not use pill shapes, as the rectangular structure better aligns with dense, grid-based data layouts.
- **Input Fields:** Use 4px corner radius to maintain consistency with the buttons, ensuring a cohesive "input" language across the UI.

## Components

### Buttons
- **Primary:** Solid Deep Indigo with white text. High-contrast with a visible ripple effect on tap.
- **Ghost/Tertiary:** Used for less frequent actions (e.g., "Add Note"). These have no border or background until tapped.

### Inventory Cards
Cards feature a top-aligned image (if available), followed by the item name in `body-lg` (bold) and the price. The bottom right corner is reserved for the "Stock Count" badge.

### Status Badges
Small, high-contrast pills with `label-md` text.
- **Stock Status:** Green (In Stock), Amber (Low), Red (Out).
- **Platform Badge:** Used to identify source (e.g., "POS," "Web," "Marketplace").

### Data-Heavy Views
- **Loading Skeletons:** Use shimmer-effect rectangles that mimic the exact layout of inventory cards or list rows to prevent layout shift.
- **Input Fields:** Outlined style with floating labels. When focused, the border thickens to 2px Indigo.

### Interactive Charts
Line and Bar charts use the secondary palette (Teal and Indigo) for data series. Hover/Tap states on chart data points should trigger a small tooltip with specific numeric values in `numeric-data` styling.