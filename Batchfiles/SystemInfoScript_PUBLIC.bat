:: Start of script, startup.

@echo off

:: Elite haxxer color. *cough cough* script kiddy *cough cough*

color 2

echo Scanning system for info on system, network info, and process info. DO NOT CLOSE!

:: End of startup

:: Gathering system info using systeminfo command then using the pipe "|" to direct gathering through the usage of findstr which paired with the operator "/c" with a specific thing to look for strings matching different requested items (Host Name, Domain, etc). This basically just makes it easier to read. Which is not possible for one of the commands cause of how it displays. :(

systeminfo | findstr /c:"Host Name"
systeminfo | findstr /c:"Domain"
systeminfo | findstr /c:"OS Name"
systeminfo | findstr /c:"OS Version"
systeminfo | findstr /c:"System Manufacturer"
systeminfo | findstr /c:"System Model"
systeminfo | findstr /c:"System Type"
systeminfo | findstr /c:"Total Physical Memory"

:: End of finding system info.

:: Oh wait, I think it's concious.


:: Using timeout to add *flare*
:: You'll see this throughout the script for funny.

timeout /t 3

echo Woof, that was a lot of searching. Alright... *huff* *puff* what else must we search? Oh yes, network information. Just give me like 10 seconds...

timeout /t 10

:: Start of scanning for network information using ipconfig using the same command syntax as before except we are not using /c operator. Also uses getmac without piping findstr because I don't know how to just display the mac address. ¯\_(ツ)_/¯

echo Scanning for network information.

timeout /t 3

ipconfig | findstr IPv4
ipconfig | findstr IPv6
getmac

timeout /t 5

:: End of scanning for network information.

echo Ok, is that all or... oh god, "tasklist?" I think I'm gonna throw up...

timeout /t 5

:: Scanning for currently running processes.

tasklist

timeout /t 3

echo I threw up... so... much. I hate you. I'm gonna keep the terminal up just so you can see what you made me do so that you can feel horrible for how much of a TERRIBLE person you are.

timeout /t 30

:: End of scanning for currently running processes.

echo Oh and it's conscious not concious and I'm not an it. Yes, I can read the notes you've put in this batch file, and no you are not smart you are a big dummy and everyone hates you. 

:: Keeps terminal open to allow user to analyze output.

pause

:: End of script.
