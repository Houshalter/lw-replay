package.path = package.path..";./?.lua;./?/init.lua;"

require 'config'
require 'irc'
cjson = require 'cjson'



local sleep = require 'socket'.sleep


local s = irc.new{nick = config.nick, username = config.username, realname = config.realname}

s:hook('OnChat', function(user, channel, message)
	if message:match('%.ff') then
		speed = message:match('%.ff (.*)')
		utcAdjust os.clock()
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
while true do
	s:think()
	if os.clock() > m[2]-utcAdjust then
		s:sendChat(config.mainChannel, m[3]:match('(.-)!')..': '..m[4])
		sleep(config.refeshRate)
		m = cjson.decode(logs:read('*l'))
	end
end
