# DialKit 2.0

**Part of [Interface Craft](SKILL.md) by Josh Puckett**

Build live controls for tuning an interface in its running app. This guide targets **dialkit@2.0.0**: React, Solid, Svelte 5, Vue 3, and plain JavaScript. Use the project's framework and animation runtime.

## Choose the authoring surface

- **Parameter panels**: tune appearance, text, images, XY positions, spring physics, or easing. Use `useDialKit` / `createDialKit`.
- **Controllers**: use `useDialKitController` / `createDialKitController` when application buttons, URL state, or other app code must also update panel values.
- **Animation timeline**: tune clip start times, sequences, independent property tracks, loops, replay, or reversible state boundaries. Read [dialkit-timeline.md](dialkit-timeline.md) for configuration, scrubbing, dock controls, and production handoff.
- Use both panels and Timeline when the task needs appearance controls and choreography. Do not rebuild the timeline out of delay sliders and timers.

When the request identifies a component or properties, inspect the code and implement directly. For a bare invocation, infer useful controls from the current component; ask a concise question only if the target cannot be determined. Preserve existing values as defaults, choose useful ranges, and bind every generated control to the actual UI.

## Setup

Inspect project instructions, package manager, `package.json`, lockfile, and existing DialKit roots before editing. Check the installed version before using 2.0 features. Follow the project's dependency rules and existing authorization; a skill invocation alone does not authorize adding or upgrading packages. For an authorized upgrade, use an exact DialKit version and preserve the project's version-pinning policy for all dependencies.

| Adapter | Import from | Panel / controller | Read panel / controller values | Required peers for editor UI |
| --- | --- | --- | --- | --- |
| React 18+ | `dialkit` | `useDialKit` / `useDialKitController` | `p.radius` / `dial.values.radius` | `react`, `react-dom`, `motion` 11+ |
| Solid 1.6+ | `dialkit/solid` | `createDialKit` / `createDialKitController` | `p().radius` / `dial.values().radius` | `solid-js`, `motion` 11+ |
| Svelte 5.8+ | `dialkit/svelte` | `createDialKit` / `createDialKitController` | `p.radius` / `dial.values.radius` | `svelte` |
| Vue 3.3+ | `dialkit/vue` | `useDialKit` / `useDialKitController` | `p.value.radius` / `dial.values.value.radius` in script | `vue`, `motion` 11+, `motion-v` 2+ |
| Plain JavaScript | `dialkit/vanilla` | `createDialKit` (already a controller) | `kit.values.radius` or `kit.subscribe(callback)` | None |

Vue templates unwrap the returned ref. Preserve reactive access in Solid, Svelte, and Vue; do not capture a primitive snapshot outside a reactive expression and expect it to update.

Mount one `DialRoot` for panels and one `DialTimeline` for timelines, using the matching adapter. They are independent siblings of app content, not context providers. Add the missing surface when implementing an authorized integration. A timeline-only app does not need `DialRoot`.

- React, Solid, Vue: import `dialkit/styles.css` once.
- Svelte: `DialRoot` injects styles. For Timeline without `DialRoot`, import `dialkit/styles.css` yourself.
- Vanilla: import `dialkit/vanilla/styles.css`; mount `createDialRoot()` and/or `createDialTimelineRoot()`.
- Next.js App Router: put hooks and authoring surfaces in a client component. Mount that component from the existing layout without converting the whole layout to a client component.

## Controls

Keys become labels; nested objects become folders and returned values retain their paths. Use `satisfies DialConfig` for extracted configs so literals and slider tuples retain useful inference. Import public types from the same adapter as the functions.

