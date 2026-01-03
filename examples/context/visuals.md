# Visual Design - Example Project

## Color Palette

### Primary Colors

| Name | Hex | Usage |
|------|-----|-------|
| Primary | #3B82F6 | Buttons, links |
| Primary Dark | #1D4ED8 | Hover states |
| Primary Light | #93C5FD | Backgrounds |

### Neutral Colors

| Name | Hex | Usage |
|------|-----|-------|
| Background | #FFFFFF | Page background |
| Surface | #F9FAFB | Cards, panels |
| Border | #E5E7EB | Dividers |
| Text | #111827 | Body text |
| Text Muted | #6B7280 | Secondary text |

### Semantic Colors

| Name | Hex | Usage |
|------|-----|-------|
| Success | #10B981 | Completed states |
| Warning | #F59E0B | Caution states |
| Error | #EF4444 | Error states |
| Info | #3B82F6 | Information |

## Typography

### Font Stack

```css
--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', monospace;
```

### Scale

| Name | Size | Line Height | Weight |
|------|------|-------------|--------|
| h1 | 2.25rem | 2.5rem | 700 |
| h2 | 1.875rem | 2.25rem | 600 |
| h3 | 1.5rem | 2rem | 600 |
| body | 1rem | 1.5rem | 400 |
| small | 0.875rem | 1.25rem | 400 |

## Component Patterns

### Buttons

- Primary: Solid background, white text
- Secondary: Outline, primary border
- Ghost: No background, text only
- Destructive: Red background

### Cards

```
┌─────────────────────────┐
│ [Header]                │
├─────────────────────────┤
│ [Content]               │
│                         │
├─────────────────────────┤
│ [Footer/Actions]        │
└─────────────────────────┘
```

### Forms

- Labels above inputs
- Helper text below inputs
- Error messages in red below field
- Required fields marked with *

## Spacing

Base unit: 4px

| Name | Size |
|------|------|
| xs | 4px |
| sm | 8px |
| md | 16px |
| lg | 24px |
| xl | 32px |
| 2xl | 48px |

## Responsive Breakpoints

| Name | Width |
|------|-------|
| sm | 640px |
| md | 768px |
| lg | 1024px |
| xl | 1280px |
