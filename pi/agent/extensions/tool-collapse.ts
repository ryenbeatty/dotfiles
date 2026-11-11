/**
 * Tool Collapse — keep every tool call to a single line.
 *
 * Collapsed (default): two one-line rows per call, never more, no matter how
 * much output the tool produced:
 *
 *   ● bash npm test -- --watch=false
 *     └ exit 1 · 42 lines · 2.4s
 *
 * Expanded: the tool's own call line plus its full output, unchanged content.
 * Toggling uses the existing "expand tools" keybinding, so nothing new to learn.
 *
 * The wrapper applies to *every* tool, including MCP tools and tools registered
 * later, because it is installed as a renderer resolver rather than per tool.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { type Component, truncateToWidth } from "@earendil-works/pi-tui";
import { isAbsolute, relative, resolve } from "node:path";

type Theme = { fg(color: string, text: string): string; bold(text: string): string };
type Args = Record<string, unknown>;

const ARG_MAX = 96;
const NAME_MAX = 22;

function str(value: unknown): string | undefined {
	return typeof value === "string" && value.length > 0 ? value : undefined;
}

/** Collapse newlines/tabs so a command or path can never wrap to a second row. */
function flat(text: string): string {
	return text.replace(/\s+/g, " ").trim();
}

function clip(text: string, max = ARG_MAX): string {
	return text.length <= max ? text : `${text.slice(0, max - 1)}…`;
}

/** Path relative to cwd when inside it, otherwise as given. */
export function shortPath(raw: string | undefined, cwd: string): string {
	if (!raw) return "";
	const abs = isAbsolute(raw) ? raw : resolve(cwd, raw);
	const rel = relative(cwd, abs);
	return rel && !rel.startsWith("..") ? rel : raw;
}

/** The most useful argument for a tool, on one line. */
export function summarizeCall(toolName: string, args: Args, cwd: string): string {
	const path = shortPath(str(args.file_path) ?? str(args.path), cwd);

	switch (toolName) {
		case "read": {
			const offset = typeof args.offset === "number" ? args.offset : undefined;
			const limit = typeof args.limit === "number" ? args.limit : undefined;
			const range =
				offset === undefined && limit === undefined
					? ""
					: limit === undefined
						? ` [${offset}+]`
						: ` [${offset ?? 1}-${(offset ?? 1) + limit - 1}]`;
			return clip(`${path}${range}`);
		}
		case "write":
			return clip(path);
		case "edit": {
			const count = Array.isArray(args.edits) ? args.edits.length : undefined;
			return clip(count && count > 1 ? `${path} (${count} edits)` : path);
		}
		case "bash":
		case "shell":
		case "powershell":
			return clip(flat(str(args.command) ?? ""));
		case "grep":
		case "search": {
			const pattern = str(args.pattern) ?? str(args.regex);
			return clip([pattern ? `/${pattern}/` : "", path].filter(Boolean).join(" "));
		}
		case "find":
		case "glob":
		case "ls":
		case "list":
			return clip(str(args.pattern) ?? path);
		case "webfetch":
		case "fetch":
			return clip(str(args.url) ?? "");
		case "websearch":
			return clip(str(args.query) ?? "");
		default: {
			const first = Object.values(args).find((value) => typeof value === "string") as string | undefined;
			if (first) return clip(flat(first));
			try {
				return clip(JSON.stringify(args));
			} catch {
				return "";
			}
		}
	}
}

export function textOf(result: unknown): { text: string; images: number } {
	let text = "";
	let images = 0;
	const content = (result as { content?: unknown })?.content;
	if (Array.isArray(content)) {
		for (const part of content) {
			if (!part || typeof part !== "object") continue;
			const typed = part as { type?: string; text?: unknown };
			if (typed.type === "image") images += 1;
			else if (typeof typed.text === "string") text += (text ? "\n" : "") + typed.text;
		}
	} else if (typeof content === "string") {
		text = content;
	}
	return { text, images };
}