| Control | Configuration example | Result |
| --- | --- | --- |
| Slider | `blur: [24, 0, 100, 1]` | `number`; tuple is `[default, min, max, step?]` |
| Inferred slider | `scale: 1.2` | `number`; prefer explicit bounds when precision matters |
| Toggle | `visible: true` | `boolean` |
| Text | `title: 'Hello'` | `string` |
| Explicit text | `notes: { type: 'text', default: '', placeholder: 'Notes' }` | `string`; grows up to five lines, then scrolls |
| Color | `accent: 'oklch(0.7 0.2 145 / 0.8)'` | CSS color string |
| Select | `layout: { type: 'select', options: ['stack', 'grid'], default: 'stack' }` | Selected string; options also accept `{ value, label }` |
| Image | `cover: { type: 'image', options: ['/cover.jpg'] }` | URL or data URL; `''` when empty |
| XY pad | `position: { type: 'pad', x: [0, -100, 100, 1], y: [0, -100, 100, 1] }` | `{ x: number, y: number }` |
| Time spring | `curve: { type: 'spring', visualDuration: 0.3, bounce: 0.2 }` | `TransitionConfig` |
| Physics spring | `curve: { type: 'spring', stiffness: 200, damping: 25, mass: 1 }` | `TransitionConfig` |
| Easing | `curve: { type: 'easing', duration: 0.3, ease: [0.25, 0.1, 0.25, 1] }` | `TransitionConfig` |
| Action | `replay: { type: 'action', label: 'Replay animation' }` | Calls `options.onAction('replay')` |
| Folder | `shadow: { _collapsed: true, blur: [16, 0, 48, 1] }` | `p.shadow.blur`; `_collapsed` is omitted at runtime |

[references/config-patterns.json](references/config-patterns.json) contains reusable configurations, suggested ranges, and type summaries. These are starting points, not replacements for the component's current values or the package's TypeScript definitions.

### XY pads

Use a pad when two related values benefit from spatial editing: position, transform origin, light direction, or duration/bounce. Each axis takes a slider tuple; omitted axes default to `[0, -1, 1, 0.01]`. An explicit axis without a step uses `(max - min) / 200`. Values clamp and snap to the step; bounds must be finite with `min < max` and a positive step.

`labels: { x: 'Duration', y: 'Bounce' }` changes labels, not the `{ x, y }` result. X increases rightward; Y increases **upward**. Negate Y when binding spatial pad movement to CSS or Motion coordinates if the element should follow the pad. For non-spatial parameters, use the values directly.

Shift-drag locks an axis; Home or double-click restores defaults; Escape cancels a drag. Update pads as a whole value: `dial.setValue('position', { x: 40, y: 20 })`, not as invented nested controls `position.x` and `position.y`.

### Colors and images

Color detection accepts hex (3, 4, 6, or 8 digits), RGB, HSL, OKLCH, and Display P3. The picker has Hex, OKLCH, and Display P3 output with alpha controls. Bind the returned CSS string directly; do not assume it is hex or parse it into RGB channels. Named colors, variables, relative colors, and `calc()` are not parsed. Use `{ type: 'color', default: 'transparent' }` for transparent and explicit `type: 'text'` to keep a color-looking string as text.

Image `options` accept URLs or `{ value, label }` objects. `default` selects the initial URL; otherwise the first option is selected. Omit options for upload-only controls. Uploads and drops up to 10 MB become local data URLs; nothing is uploaded to a server. Uploaded choices last for the control's lifetime; the selected value can persist, subject to browser storage limits. Handle `''` before rendering an image and use the project's existing image component (`next/image` in Next.js).

### Transitions and Motion

Spring and easing definitions open the same editor with **Easing**, **Time**, and **Physics** modes. Easing offers draggable Bézier handles and editable coordinates; mode switching restores that mode's previous edits while mounted. Even a config initially called `spring` returns the **`TransitionConfig` union**, because the user can switch modes.

DialKit calls a Bézier transition `type: 'easing'`; Motion calls it `type: 'tween'`. Narrow and convert at the rendering boundary. Reuse this adapter when several components need it; do not cast the union to `SpringConfig` or pass `type: 'easing'` to Motion.

