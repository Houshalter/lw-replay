package.path = package.path..";./?.lua;./?/init.lua;"

require 'config'
require 'irc'
cjson = require 'cjson'
require 'quotes'



local sleep = require 'socket'.sleep


local s = irc.new{nick = config.nick, username = config.username, realname = config.realname}

s:hook('OnChat', function(user, channel, message)
	if message:match('%.ff') then
		local newspeed = tonumber(message:match(' (%d*)'))
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
			logs:seek('cur', 10000)
			logs:read('*l')
			m = cjson.decode(logs:read('*l'))
		end
		while utc < m[2] do
			logs:seek('cur', -10000)
			logs:read('*l')
			m = cjson.decode(logs:read('*l'))
		end
		while utc > m[2] do
			m = cjson.decode(logs:read('*l'))
		end
	elseif message:match('%.utc') then
		s:sendChat(channel, tostring(os.clock()*speed+utcAdjust))
	elseif message:match('%.help') then
		s:sendChat(channel, 'Available Commands: ff, .skip, .setutc, .utc')
	end
end)



s:connect(config.server)

for i, channel in ipairs(config.channels) do
	s:join(channel)
end
s:sendChat('NickServ', 'identify '..config.password)
logs = io.open(config.dataFileName, "r")
m = cjson.decode(logs:read('*l'))
utcAdjust = os.clock()+20+m[2]
speed = 1
while true do
	s:think()
	if os.clock()*speed > m[2]-utcAdjust then
		s:sendChat(config.mainChannel, m[3]:match('(.-)!')..': '..m[4])
		sleep(config.refeshRate)
		m = cjson.decode(logs:read('*l'))
	end
end
