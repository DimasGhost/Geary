local Replay = display.newGroup()

function Replay.init()
    local Utils = require("scripts.utils")
    local Screen = require("scripts.screen")
    local Game = require("scripts.game")

    Utils.inherit(Replay, Screen)

    Replay.x, Replay.y = Utils.cx, Utils.cy + 700

    Replay.title = Utils.create_text('GAME OVER', 120, 'blood', Utils.cx, Utils.cy - 420, Replay)
    Replay.score = Utils.create_text('SCORE', 80, 'brown', Utils.cx + 130, Utils.cy - 280, Replay)
    Replay.score_cnt = Utils.create_text('0', 150, 'brown', Utils.cx + 130, Utils.cy - 160, Replay)
    Replay.best = Utils.create_text('BEST', 70, 'brown', Utils.cx - 130, Utils.cy - 250, Replay)
    Replay.best_cnt = Utils.create_text('0', 100, 'brown', Utils.cx - 130, Utils.cy - 150, Replay)
    Replay.play = Utils.create_text('TAP TO PLAY', 60, 'blood', Utils.cx, Utils.cy + 430, Replay)

    Replay.new_score = display.newGroup()
    Replay:insert(Replay.new_score)
    Replay.new_score_text = Utils.create_text('NEW HIGHSCORE', 45, 'brown', Utils.cx, Utils.cy - 505, Replay.new_score)
    Replay.left_star = Utils.create_image('star', Utils.cx - 170, Utils.cy - 505, 1, Replay.new_score, true, 'yellow')
    Replay.right_star = Utils.create_image('star', Utils.cx + 160, Utils.cy - 505, 1, Replay.new_score, true, 'yellow')

    Replay.buttons = {}

    Replay.home_but = Replay:create_button('home', Utils.cx - 200, Utils.cy + 50, Replay.home)
    Replay.share_but = Replay:create_button('share', Utils.cx, Utils.cy + 50, Replay.share)
    Replay:create_sound_button()


    Replay.rotation = 180 * Game.dir
end

function Replay.home()
    local Menu = require('scripts.menu')

    Replay:hide(true)
    Menu:show()
end

function Replay.share()
    local analytics = require('analytics')
    local Utils = require('scripts.utils')
    local Game = require('scripts.game')
    analytics.logEvent('ShareButton')
    local options = {
        service = 'share',
        message = 'I just scored ' .. Game.score.text .. ' in Geary! #android #geary',
        url = Utils.game_http_link
    }
    native.showPopup('social', options)
end

function Replay.on_call()
    local Game = require('scripts.game')
    local Utils = require('scripts.utils')

    Replay.score_cnt.text = Game.score.text
    Replay.best_cnt.text = Utils.data_table.score

    Replay.new_score.isVisible = Game.new_best_score
end

function Replay.on_tap(event)
    local Game = require('scripts.game')
    if event.y > 800 then
        Replay:hide()
        timer.performWithDelay(500, Game.start)
    end
end

Replay.init()

return Replay