```tsx
import type { TransitionConfig } from 'dialkit'
import type { Transition } from 'motion/react'

function toMotionTransition(curve: TransitionConfig): Transition {
  return curve.type === 'easing'
    ? { type: 'tween', duration: curve.duration, ease: curve.ease }
    : curve
}
```

Use the project's existing Motion import if it uses `framer-motion`. Time springs are a useful starting point for new controls; preserve physics springs where the existing animation uses them. All durations are in seconds.

## Complete React example

This component tunes the actual card and lets the app reset the panel. Mount `DialRoot` once alongside it in the existing client shell.

```tsx
'use client'

import { useDialKitController } from 'dialkit'
import { motion, type Transition } from 'motion/react'

export function CardPreview() {
  const dial = useDialKitController('Card', {
    title: 'Hello',
    accent: 'oklch(0.7 0.2 145)',
    position: { type: 'pad', x: [0, -100, 100, 1], y: [0, -100, 100, 1] },
    scale: [1, 0.5, 2, 0.01],
    curve: { type: 'spring', visualDuration: 0.3, bounce: 0.2 },
  }, { id: 'card-preview' })
  const p = dial.values
  const transition: Transition = p.curve.type === 'easing'
    ? { type: 'tween', duration: p.curve.duration, ease: p.curve.ease }
    : p.curve

  return (
    <>
      <motion.div
        style={{ background: p.accent }}
        animate={{ x: p.position.x, y: -p.position.y, scale: p.scale }}
        transition={transition}
      >
        {p.title}
      </motion.div>
      <button type="button" onClick={() => dial.resetValues()}>Reset</button>
    </>
  )
}
```

## Controllers, actions, and saved versions

Use the simple hook when only the panel changes values. Use the controller for application-driven edits instead of mirroring DialKit values into separate React state.

| Controller member | Use |
| --- | --- |
| `values` | Live values with the adapter-specific access pattern above |
| `setValue(path, value)` | Set one control, e.g. `dial.setValue('shadow.blur', 24)` |
| `setValues(values)` | Apply a typed nested partial object in one update, e.g. `{ shadow: { blur: 8 } }` |
| `resetValues()` | Restore current config defaults and clear the active preset |
| `getValues()` | Read the latest snapshot inside callbacks |
| `setOpen(boolean)` | Expand/collapse the panel; opening also reveals its root |
| `getOpen()` | Read open state; `undefined` before a root default has been initialized |

Actions call `onAction` with their full dot path, e.g. `shadow.reset`. Wire them to real handlers, including timeline `replay()` when appropriate. Actions are triggers, not writable state; `setValues` neither sets nor invokes them.

The toolbar's **+** saves and selects a version. Edits, including controller updates, modify the selected version. **Version 1** holds editable base values. **Copy** exports current values with an instruction for updating the config; apply those to defaults while preserving slider bounds, labels, and structure. Copy does not modify source files itself.

A stable `id` shares values across mounts/pages. Keep configs consistent across registrations with the same ID. Add `persist: true` to save values, versions, and the active version to `localStorage` under `dialkit:${id}`. Use `{ key: 'my-app:card', storage: 'sessionStorage', presets: false }` for a custom key and values-only session persistence. Prefer development-only persistence for authoring controls unless saved overrides are an intended app feature. Panel open state is retained in memory for stable IDs but is never persisted to storage.

## Panel layout and keyboard controls

`DialRoot` accepts `position` (four viewport corners, default `top-right`), `theme` (`system`, `light`, `dark`), `mode` (`popover` or `inline`), `defaultOpen`, `onOpenChange`, and `productionEnabled`. Inline mode fills its container, ignores position, and disables collapse-to-icon. Popover panels are draggable and collapse to an icon.

Use `{ defaultCollapsed: true }` in panel options to override the root's initial open state; use controller `setOpen` for later changes. Folder `_collapsed` only affects that nested folder. `DialRoot` has no controlled `open` prop; individual `Folder` components support `open` / `onOpenChange`. Vue events use `@open-change`.

