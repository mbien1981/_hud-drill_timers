local module = DMod:new("_hud-drill_timers", {
	name = "_hud-drill_timers",
	description = "Standalone drill times.",
	author = "_atom",
	version = "2.1-final",
	dependencies = { "[_hud]" },
	categories = { "hud", "QoL", "gameplay" },
})

module:hook_post_require("lib/units/beings/player/playerbase", "hooks/drill_timers")
module:hook_post_require("lib/units/props/timergui", "hooks/drill_timers")
module:hook_post_require("lib/units/props/securitylockgui", "hooks/drill_timers")

module:hook_post_require("lib/setups/setup", "classes/toolbox")
module:hook_post_require("lib/setups/setup", "classes/updator")
module:hook_post_require("core/lib/setups/coresetup", "classes/updator")

return module
