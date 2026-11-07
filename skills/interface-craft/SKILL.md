---
name: interface-craft
description: "Interface Craft by Josh Puckett — a toolkit for polished, animated interfaces. Includes Storyboard Animation for readable React animation sequences, DialKit 2.0 for live controls and a scrubbable animation timeline across React, Solid, Svelte, Vue, and plain JavaScript, and Design Critique for systematic UI review. Use for animation, transitions, choreography, springs, easing, timelines, clips, markers, scrubbing, looping, replay, DialKit panels, sliders, XY pads, color/image controls, presets, tuning, or interface critique and refinement."
---

# Interface Craft

**By Josh Puckett**

A toolkit for building polished, animated interfaces. Write animations you can read like a script, then tune them with live controls.

---

## Skills

| Skill | When to Use | Invoke |
| --- | --- | --- |
| [Storyboard Animation](storyboard-animation.md) | Writing or refactoring multi-stage animations into a human-readable DSL | `/interface-craft storyboard` or describe an animation |
| [DialKit 2.0](dialkit.md) | Adding live panels, XY pads, image/color controls, transition editors, or application-driven value updates | `/interface-craft dialkit` or mention DialKit/controls/tuning |
| [DialKit Timeline](dialkit-timeline.md) | Tuning choreography, sequences, property tracks, loops, or reversible state changes with a scrubbable timeline | Mention timeline/clips/markers/scrubbing |
| [Design Critique](design-critique.md) | Systematic UI critique of a screenshot, component, or page | `/interface-craft critique` or paste a screenshot for review |

## Quick Start

### Storyboard Animation

Turn any animation into a readable storyboard with named timing, config objects, and stage-driven sequencing:

```tsx
/* ─────────────────────────────────────────────────────────
 * ANIMATION STORYBOARD
 *
 *    0ms   waiting for scroll into view
 *  300ms   card fades in, scale 0.85 → 1.0
 *  900ms   heading highlights
 * 1500ms   rows slide up (staggered 200ms)
 * ───────────────────────────────────────────────────────── */

const TIMING = {
  cardAppear:  300,   // card fades in
  heading:     900,   // heading highlights
  rows:        1500,  // rows start staggering
};
```

See [storyboard-animation.md](storyboard-animation.md) for the full pattern spec.

### DialKit

Generate live control panels for tuning values in real time. For example, in React:

```tsx
const params = useDialKit('Card', {
  scale: [1, 0.5, 2],
  blur: [0, 0, 100],
  position: { type: 'pad' },
  spring: { type: 'spring', visualDuration: 0.3, bounce: 0.2 },
})
```

See [dialkit.md](dialkit.md) for setup, all control types, controllers, presets, and framework adapters. Transition controls return a spring/easing union; follow its Motion conversion guidance when applying them.

The DialKit guidance targets **2.0.0**. For clip timing, sequences, property tracks, loops, replayable animations, timeline markers/events, or scrubbing, read and follow [dialkit-timeline.md](dialkit-timeline.md). Panels and timelines use separate authoring surfaces and can be used together.

## Sub-Skill Routing

When the user invokes `/interface-craft`:

1. **With `timeline`, clips, markers, timeline events, playhead, scrubbing, sequence-timing, intro-then-loop, or replayable-animation context** → Load and follow [dialkit-timeline.md](dialkit-timeline.md)
2. **With `dialkit`, dials, sliders, XY pads, image/color controls, Bézier editing, presets, controllers, tune, or tweak context** → Load and follow [dialkit.md](dialkit.md)
3. **With `storyboard` or general animation-choreography context** → Load and follow [storyboard-animation.md](storyboard-animation.md)
4. **With `critique`, a pasted image, or review-related context** → Load and follow [design-critique.md](design-critique.md)
5. **With a file path** → Read the file, detect whether it needs storyboard refactoring, DialKit panels, a DialKit timeline, or a design critique, and apply the appropriate skill
6. **With a plain-English description of an animation** → Use storyboard-animation unless the request emphasizes live timing, clips, or scrubbing
7. **Ambiguous** → Ask which skill to use

## Design Principles

1. **Readable over clever** — Anyone should be able to scan the top of a file and understand the animation sequence without reading implementation code
2. **Tunable by default** — Every value that affects timing or appearance should be a named constant, trivially adjustable
3. **Data-driven** — Repeated elements use arrays and `.map()`, not copy-pasted blocks
4. **Explicit sequencing** — Storyboards use stage state; DialKit timelines derive animated values and reversible marker state from the playhead
5. **Spring-first** — Prefer spring physics over duration-based easing for natural motion
6. **Authoring-aware** — Use DialKit's scrubbable timeline preview while tuning, then translate the tuned choreography to the app's real animation system when explicitly finalizing for production
