# DialKit Timeline

Use DialKit **2.0.0** Timeline to author and tune animation choreography: clip timing, sequences, independent property tracks, loops, replayable interactions, reversible timeline events, and scrubbing. Examples use React; Timeline also supports Solid, Svelte 5, Vue 3, and plain JavaScript.

## Contents

- [Setup](#setup)
- [Core model](#core-model)
- [Recommended authoring pattern](#recommended-authoring-pattern)
- [Choose a clip shape](#choose-a-clip-shape)
- [Discrete timeline events](#discrete-timeline-events)
- [Playback and loops](#playback-and-loops)
- [Dock and editing workflow](#dock-and-editing-workflow)
- [Rendering semantics](#rendering-semantics)
- [Plain JavaScript timeline](#plain-javascript-timeline)
- [Production handoff](#production-handoff)
- [Output rules](#output-rules)

## Setup

Follow [dialkit.md — Setup](dialkit.md#setup) for version checks, adapter dependencies, styles, and client boundaries. This guide targets 2.0.0; follow project dependency rules and existing user authorization before adding or upgrading packages. Mount `DialTimeline` once. `DialRoot` is optional unless the project also uses regular parameter panels. In Svelte, import the shared stylesheet yourself for a timeline-only app; in vanilla, use `dialkit/vanilla/styles.css`.

```tsx
"use client";

import type { ReactNode } from "react";
import { DialTimeline } from "dialkit";
import "dialkit/styles.css";

export function TimelineShell({ children }: { children: ReactNode }) {
  return (
    <>
      {children}
      <DialTimeline />
    </>
  );
}
```

Use the adapter that matches the project:

| Framework | Import | Timeline function | Read returned values |
| --- | --- | --- | --- |
| React | `dialkit` | `useDialTimeline` | `timeline.card.current` |
| Solid | `dialkit/solid` | `createDialTimeline` | `timeline().card.current` |
| Svelte 5 | `dialkit/svelte` | `createDialTimeline` | `timeline.card.current` |
| Vue 3 | `dialkit/vue` | `useDialTimeline` | `timeline.value.card.current` in script; auto-unwrapped in templates |
| Plain JavaScript | `dialkit/vanilla` | `createDialTimeline` | `timeline.values.card.current`; subscribe for frame updates |

Vanilla mounts the dock with `createDialTimelineRoot()`; other adapters export `DialTimeline`. Keep Solid/Vue/Svelte value reads reactive instead of capturing a primitive outside a reactive expression.

Hook/factory options:

| Option | Purpose | Default |
| --- | --- | --- |
| `id` | Stable logical timeline ID across mounts | Generated |
| `persist` | Save timing/value edits and presets; same boolean or storage object as panels | `false` |
| `autoplay` | Play on mount | `true` |
| `loop` | `true` wraps to 0; `{ from: seconds }` wraps to a loop region | `false` |

The returned timeline includes `time`, `playing`, `duration`, `play()`, `pause()`, `replay()`, and `seek(seconds)`. These names are reserved at the top level; do not use them as clip/group names. All times are **seconds**, even if a source storyboard is written in milliseconds.

## Core model

- Keep animation structure in code. Let the dock edit timing, values, and curves; do not expect it to invent clips, steps, loops, or relationships between elements.
- Give every clip a semantic name and an `at` start time, such as `enter`, `idle`, `cardReveal`, or `dismiss`.
- Give discrete state boundaries semantic names such as `tuck`, `enableInput`, or `moveBehind`.
- Use separate clips for separate behaviors even when one element combines their output.
- Treat top-level `duration` as a minimum editing window. Omit it for an initially exact-fit window. Allow the timeline to extend when edited content, especially a physics spring, grows past the boundary.
- Keep loop behavior code-defined.
- Use a stable `id` when persisting edits. In application projects, prefer development-only persistence unless the user explicitly wants authored overrides in production.
- For a reusable configuration, declare it separately with `satisfies TimelineConfig` so TypeScript checks its shape without losing literal inference. Import the type from the same framework adapter as the timeline function.

Clip state includes `at`, `duration`, `loop` (`"off"` / `"repeat"`), `started`, `active`, `done`, and `progress`. Sequences also expose a `step` index. Animating clips expose resolved `from`, `to`, `animate`, and sampled `current`; `to` is the final merged state for a sequence. Only single-curve clips expose `transition` and `css`; they are `undefined` for sequences and property tracks. Timing markers have no animated value bindings.

## Recommended authoring pattern

Use `clip.current` by default so every intermediate state remains scrubbable. Apply the returned values directly and preserve any expressions that combine multiple clips.

```tsx
"use client";

import { useDialTimeline } from "dialkit";

function Toast() {
  // TODO(production): DialKit's clip.current values are the scrubbable authoring preview.
  // Replace them with equivalent real Motion animations using the tuned timeline
  // timings and transitions, then remove useDialTimeline and <DialTimeline />.
  const toast = useDialTimeline(
    "Toast",
    {
      enter: {
        at: 0,
        duration: 0.45,
        from: { y: 16, scale: 0.94, opacity: 0 },
        to: { y: 0, scale: 1, opacity: 1 },
        transition: {
          type: "spring",
          visualDuration: 0.45,
          bounce: 0.2,
        },
      },
      dismiss: {
        at: 2,
        duration: 0.25,
        from: { y: 0, opacity: 1 },
        to: { y: -12, opacity: 0 },
        transition: {
          type: "easing",
          duration: 0.25,
          ease: [0.55, 0, 1, 0.45],
        },
      },
    },
    { autoplay: false },
  );

  const enter = toast.enter.current;
  const dismiss = toast.dismiss.current;

  return (
    <>
      <div
        style={{
          opacity: Math.min(enter.opacity, dismiss.opacity),
          transform: `translateY(${enter.y + dismiss.y}px) scale(${enter.scale})`,
        }}
      >
        Changes saved
      </div>
      <button onClick={() => toast.replay()}>Show toast</button>
    </>
  );
}
```

DialKit does not automatically compose `enter` and `dismiss`; the application owns expressions such as `enter.y + dismiss.y`. Preserve that composition while editing and during production conversion.

## Choose a clip shape

### One transition: `from` and `to`

Use one clip for one transition. A time spring or easing takes its length from the bar. A physics spring using `stiffness`, `damping`, or `mass` derives its duration from its settle time; its bar displays `~`. Edit the physics instead of resizing that bar. Without a duration, DialKit derives the length from the transition; a value clip without a transition uses a default spring with `bounce: 0.2`.

```tsx
cardEnter: {
  at: 0.4,
  duration: 0.6,
  from: { y: 32, opacity: 0 },
  to: { y: 0, opacity: 1 },
  transition: { type: "spring", visualDuration: 0.6, bounce: 0.2 },
}
```

### Sequential legs: `steps`

Use `steps` for explicit sequential states on one clip. Declare every animated property in `from`. A step changes only properties named in its `to`; all other properties hold their previous value. Each step can override `transition`; otherwise it inherits the clip's curve. The clip duration is the sum of step durations. Do not combine clip-level `steps` with `to`.

```tsx
path: {
  at: 0,
  from: { x: -70, y: 0, opacity: 0 },
  steps: [
    { duration: 0.5, to: { x: 0, opacity: 1 } },
    { duration: 0.4, to: { y: 36 } },
    { duration: 0.6, to: { x: 80, y: 0 } },
  ],
}
```

### Independent property timing: `props`

Use `props` when properties need separate delays, durations, curves, or steps. `delay` is relative to the clip's `at`; each track may use scalar `from`/`to` or scalar `steps`. Do not combine `props` with clip-level `from`, `to`, or `steps`, and do not use reserved clip field names as track names.

```tsx
card: {
  at: 0.4,
  props: {
    opacity: { from: 0, to: 1, duration: 0.3 },
    y: {
      from: 32,
      delay: 0.1,
      steps: [
        { duration: 0.6, to: 0 },
        { duration: 0.4, to: -8 },
      ],
    },
  },
}
```

### Markers

- Use a clip with only `at` and optional `duration` as a timing marker. Read its `started`, `active`, or `progress`; it has no `current` values.

### Groups

Nest clips one level inside a named object to create a presentational group. Grouping does not compose their animation values.

## Discrete timeline events

Model a reversible event as a zero-duration marker. DialKit does not invoke a callback; it derives marker state from the playhead. Use `started` for the before/after boundary so scrubbing backward restores the earlier state automatically.

```tsx
// Inside the scene component:
// TODO(production): Replace sampled travel and the tuck.started boundary with
// equivalent production choreography before removing the timeline hook and dock.
const close = useDialTimeline(
  "Gift close",
  {
    duration: 1.6,
    letter: {
      travel: {
        at: 0.01,
        duration: 0.92,
        from: { progress: 0 },
        to: { progress: 1 },
        transition: { type: "spring", bounce: 0.25 },
      },
      tuck: {
        at: 0.31,
        duration: 0,
      },
    },
  },
  {
    id: "gift-close-v1",
    persist: process.env.NODE_ENV === "development",
    autoplay: false,
  },
);

const letterLayer = close.letter.tuck.started ? 10 : 50;

return <div style={{ zIndex: letterLayer }}>{/* letter */}</div>;
```

This makes the `tuck` visible and movable in the authoring timeline while the application owns its meaning: before 0.31s the letter is above the envelope; at and after 0.31s it is behind the envelope front.

Follow these rules:

- Use `started` for an instantaneous marker (`duration: 0`). A zero-duration marker has no sustained active interval, so do not use `active` as its event flag.
- Use `active` for a finite on/off interval and `progress` for a finite custom effect. Markers do not return `current` values.
- Derive render state directly from the marker. Do not mirror it into React state or recreate it with `setTimeout`; both approaches make reverse scrubbing and seeking harder to reason about.
- Use markers for reversible UI state such as layer order, visibility, pointer interaction, labels, or mode changes. When switching `zIndex`, ensure the affected layers share the intended stacking context.
- Do not treat a marker as an imperative one-shot callback for analytics, network requests, purchases, destructive actions, or other external side effects. The playhead can cross the same marker repeatedly while replaying or scrubbing; keep those effects attached to the application's real event lifecycle.

## Playback and loops

- Use `autoplay: false` for event-driven UI and call `replay()` from the application's real trigger.
- Use `loop: true` (or `"repeat"`; disabled is `false` / `"off"`) on a clip to repeat its cycle until the timeline ends. There is no mirror mode: write a final step returning to the initial values for a seamless bob or pulse.
- Looping property tracks repeat at their own periods, including their phase delays. Their durations need not match.
- Use the hook option `{ loop: true }` to wrap the playhead to zero, or `{ loop: { from: 1.4 } }` for a one-time intro followed by a loop region. This is separate from an individual clip's loop setting.
- Looping clips keep their phase across playhead wraps; seeking returns to first-pass state at that time. `replay()` always starts from zero.
- Use `play()`, `pause()`, `replay()`, and `seek(time)` only as authoring transport or intentional application controls.
- Keep the real application trigger wired to the timeline while authoring so replay behavior is tested in context.
- Respect reduced-motion preferences. For an event-driven sequence, pause and seek to the intended state boundary so markers update, then render the intended endpoint and complete the application's state transition immediately. A sampled spring may not equal its target exactly at the clip end. Handle infinite loops with a chosen stable state.

## Dock and editing workflow

The bottom dock displays all registered timelines. Panels and timeline controls live in their respective surfaces; when both roots are mounted, the panel's timeline button toggles the dock. Visibility does not pause playback.

`DialTimeline` accepts `theme` (`system`, `light`, `dark`), `defaultVisible` (initial visibility, default `true`), controlled `visible` / `onVisibilityChange`, `defaultOpen` (initial expanded sections, default `true`), and `productionEnabled`. Vue emits `@visibility-change`. Framework docks are hidden in production by default; vanilla docks are enabled by default.

| Gesture | Result |
| --- | --- |
| Drag ruler/playhead or collapsed overview | Scrub; pause during drag and resume if previously playing |
| Alt/Option-drag ruler | Zoom around the drag's starting point |
| Shift-drag | Reset to full timescale and seek |
| Horizontal scroll while zoomed | Pan the visible time range |
| Drag clip | Change `at` |
| Drag clip edges | Retime a time spring/easing or marker window |
| Drag sequence segment boundary | Retime the step to its left |
| Click clip/segment | Edit endpoint values and transition, including Bézier handles |
| Expand a property clip, then drag a track | Edit that track's delay |
| Drag top edge of dock | Resize dock height |

Use **+** and the preset menu to compare authored versions; edits update the active version. **Copy** exports instructions with tuned timings, transitions, and values. Apply them to the code config and keep scrubbable bindings while authoring. It does not write code or convert the animation runtime itself.

## Rendering semantics

### Recommended: `current`

Bind `clip.current` directly while tuning. DialKit deterministically samples the configured easing or damped-spring equation, making intermediate states scrubbable. The sampler is designed to closely preview Motion but does not guarantee frame-for-frame identity with Motion's runtime implementation.

`done` reports a timing boundary; it does not force a spring's sampled `current` to equal `to`. Use explicit endpoints when an application state requires exact final values, including reduced-motion rendering.

Hiding or removing only `<DialTimeline />` hides the dock; it does not change what renders the animation. As long as code reads `clip.current`, DialKit's sampled values still drive the element.

Do not feed `clip.current` into a second animated `animate` layer that smooths those values, because that breaks deterministic scrubbing.

Use numeric values for smooth interpolation. The 2.0 sampler interpolates numbers and supported hex colors; other strings switch at the midpoint. Wide-gamut panel color support does not imply OKLCH/Display P3 timeline interpolation. For reliable color scrubbing use six/eight-digit hex, or animate numeric channels/progress and compose the desired CSS string yourself. CSS unit strings such as `"20px"` also switch; animate numeric `y: 20` and append units at the binding.

### Alternative: real Motion during authoring

For a single-curve clip, use `clip.animate` with a Motion-compatible conversion of `clip.transition` when actual Motion playback matters more than scrubbing. Follow [the transition adapter](dialkit.md#transitions-and-motion): DialKit `type: "easing"` must become Motion `type: "tween"`. Motion then runs the curve, but seeking chooses endpoints rather than rendering intermediate states. Sequences and property tracks do not expose a single transition; their `animate` values do not reproduce the intermediate choreography.

`clip.css` supplies `transitionDuration` and `transitionTimingFunction` for endpoint-based CSS transitions on single-curve clips. Easing maps to cubic Bézier; spring CSS output is an approximation. It does not provide scrubbing or automatically animate any element.

## Plain JavaScript timeline

Use the same clip config with a subscription for sampled frame updates. Mount the shared dock once; destroy timelines separately when their scene is removed.

```ts
import { createDialTimeline, createDialTimelineRoot } from 'dialkit/vanilla'
import 'dialkit/vanilla/styles.css'

export function mountCardTimeline(card: HTMLElement, replayButton: HTMLButtonElement) {
  const dock = createDialTimelineRoot()
  // TODO(production): Replace sampled current bindings with equivalent production
  // animation using tuned timings/curves before removing the controller and dock.
  const timeline = createDialTimeline('Card', {
    enter: {
      at: 0,
      duration: 0.6,
      from: { y: 24, opacity: 0 },
      to: { y: 0, opacity: 1 },
      transition: { type: 'spring', bounce: 0.2 },
    },
  }, { autoplay: false })
  const unsubscribe = timeline.subscribe(values => {
    card.style.opacity = String(values.enter.current.opacity)
    card.style.transform = `translateY(${values.enter.current.y}px)`
  })
  const replay = () => timeline.replay()
  replayButton.addEventListener('click', replay)

  return () => {
    replayButton.removeEventListener('click', replay)
    unsubscribe()
    timeline.destroy()
    dock.destroy()
  }
}
```

The controller also exposes `id`, `values`, `getValues()`, `updateConfig(config)`, and transport methods. `subscribe` runs immediately by default. `dock.setVisible(boolean)` toggles the editor; `dock.update({ visible, onVisibilityChange })` supports controlled visibility. For a custom clock, `formatClock(seconds, tenths?)` is exported by `dialkit`, `dialkit/vanilla`, and `dialkit/timeline`.

## Production handoff

Treat the Timeline as an authoring system. Do not remove or convert it until the user explicitly asks to finalize the animation for production.

1. Generate the timeline with `clip.current` and the `TODO(production)` comment shown above.
2. Tune and scrub the animation in its real interface context.
3. Use Copy to bake the tuned values into the `useDialTimeline` configuration. Keep `clip.current` during authoring.
4. When explicitly asked to finalize, inspect both the timeline configuration and every consumer of its values.
5. Inventory marker consumers such as `started`, `active`, and `progress`; zero-duration clips can be easy to miss because they have no `current` values.
6. Translate the tuned choreography and every discrete marker boundary to the application's existing animation runtime or state sequence (Motion, CSS, WAAPI, or another chosen runtime).
7. Remove DialKit only after every value binding, marker consumer, transport call, hook, component, and unused import has been replaced.

Use this mapping as a guide, not as a blind textual rewrite:

- `at` → delay or sequence offset relative to the application's trigger
- `from` / `to` → Motion `initial` / `animate` or imperative animation controls
- Spring transition → pass the tuned spring parameters to Motion
- Easing transition → translate to Motion's equivalent duration/ease tween
- `steps` → keyframes or an imperative animation sequence
- `props` → independently timed property keyframes or controls
- Marker `started` / `active` / `progress` → an equivalent reversible discrete state boundary or finite custom effect at the same offset
- Clip loop → Motion repetition
- Timeline loop region → an explicit intro followed by a repeated production sequence
- `replay()` or other transport calls → application state or Motion controls
- Expressions combining multiple `current` values → equivalent composed production behavior

Preserve behavior before removing DialKit. Do not assume that copying values alone performs this conversion.

## Output rules

1. Generate complete, copy-paste-ready code for the project's framework, using the matching adapter and returned-value access pattern.
2. Mount `DialTimeline` once and only when Timeline is used.
3. Prefer `clip.current` for authoring and apply every returned value to the actual interface.
4. Preserve the application's existing triggers and value-composition expressions.
5. Keep clip structure, sequences, and loops explicit in code.
6. Use zero-duration markers plus `started` for reversible timeline events; never substitute timers or attach irreversible external side effects to the playhead.
7. Add the `TODO(production)` handoff comment immediately above every generated timeline hook/function call.
8. Do not convert to production Motion or remove DialKit unless explicitly requested.
9. When finalizing, verify that all DialKit timeline hooks/controllers, docks, sampled bindings, marker consumers, and transport calls for the finalized animation have been replaced. Preserve unrelated parameter panels or other timelines.

Validated against DialKit 2.0.0, source commit `d408597c85b118dc497a209c5f1dc396922f8cc7`. See the [upstream timeline guide](https://github.com/joshpuckett/dialkit/blob/main/docs/timeline.md) and installed adapter types for further API details.
