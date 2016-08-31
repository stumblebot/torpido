#!/bin/bash

#initialize the default values for several variables
iterations=5
downloadLocation="./"
stall=0

while getopts "u:n:l:w:h" option;
do
	case $option in
	u)
		downloadURL=$OPTARG
		;;
	n)
		iterations=$OPTARG
		;;
	l)
		downloadLocation=$OPTARG
		;;
	w)
		waitArg=$OPTARG
		;;
	h)
		echo "This script will download a file from a bunch of different tor circuits
	Dependencies:
	-tor: installed as a service
	-proxychains: configured to use tor
	Use:
	-u: The URL of the file to download. [REQUIRED]
	-n: The number of times to attempt to download the file. Default is 5.
	-l: The location to download these files to. Default is the current directory.
	-w: The additional amount of time to wait between downloads. Torpido already waits 10 seconds
		to ensure that there has been enough time to create the next circuit.
	-h: Display this help"
		exit
		;;
	:)
		echo "option -$OPTARG needs an argument"
		exit
		;;
	esac
done

#Verify that all required arguments contain some data
if [[ -z "$downloadURL" ]]; then
	echo "script needs the URL of a file to download"
	exit
fi

#Print some of the arguments that we'll be running with
echo "Downloading $iterations times"
echo "Your download URL is $downloadURL"

#Add the additional wait time from -w
waitTime=$(( $waitArg + 10 ))

torpid=`cat /run/tor/tor.pid`

for i in $(eval echo {1..$iterations})
do
	#Establish a new tor circuit
	kill -1 $torpid
	echo -n "Establishing new tor circuit. "
	echo -n "Waiting $waitTime seconds"
	#Spit out a nice animation so impatient people know that there's still progress
	aniWait=$(( $waitTime / 5 ))
	for ani in $(seq 1 5)
	do
		sleep $aniWait
		echo -n "."
	done
	sleep $(( $waitTime - ($aniWait * 5) ))
	#Tell the exit node IP
	exitAddress=`proxychains curl -s http://canihazip.com/s | grep -v ProxyChains`	
	echo -e "Exit node IP: $exitAddress"
	#Download the thing!
	proxychains wget -nv $downloadURL -P $downloadLocation | grep -v ProxyChains
done