/** One line describing what the tool produced. */
export function summarizeResult(toolName: string, result: unknown, isError: boolean): string {
	const { text, images } = textOf(result);
	const body = text.trim();
	const lines = body ? body.split("\n").length : 0;

	if (isError || (result as { isError?: boolean })?.isError) {
		// A failing shell command is more informative as its exit status than as
		// the first line of its output.
		const exitCode = body.match(/Command exited with code (\d+)/)?.[1];
		if (exitCode) return `failed · exit ${exitCode}`;
		const first = body.split("\n").find((line) => line.trim()) ?? "failed";
		return `failed: ${clip(flat(first), 80)}`;
	}
	if (images > 0 && lines === 0) return `${images} image${images === 1 ? "" : "s"}`;

	switch (toolName) {
		case "bash":
		case "shell":
		case "powershell": {
			// The bash tool appends its exit status to the text instead of `details`.
			const exitCode = body.match(/Command exited with code (\d+)/)?.[1];
			const parts: string[] = [];
			if (exitCode) parts.push(`exit ${exitCode}`);
			if (lines > 1) parts.push(`${lines} lines`);
			else if (lines === 1 && !exitCode) parts.push(clip(flat(body), 60));
			return parts.join(" · ") || "no output";
		}
		case "read":
			return images > 0 ? `${images} image${images === 1 ? "" : "s"}` : `${lines} line${lines === 1 ? "" : "s"}`;
		case "edit":
			return "applied";
		case "write":
			return lines ? `wrote ${lines} line${lines === 1 ? "" : "s"}` : "written";
		default:
			if (lines === 0) return "done";
			return lines === 1 ? clip(flat(body), 80) : `${lines} lines`;
	}
}

function duration(durationMs: number | undefined): string {
	if (typeof durationMs !== "number" || durationMs <= 0) return "";
	if (durationMs < 100) return ` · ${Math.round(durationMs)}ms`;
	const seconds = durationMs / 1000;
	return ` · ${seconds < 10 ? seconds.toFixed(1) : Math.round(seconds)}s`;
}

/** `mcp__figma__get_screenshot_file` reads better as `figma:get_screenshot_file`. */
function displayName(toolName: string): string {
	let name = toolName;
	if (name.startsWith("mcp__")) {
		const [, server, ...rest] = name.split("__");
		if (server) name = `${server}:${rest.join("__")}`;
	}
	return name.length > NAME_MAX ? `${name.slice(0, NAME_MAX - 1)}…` : name;
}

/**
 * Fixed-height component: `set()` replaces the text, `render()` truncates each
 * line to the viewport so a long command can never wrap into a second row.
 */
class OneLine implements Component {
	private lines: string[] = [];

	set(lines: string[]): void {
		this.lines = lines;
	}

	render(width: number): string[] {
		return this.lines.map((line) => truncateToWidth(line, width));
	}

	/**
	 * No cached state to drop: the renderers rebuild the text on every call, so
	 * clearing here would blank the row if pi invalidates without re-rendering.
	 */
	invalidate(): void {}
}

export default function toolCollapse(pi: ExtensionAPI) {
	pi.registerToolRenderer((toolName) => ({
		renderCall(args, theme: Theme, context) {
			const component =
				context.lastComponent instanceof OneLine ? context.lastComponent : new OneLine();
			const name = displayName(toolName);
			const detail = summarizeCall(toolName, (args ?? {}) as Args, context.cwd);
			component.set([`${theme.fg("muted", "● ")}${theme.fg("toolTitle", theme.bold(name))} ${theme.fg("toolOutput", detail)}`.trimEnd()]);
			return component;
		},

		renderResult(result, options, theme: Theme, context) {
			const component =
				context.lastComponent instanceof OneLine ? context.lastComponent : new OneLine();
			const { text } = textOf(result);
			const body = text.trim();
			const color = context.isError ? "error" : "muted";

			if (options.expanded) {
				const summary = summarizeResult(toolName, result, context.isError);
				component.set([
					`${theme.fg("muted", "  └ ")}${theme.fg(color, summary)}${theme.fg("muted", duration(context.durationMs))}`,
					...(body ? body.split("\n").map((line) => theme.fg("toolOutput", line)) : []),
				]);
			} else {
				const summary = summarizeResult(toolName, result, context.isError);
				component.set([
					`  ${theme.fg(color, `└ ${summary}`)}${theme.fg("muted", duration(context.durationMs))}`,
				]);
			}
			return component;
		},
	}));
}
