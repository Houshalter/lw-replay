# lw-replay
lw-replay is an IRC bot designed to examine the quality of lesswrong as it once was.

Requires cjson. Which can be installed with luarocks. Also requires socket and irc, which are included.

Logs are not included! You will need to provide them yourself.

Requires logs in a certain format. Raw JSON logs can be processed with processdata.py.

See the config file to configure it.

To run, navigate to the directory you saved it in and type

	lua lw-replay.lua
	
You should have lua 5.1 installed. Though it may work with other versions if you get all the dependencies for those versions.