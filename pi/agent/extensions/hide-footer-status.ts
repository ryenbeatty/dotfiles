/**
 * hide-footer-status.ts
 *
 * Suppresses selected extension statuses from Pi's footer strip.
 *
 * Why this exists: some extension packages call `ctx.ui.setStatus()` unconditionally
 * and expose no setting to turn it off:
 *   - @sysid/pi-sandbox    -> "sandbox"  (index.ts:415, inside on("session_start"))
 *   - pi-mcp-adapter       -> "mcp"      (init.ts:406 / index.ts:1785)
 *
 * The MCP one has a supported switch (settings.mcpFooterStatus: "off" in
 * mcp-adapter.json), so it is cleared here only as a belt-and-braces fallback.
 *
 * The sandbox status is set after `await SandboxManager.initialize()`, so its
 * session_start handler may resolve after ours. Clearing is idempotent, so we
 * clear on session_start (immediately and again shortly after) and on later
 * events that are guaranteed to fire after startup completed.
 *
 * Nothing is hidden from you permanently: `/sandbox` and `/mcp-adapter status`
 * still report the full state on demand.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const HIDDEN_KEYS = ["sandbox", "mcp"] as const;

export default function (pi: ExtensionAPI) {
	const clearHiddenStatuses = (ctx: { ui: { setStatus: (key: string, text: string | undefined) => void } }) => {
		for (const key of HIDDEN_KEYS) ctx.ui.setStatus(key, undefined);
	};

	pi.on("session_start", async (_event, ctx) => {
		clearHiddenStatuses(ctx);
		// Sandbox init is async; clear once more after it has had a chance to land.
		setTimeout(() => clearHiddenStatuses(ctx), 50);
	});

	// Later lifecycle events: if an extension re-sets a status, this clears it again.
	pi.on("agent_start", async (_event, ctx) => clearHiddenStatuses(ctx));
	pi.on("turn_start", async (_event, ctx) => clearHiddenStatuses(ctx));
}