Framework roots and docks are hidden in production by default. Set `productionEnabled` only if the editor should be visible there. Vanilla roots and docks are enabled by default; use `productionEnabled: false` to hide them. These flags control editor visibility, not hooks, controllers, persistence, or animation playback.

Assigned shortcuts go in panel options, keyed by control path:

```tsx
const options = {
  shortcuts: {
    scale: { key: 's', mode: 'fine' },
    'shadow.blur': { key: 'b', modifier: 'alt', interaction: 'drag' },
    visible: { key: 'v' },
  },
} satisfies import('dialkit').UseDialOptions
```

Sliders support `scroll` (default), `drag`, `move`, or `scroll-only` (no key needed). Modifiers are `alt`, `shift`, or `meta`. `normal` uses the slider step; `fine` uses 1% of its range; `coarse` uses 10%. Toggles flip on keypress. Assigned shortcuts pause while an input, button, or keyboard-operated control has focus.

Built-in keyboard operation needs no shortcuts: Tab to controls; slider arrows change one step, Shift+Arrow/Page Up/Down change ten, Home/End reach bounds, and Enter opens numeric editing. Menus support arrows, typeahead, selection, and Escape. XY pads and Bézier handles support arrows and larger Shift+Arrow steps. Preserve these semantics when building custom layouts.

## Plain JavaScript lifecycle

Vanilla needs no React or Motion runtime. Subscribe to changes instead of reading a snapshot once:

```ts
import { createDialKit, createDialRoot } from 'dialkit/vanilla'
import 'dialkit/vanilla/styles.css'

export function mountCardControls(card: HTMLElement) {
  const root = createDialRoot()
  const kit = createDialKit('Card', { radius: [24, 0, 64, 1] })
  const unsubscribe = kit.subscribe(values => {
    card.style.borderRadius = `${values.radius}px`
  })

  return () => {
    unsubscribe()
    kit.destroy()
    root.destroy()
  }
}
```

`subscribe(callback, immediate?)` calls immediately by default and returns an unsubscribe function. `values` / `getValues()` are snapshots. `updateConfig(config)` reconciles definitions while keeping compatible edits. Destroy controllers separately from roots; removing the editor does not release registrations. For inline UI use `createDialRoot({ mode: 'inline', target: container })`.

Without a bundler, use the package's `dist/vanilla/browser.global.js` (global `DialKit`) and `dist/vanilla/styles.css`; a self-contained ES module is available at `dist/vanilla/index.js`. Use one entry consistently so controls and roots share the same store. Do not add a framework just to use DialKit.

## Custom layouts and source checks

For custom editor layouts, adapters export controls such as `Slider`, `DialPad`, `ImageControl`, `TransitionControl`, `Folder`, and `ControlRenderer`, plus `DialStore`. Keep controls inside `.dialkit-root` with a `data-theme` value. Vanilla uses `mountSlider(host, props)` and analogous mount functions returning `update(props)` / `destroy()`; mount `mountShortcutListener()` if global shortcuts are needed without a root. Vue also exports `vDialKit` for directive-based root mounting.

Before using advanced component props or store APIs, inspect the installed types and the [official reference](https://github.com/joshpuckett/dialkit/blob/main/docs/reference.md). Prefer controllers over direct store access for ordinary application edits.

Verified against the published npm 2.0.0 metadata and matching DialKit source at commit `d408597c85b118dc497a209c5f1dc396922f8cc7`. The [README](https://github.com/joshpuckett/dialkit#readme), [control reference](https://github.com/joshpuckett/dialkit/blob/main/docs/reference.md), and [timeline guide](https://github.com/joshpuckett/dialkit/blob/main/docs/timeline.md) are the upstream references. If documentation and installed APIs differ, use the installed version's public types and implementation.
