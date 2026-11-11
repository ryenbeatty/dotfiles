/**
 * DeepSeek Balance + Peak/Off-peak Pricing
 *
 * Shows your DeepSeek account balance, whether you are currently in the peak
 * or off-peak billing window, and the per-token price for the active model.
 *
 * The footer status is deliberately terse: `🐋 ¥12.34 · peak`. Unavailable
 * shows `🐋 ✕`, unknown balance `🐋 ?`, and a failed refresh `🐋 ⚠`.
 *
 * - Reads the API key from DEEPSEEK_API_KEY, falling back to
 *   ~/.pi/agent/models.json (providers.deepseek.apiKey).
 * - Refreshes on session start and after each agent turn.
 * - `/deepseek` (alias `/balance`) fetches and prints the full breakdown.
 *
 * Pricing and peak-window rules are from
 * https://api-docs.deepseek.com/quick_start/pricing — update HOLIDAYS_2026
 * and PRICING when DeepSeek changes them.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const BALANCE_URL = "https://api.deepseek.com/user/balance";
const STATUS_KEY = "deepseek-balance";

const CURRENCY_SYMBOLS: Record<string, string> = {
	CNY: "¥",
	USD: "$",
	EUR: "€",
	GBP: "£",
};

// ---- Balance types ---------------------------------------------------------

interface BalanceInfo {
	currency: string;
	total_balance: string;
	granted_balance: string;
	topped_up_balance: string;
}

interface BalanceResponse {
	is_available: boolean;
	balance_infos: BalanceInfo[];
}

// ---- Pricing (per 1M tokens) ----------------------------------------------

interface Rate {
	peak: number;
	offPeak: number;
}

interface ModelPricing {
	label: string;
	inputCacheHit: Rate;
	inputCacheMiss: Rate;
	output: Rate;
}

const PRICING: Record<string, ModelPricing> = {
	"deepseek-flash": {
		label: "DeepSeek V4.1 Flash",
		inputCacheHit: { peak: 0.006, offPeak: 0.003 },
		inputCacheMiss: { peak: 0.3, offPeak: 0.15 },
		output: { peak: 1.2, offPeak: 0.6 },
	},
	"deepseek-v4-pro": {
		label: "DeepSeek V4 Pro",
		inputCacheHit: { peak: 0.044, offPeak: 0.022 },
		inputCacheMiss: { peak: 1.32, offPeak: 0.66 },
		output: { peak: 3.96, offPeak: 1.98 },
	},
};

// ---- Peak / off-peak schedule ---------------------------------------------

// Peak windows are half-open [start, end) hours in UTC, Mon–Fri only.
const PEAK_WINDOWS: Array<[number, number]> = [
	[1, 4],
	[6, 10],
];

// 2026 Chinese public holidays. DeepSeek treats these whole days as off-peak,
// so peak hours do not apply. Update this list each year.
function dateRange(start: string, end: string): string[] {
	const out: string[] = [];
	const d = new Date(`${start}T00:00:00Z`);
	const last = new Date(`${end}T00:00:00Z`);
	while (d.getTime() <= last.getTime()) {
		out.push(d.toISOString().slice(0, 10));
		d.setUTCDate(d.getUTCDate() + 1);
	}
	return out;
}

const HOLIDAYS_2026: Set<string> = new Set([
	...dateRange("2026-01-01", "2026-01-01"), // New Year's Day
	...dateRange("2026-02-15", "2026-02-21"), // Spring Festival
	...dateRange("2026-04-04", "2026-04-06"), // Qingming
	...dateRange("2026-05-01", "2026-05-05"), // Labour Day
	...dateRange("2026-06-19", "2026-06-21"), // Dragon Boat
	...dateRange("2026-09-25", "2026-09-27"), // Mid-Autumn
	...dateRange("2026-10-01", "2026-10-07"), // National Day
]);

function isHoliday(date: Date): boolean {
	return HOLIDAYS_2026.has(date.toISOString().slice(0, 10));
}

function isPeakAt(date: Date): boolean {
	const day = date.getUTCDay();
	if (day === 0 || day === 6) return false; // weekend
	if (isHoliday(date)) return false;
	const hour = date.getUTCHours();
	return PEAK_WINDOWS.some(([start, end]) => hour >= start && hour < end);
}

function nextTransition(now: Date): Date {
	const current = isPeakAt(now);
	const stepMs = 15 * 60 * 1000;
	const limitMs = 8 * 24 * 60 * 60 * 1000;
	for (let t = now.getTime() + stepMs; t <= now.getTime() + limitMs; t += stepMs) {
		const d = new Date(t);
		if (isPeakAt(d) !== current) return d;
	}
	return new Date(now.getTime() + limitMs);
}

// ---- Formatting helpers ----------------------------------------------------

function getApiKey(): string | undefined {
	const fromEnv = process.env.DEEPSEEK_API_KEY?.trim();
	if (fromEnv) return fromEnv;

	try {
		const modelsPath = join(homedir(), ".pi", "agent", "models.json");
		const cfg = JSON.parse(readFileSync(modelsPath, "utf8")) as {
			providers?: { deepseek?: { apiKey?: string } };
		};
		const key = cfg?.providers?.deepseek?.apiKey?.trim();
		if (key) return key;
	} catch {
		// ignore malformed/missing models.json
	}

	return undefined;
}

function detectModel(): string {
	const raw = (process.env.PI_MODEL ?? "").toLowerCase();
	return raw.includes("pro") ? "deepseek-v4-pro" : "deepseek-flash";
}

function formatMoney(amount: string, currency: string): string {
	const symbol = CURRENCY_SYMBOLS[currency] ?? `${currency} `;
	const value = Number.parseFloat(amount);
	const text = Number.isFinite(value) ? value.toFixed(2) : amount;
	return `${symbol}${text}`;
}

function formatPrice(value: number): string {
	return value < 0.01 ? `$${value.toFixed(3)}` : `$${value.toFixed(2)}`;
}

function primaryInfo(res: BalanceResponse): BalanceInfo | undefined {
	return res.balance_infos?.[0];
}

function windowLabel(isPeak: boolean): string {
	return isPeak ? "peak" : "off-peak";
}

function formatTransition(date: Date): string {
	const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
	const hh = String(date.getUTCHours()).padStart(2, "0");
	const mm = String(date.getUTCMinutes()).padStart(2, "0");
	return `${days[date.getUTCDay()]} ${hh}:${mm} UTC`;
}

function relativeMinutes(ms: number): string {
	const mins = Math.max(0, Math.round(ms / 60000));
	const h = Math.floor(mins / 60);
	const m = mins % 60;
	return h === 0 ? `${m}m` : `${h}h ${m}m`;
}

// ---- Rendering -------------------------------------------------------------

function statusText(res: BalanceResponse, isPeak: boolean): string {
	const window = windowLabel(isPeak);
	if (!res.is_available) return `🐋 ✕ · ${window}`;
	const info = primaryInfo(res);
	if (!info) return `🐋 ? · ${window}`;
	return `🐋 ${formatMoney(info.total_balance, info.currency)} · ${window}`;
}

function detailText(res: BalanceResponse, model: ModelPricing, isPeak: boolean): string {
	const info = primaryInfo(res);
	const lines: string[] = ["🐋 balance"];

	if (!info) {
		lines.push("No balance information returned.");
	} else {
		const currency = info.currency || "CNY";
		lines.push(
			`Total:     ${formatMoney(info.total_balance ?? "0", currency)}`,
			`Topped up: ${formatMoney(info.topped_up_balance ?? "0", currency)}`,
			`Granted:   ${formatMoney(info.granted_balance ?? "0", currency)}`,
		);
	}

	const rate = (r: Rate): number => (isPeak ? r.peak : r.offPeak);
	lines.push(
		"",
		`Model: ${model.label}`,
		`Window: ${windowLabel(isPeak)} (${isPeak ? "full" : "50%"} price)`,
		"",
		"Token prices (per 1M tokens):",
		`Input  (cache hit) : ${formatPrice(rate(model.inputCacheHit))}`,
		`Input  (cache miss): ${formatPrice(rate(model.inputCacheMiss))}`,
		`Output             : ${formatPrice(rate(model.output))}`,
		"",
		`Peak: Mon–Fri 01:00–04:00 & 06:00–10:00 UTC (excl. CN holidays)`,
		`Next change: ${formatTransition(nextTransition(new Date()))}`,
	);

	return lines.join("\n");
}

// ---- Extension -------------------------------------------------------------

export default function deepseekBalance(pi: ExtensionAPI): void {
	async function fetchBalance(): Promise<BalanceResponse> {
		const key = getApiKey();
		if (!key) {
			throw new Error(
				"no API key found (set DEEPSEEK_API_KEY or add providers.deepseek.apiKey to ~/.pi/agent/models.json)",
			);
		}
		const res = await fetch(BALANCE_URL, {
			headers: { Authorization: `Bearer ${key}`, Accept: "application/json" },
		});
		if (!res.ok) {
			throw new Error(`balance API returned HTTP ${res.status}`);
		}
		return (await res.json()) as BalanceResponse;
	}

	async function show(ctx: ExtensionContext, opts: { detail?: boolean; quiet?: boolean } = {}): Promise<void> {
		try {
			const data = await fetchBalance();
			const isPeak = isPeakAt(new Date());
			const color = isPeak ? "warning" : "accent";
			ctx.ui.setStatus(STATUS_KEY, ctx.ui.theme.fg(color, statusText(data, isPeak)));
			if (opts.detail) {
				ctx.ui.notify(detailText(data, PRICING[detectModel()], isPeak), "info");
			}
		} catch (err) {
			ctx.ui.setStatus(STATUS_KEY, ctx.ui.theme.fg("warning", "🐋 ⚠"));
			if (!opts.quiet) {
				ctx.ui.notify(`🐋 ${(err as Error).message}`, "error");
			}
		}
	}

	pi.registerCommand("deepseek", {
		description: "Show DeepSeek balance and peak/off-peak token pricing",
		handler: async (_args, ctx) => show(ctx, { detail: true }),
	});

	pi.registerCommand("balance", {
		description: "Alias for /deepseek",
		handler: async (_args, ctx) => show(ctx, { detail: true }),
	});

	// Initial value, then keep the status bar current as usage accrues.
	pi.on("session_start", async (_event, ctx) => show(ctx, { quiet: true }));
	pi.on("agent_end", async (_event, ctx) => show(ctx, { quiet: true }));
}
