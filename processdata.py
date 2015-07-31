import json
f = open('lw-2011-2015.json')
data = json.load(f)

table = []

for k in data:
	time = int(k)
	for message in data[k]:
		if message[1] in ["ACTION","PRIVMSG"]:
			m = [message[1], message[2]+time, message[3], message[4]]
			table.append(m)

data = None
table.sort(key=lambda message: message[1])

outfile = open('logs.json', 'a')

last = 0
for	message in table:
	if last>message[1]:
		 raise Exception(last, message[1])
	last = message[1]
	outfile.write(json.dumps(message, separators=(',',':')))
	outfile.write("\n")