local google_gs = {
	on_init_net = {},
	on_login = {},
	on_send_score = {},
	on_error = {},
	on_show_leaderboard = {},
	leaderboard = 'CgkIgLrescsDEAIQBQ'
}

function google_gs.init()
	google_gs.net = require('gameNetwork')
end

function google_gs.error()
	for i = 1, #google_gs.on_error do
		google_gs.on_error[i]()
	end
end

function google_gs.init_net()
	if system.getInfo('environment') == 'simulator' then
		timer.performWithDelay(20, google_gs.error)
	else
		google_gs.net.init('google', google_gs.init_net_listener)
	end
end

function google_gs.init_net_listener(event)
	if not event.isError then
		for i = 1, #google_gs.on_init_net do
			google_gs.on_init_net[i]()
		end
	else
		google_gs.error()
	end
end

function google_gs.login()
	google_gs.net.request('login', {user_initiated = true, listener = google_gs.login_listener})
end

function google_gs.login_listener(event)
	if (not event.data) or (not event.data.isError) then
		for i = 1, #google_gs.on_login do
			google_gs.on_login[i]()
		end
	else
		google_gs.error()
	end
end

function google_gs.send_score()
	local Utils = require('scripts.utils')
	local score = {
		category = google_gs.leaderboard,
		value = Utils.data_table.score
	}
	google_gs.net.request('setHighScore', {localPlayerScore = score, listener = google_gs.send_score_listener})
end

function google_gs.send_score_listener(event)
	for i = 1, #google_gs.on_send_score do
		google_gs.on_send_score[i]()
	end
end

function google_gs.load_score()
	local leaderboard = {
        category = google_gs.leaderboard,
        playerScope = "Global",
        timeScope = "AllTime",
        range = {1, 1},
        playerCentered = true
    }
    google_gs.net.request('loadScores', {leaderboard = leaderboard, listener = google_gs.load_score_listener})
end

function google_gs.load_score_listener(event)
	local Utils = require('scripts.utils')
	if event.data.value > Utils.data_table.score then
		Utils.change_data_table({score = event.data.value})
	end
end

function google_gs.sync_scores()
	google_gs.load_score()
	google_gs.send_score()
end

function google_gs.show_leaderboard()
	for i = 1, #google_gs.on_show_leaderboard do
		google_gs.on_show_leaderboard[i]()
	end
	google_gs.net.show('leaderboards')
end

function google_gs.loaded()
	google_gs.is_loading = nil
end

function google_gs.ask_leaderboard(on_success, on_fail)
	if google_gs.is_loading then
		return
	end
	google_gs.is_loading = true
	google_gs.on_error = {on_fail, google_gs.loaded}
	google_gs.on_show_leaderboard = {on_success, google_gs.loaded}
	google_gs.on_send_score = {google_gs.show_leaderboard}
	if google_gs.net.request('isConnected') then
		google_gs.sync_scores()
	else
		google_gs.on_init_net = {google_gs.login}
		google_gs.on_login = {google_gs.sync_scores}
		google_gs.init_net()
	end
end

google_gs.init()

return google_gs