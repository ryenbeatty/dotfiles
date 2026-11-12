/**
 * Prompt Pin
 *
 * Keeps the last prompt you sent pinned to the top of the window.
 *
 * - Two lines max. Anything longer ends with an ellipsis on the second line.
 * - Generous padding: three columns left and right, one blank row above and below.
 * - Rendered as a non-capturing overlay, so the editor keeps focus, keybindings and
 *   the transcript scrollbar all keep working.
 * - Fills the full width with the user-message background so transcript lines never
 *   bleed through it.
 *
 * `/pin` hides or shows the band. `/reload` picks up edits to this file.
 */

import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import type { Component, OverlayHandle, TUI } from "@earendil-works/pi-tui";
import {
	sliceByColumn,
	stripTerminalSequences,
	truncateToWidth,
	visibleWidth,
	wrapTextWithAnsi,
} from "@earendil-works/pi-tui";

/** Prompt lines shown, not counting padding. */
const MAX_LINES = 2;
/** Columns of padding left and right of the text. */
const PAD_X = 3;
/** Blank rows above and below the text. */
const PAD_Y = 1;
const ELLIPSIS = "…";

/**
 * The pinned band. Colors are resolved on every render and the theme object is a live
 * proxy, so a theme change needs no cache invalidation here.
 */
class PromptPin implements Component {
	private readonly tui: TUI;
	private readonly theme: Theme;
	private text: string | undefined;

	constructor(tui: TUI, theme: Theme, text: string | undefined) {
		this.tui = tui;
		this.theme = theme;
		this.text = text;
	}

	setText(text: string | undefined): void {
		if (text === this.text) return;
		this.text = text;
		this.tui.requestRender();
	}

	invalidate(): void {
		// Nothing is cached, so there is nothing to drop.
	}

	render(width: number): string[] {
		const padX = width >= PAD_X * 2 + 8 ? PAD_X : 0;
		const inner = Math.max(1, width - padX * 2);
		const body = clampToLines(this.text, inner);
		if (body.length === 0) return [];

		const paint = (line: string) => this.theme.bg("userMessageBg", line);
		const blank = paint(" ".repeat(width));

		const lines: string[] = [];
		for (let i = 0; i < PAD_Y; i++) lines.push(blank);
		for (const line of body) {
			const slack = Math.max(0, inner - visibleWidth(line));
			lines.push(paint(" ".repeat(padX) + line + " ".repeat(padX + slack)));
		}
		for (let i = 0; i < PAD_Y; i++) lines.push(blank);
		return lines;
	}
}

/** Drop ANSI, normalize newlines, expand tabs, strip trailing spaces. */
function normalizePrompt(text: string): string {
	return stripTerminalSequences(text)
		.replace(/\r\n?/g, "\n")
		.replace(/[\u0000-\u0008\u000b-\u001f\u007f]/g, " ")
		.replace(/\t/g, "    ")
		.replace(/[ \t]+$/gm, "")
		.trim();
}

/** Wrap the prompt to `width` and cut it down to MAX_LINES, ellipsis included. */
function clampToLines(text: string | undefined, width: number): string[] {
	if (!text) return [];
	const clean = normalizePrompt(text);
	if (!clean) return [];

	const wrapped = wrapTextWithAnsi(clean, width).map((line) => truncateToWidth(line, width, ""));
	while (wrapped.length > 0 && wrapped[0] === "") wrapped.shift();
	while (wrapped.length > 0 && wrapped[wrapped.length - 1] === "") wrapped.pop();
	if (wrapped.length === 0) return [];
	if (wrapped.length <= MAX_LINES) return wrapped;

	const kept = wrapped.slice(0, MAX_LINES);
	const last = kept[MAX_LINES - 1] ?? "";
	const keep = Math.max(0, width - visibleWidth(ELLIPSIS));
	// strict: never let a wide character poke past the last column
	const head = visibleWidth(last) > keep ? sliceByColumn(last, 0, keep, true) : last;
	kept[MAX_LINES - 1] = `${head}${ELLIPSIS}`;
	return kept;
}

/** Pull the prompt text out of a message, ignoring images and other blocks. */
function messageText(message: unknown): string | undefined {
	const content = (message as { content?: unknown } | undefined)?.content;
	if (typeof content === "string") {
		return content.trim() ? content : undefined;
	}
	if (Array.isArray(content)) {
		const parts: string[] = [];
		for (const block of content) {
			const candidate = block as { type?: unknown; text?: unknown };
			if (candidate?.type === "text" && typeof candidate.text === "string") parts.push(candidate.text);
		}
		return parts.join("\n").trim() ? parts.join("\n") : undefined;
	}
	return undefined;
}

/** The last prompt already in the session, for resume, fork, and reload. */
function readLastPrompt(ctx: ExtensionContext): string | undefined {
	const entries = ctx.sessionManager.getBranch();
	for (let i = entries.length - 1; i >= 0; i--) {
		const entry = entries[i] as { type?: unknown; message?: { role?: unknown } } | undefined;
		if (entry?.type !== "message" || entry.message?.role !== "user") continue;
		const text = messageText(entry.message);
		if (text) return text;
	}
	return undefined;
}

let pin: PromptPin | undefined;
let handle: OverlayHandle | undefined;
let mountToken = 0;
let lastPrompt: string | undefined;
let visible = true;

/** Show the overlay if it is not there yet. Returns whether a pin is mounted. */
function mount(ctx: ExtensionContext): boolean {
	if (!ctx.hasUI || !visible) return false;
	if (pin) return true;

	const token = ++mountToken;
	void ctx.ui
		.custom<void>(
			(tui, theme) => {
				pin = new PromptPin(tui, theme, lastPrompt);
				return pin;
			},
			{
				overlay: true,
				overlayOptions: { anchor: "top-center", width: "100%", margin: 0, nonCapturing: true },
				onHandle: (overlayHandle) => {
					if (token === mountToken) handle = overlayHandle;
				},
			},
		)
		.catch((error: unknown) => {
			ctx.ui.notify(`Prompt pin failed: ${error instanceof Error ? error.message : String(error)}`, "error");
		})
		.finally(() => {
			if (token !== mountToken) return;
			pin = undefined;
			handle = undefined;
		});

	return true;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		// A fresh session has no prompt yet, so the band stays away until you send one.
		lastPrompt = readLastPrompt(ctx);
		if (!lastPrompt) {
			pin?.setText(undefined);
			return;
		}
		if (mount(ctx)) pin?.setText(lastPrompt);
	});

	pi.on("message_start", async (event, ctx) => {
		if (!ctx.hasUI || event.message.role !== "user") return;
		const text = messageText(event.message);
		if (!text) return;
		lastPrompt = text;
		if (mount(ctx)) pin?.setText(text);
	});

	pi.registerCommand("pin", {
		description: "Hide or show the pinned prompt at the top of the window",
		handler: async (_args, ctx) => {
			visible = !visible;
			if (!visible) {
				handle?.setHidden(true);
				ctx.ui.notify("Prompt pin hidden", "info");
				return;
			}
			if (!mount(ctx)) {
				ctx.ui.notify("Prompt pin needs interactive mode", "warning");
				return;
			}
			handle?.setHidden(false);
			pin?.setText(lastPrompt);
			ctx.ui.notify("Prompt pin shown", "info");
		},
	});
}
