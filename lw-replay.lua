package.path = package.path..";./?.lua;./?/init.lua;"

require 'config'
require 'irc'
cjson = require 'cjson'
require 'quotes'
a,pass = pcall(require, 'password')
if a then config.password = pass end



local sleep = require 'socket'.sleep


local s = irc.new{nick = config.nick, username = config.username, realname = config.realname}

s:hook('OnChat', function(user, channel, message)
	if message:match('%.ff') then
		local newspeed = tonumber(message:match(' (%.*)'))
		newUtcAdjust = -os.clock()*speed+utcAdjust+os.clock()*newspeed
		speed = newspeed
	elseif message:match('%.skip') then
		local offset = tonumber(message:match(' (%d*)'))
		--local cur = logs:seek('cur', offset)
		for i = 1, offset do
			m = cjson.decode(logs:read('*l'))
		end
	elseif message:lower():match('%.setutc') then
		local utc = tonumber(message:match(' (.*)'))
		utcAdjust=utc-os.clock()*speed
		while utc>m[2] do
			if not logs:seek('cur', 10000) then error("Gone to far, bug that needs fixed") end
			logs:read('*l')
			m = cjson.decode(logs:read('*l'))
		end
		while utc < m[2] do
			if not logs:seek('cur', -10000) then
				logs:seek('set')
			end
			logs:read('*l')
			m = cjson.decode(logs:read('*l'))
		end
		while utc > m[2] do
			m = cjson.decode(logs:read('*l'))
		end
	elseif message:match('%.utc') then
		s:sendChat(channel, tostring(os.clock()*speed+utcAdjust))
	elseif message:match('%topic') then
		setTopic()
	elseif message:match('%.help') then
		s:sendChat(channel, 'Available Commands: ff, .skip, .setutc, .utc, .topic')
	end
end)

function setTopic()
	local topic = ('TOPIC %s :#lesswrong history, replayed by a bot. "%s" Type .help for help. Code at https://github.com/Houshalter/lw-replay'):format(config.mainChannel, quotes[math.random(#quotes)])
	print(topic)
	s:send(topic)
end



s:connect(config.server)

for i, channel in ipairs(config.channels) do
	s:join(channel)
end
s:sendChat('NickServ', 'identify '..config.password)
logs = io.open(config.dataFileName, "r")
m = cjson.decode(logs:read('*l'))
utcAdjust = os.clock()+20+m[2]
speed = 1
topicTime = os.clock()-60*60+20
math.randomseed(os.time())
while true do
	s:think()
	if os.clock()*speed > m[2]-utcAdjust then
		local nick = m[3]:match('(.-)!')
		local pNick = nick..(' '):rep(math.max(nick:len()-config.padding, 0))
		local toSend = ('_%s: %s'):format(pNick, m[4])
		s:sendChat(config.mainChannel, toSend)
		sleep(config.refeshRate)
		m = cjson.decode(logs:read('*l'))
	end
	if os.clock() > topicTime+60*60 then
		topicTime = os.clock()
		setTopic()
	end
end
