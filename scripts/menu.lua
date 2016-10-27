local Menu = display.newGroup()

function Menu.init()
    local Utils = require("scripts.utils")
    local Screen = require("scripts.screen")

    Utils.inherit(Menu, Screen)

    Menu.x, Menu.y = Utils.cx, Utils.cy + 700

    Menu.title = Utils.create_text('GEARY', 140, 'blood', Utils.cx, Utils.cy - 200, Menu)
    Menu.play = Utils.create_text('TAP TO PLAY', 60, 'blood', Utils.cx, Utils.cy + 430, Menu)

    Menu.buttons = {}

    Menu.rate_but = Menu:create_button('rate', Utils.cx - 200, Utils.cy + 50, Menu.rate)
    Menu.lead_but = Menu:create_button('leaderboard', Utils.cx, Utils.cy + 50, Menu.leaderboard)
    Menu:create_sound_button()

    Menu.rotation = 180

    local function shake_title()
        Utils.shake_button(Menu.title)
    end

    Menu.title:addEventListener('tap', shake_title)
end


function Menu.rate()
    local analytics = require('analytics')
    local Utils = require('scripts.utils')
    analytics.logEvent('RateButton')
    system.openURL(Utils.game_market_link)
end

function Menu.leaderboard()
    local analytics = require('analytics')
    local Utils = require('scripts.utils')

    local function on_refuse()
        Utils.shake_button(Menu.lead_but)
    end

    local function on_load()
        analytics.logEvent('Leaderboard')
        Utils.stop_button(Menu.lead_but)
    end

    local google_gs = require('scripts.google_gs')
    google_gs.ask_leaderboard(on_load, on_refuse)

    Utils.loading_button(Menu.lead_but)
end

function Menu.on_tap(event)
    local Game = require("scripts.game")
    if event.y > 800 then
        Menu:hide()
        timer.performWithDelay(500, Game.start)
    end
end

Menu.init()

return Menu