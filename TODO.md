# TODO/Future ideas
- If our objective is to download each file from a different exit node, the script doesn't nicely handle this for us at the moment. Store IPs and refuse to download from exits that have already been used this session.
- Since this script relies on proxychains and we can't be sure that proxchains is going to be installed and configured well on a given machine before this script is run, a misconfig will at best fail to download and at worst route the download over whatever the current proxychains config is set to use
	- There are two ways to do this
		- Use a local proxychains.conf to ensure that a proper config is being used. If one already exists, nicely exit. Maybe allow user to set tor port if this is being used
		- Iterate through through proxychains's .conf preference list
