#!/bin/bash
#This script is for downloading a file multiple times from different tor exit nodes using tails
#run it like so
#
# sudo fileverification.sh 10 http://ur.com/file.iso ../download_folder
#where the first arguemnt is the number of times the file will be downloaded and 
#	the second argument is the URL of the file to be downloaded

#initialize the default values for several variables
iterations=5
downloadLocation="./"
stall=0

while getopts "u:n:l:h" option;
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
	h)
		echo "This script will download a file from a bunch of different tor circuits
	-u: The URL of the file to download. This argument is required.
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

#Verify that all required arguments have something in them
if [[ -z "$downloadURL" ]]; then
	echo "script needs the URL of a file to download"
	exit
fi

#First argument: number of times we will attempt to download the file
echo "Downloading $iterations times"

#Second argument: URL of the file to download
#downloadURL=$2
echo "Your download URL is $downloadURL"

#Third argument: Download location
#downloadLocation=$3

torpid=`cat /run/tor/tor.pid`
for i in $(eval echo {1..$iterations})
do
	kill -1 $torpid
	echo -n 'Establishing new tor circuit...'
	sleep 10
	exitAddress=`proxychains curl -s http://canihazip.com/s | grep -v ProxyChains`	
	echo -e "Your current exit node's address is: $exitAddress"
	proxychains wget -nv $downloadURL -P $downloadLocation | grep -v ProxyChains
done

#hey! why not dump all exit IPs to a file in /tmp and check them when doing 
#subsequent file verifications. It would be great to not roll over exit nodes 
#or get tricked into using an exit node more than once to download a file we're 
#attempting to verify
#
#while $true;do proxychains curl http://canihazip.com/s; torpid=`sudo cat /run/tor/tor.pid`;sudo  kill -1 $torpid;sleep 10;done
# I propose an option for a static or variable wait time in between downloads
#so, this script relies on proxychains and we can't be sure that proxchains is
#going to be installed and configured well on a given machine before we run this
#a misconfig will, at best fail to download and at worst route the download over
#whatever the current proxychains config is set to use
#
#is there a way to check current proxychains config and verify it's set for tor?
#	YES, Manually
#should we allow an option for creating a temporary local proxychains config
#	PROBABLY
