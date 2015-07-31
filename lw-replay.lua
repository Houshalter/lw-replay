package.path = package.path..";./?.lua;./?/init.lua;"

require 'config'
require 'irc'
cjson = require 'cjson'



local sleep = require 'socket'.sleep


local s = irc.new{nick = config.nick, username = config.username, realname = config.realname}

s:hook('OnChat', function(user, channel, message)
	print(('[%s] %s: %s'):format(channel, user.nick, message))
	if message == '.command' then
		
	end
end)



s:connect(config.server)

for i, channel in ipairs(config.channels) do
	s:join(channel)
end
s:sendChat('NickServ', 'identify '..config.password)
logs = io.open(config.dataFileName, "r")
lastTime = os.clock()
while true do
	s:think()
	if os.clock()-lastTime > 5 then
		local m = cjson.decode(logs:read('*l'))
		print(os.clock(), m[4])
		s:sendChat(config.mainChannel, m[4])
		sleep(config.refeshRate)
		lastTime = os.clock()
	end
	--sleep((nextMessageTime < config.refeshRate) and nextMessageTime or config.refeshRate)
end
