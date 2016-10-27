local Utils = require("scripts.utils")
local Tutorial = require('scripts.tutorial')
local Menu = require("scripts.menu")
local Replay = require("scripts.replay")
local Game = require("scripts.game")
local ads_control = require("scripts.ads_control")
local google_gs = require("scripts.google_gs")
local analytics = require("analytics")

system.setIdleTimer(false)
display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", Utils.color("white"))
math.randomseed(os.time())
audio.setVolume(Utils.data_table.sound and 1 or 0)

analytics.init('XGN5DF5M6NFRHTWR2P6G')
analytics.logEvent('market', {market = 'getjar'})

local author = Utils.create_text('BY MAUNT', 64, 'brown', Utils.cx, Utils.cy - 400)

local function start()
	transition.to(author, {alpha = 0, time = 1200})
	Menu:show()
	Replay:hide(true)
	Game.hide()
end
timer.performWithDelay(1000, start)