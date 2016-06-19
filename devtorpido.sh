#!/bin/bash
#This script is for downloading a file multiple times from different tor exit nodes using tails
#run it like so
#
# sudo fileverification.sh 10 http://ur.com/file.iso ../download_folder
#where the first arguemnt is the number of times the file will be downloaded and the second argument is the URL of the file to be downloaded
while getopts ":u:n:l:h" option;
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
		echo "this script will download a file from a bunch of different tor circuits
	-u: specify the URL of the file to download
	-d: specify the number of times to attempt to download the file from different exit nodes
	-l: specify the location to download these files too
	-h: display this help"
		exit
		;;
	:)
		echo "option -$OPTARG needs an argument"
		exit
		;;
	esac
done
		
#First argument: number of times we will attempt to download the file
#iterations=$(($1-1))
echo "Downloading $1 times"

#Second argument: URL of the file to download
#downloadURL=$2
echo "Your download URL is $downloadURL"

#Third argument: Download location
#downloadLocation=$3

torpid=`cat /run/tor/tor.pid`
for i in $(eval echo {0..$iterations})
do
	kill -1 $torpid
	echo -n 'Establishing new tor circuit...'
	sleep 10
	exitAddress=`proxychains curl -s http://canihazip.com/s`
	
	echo -e "Your current exit node's address is: $exitAddress"
	proxychains wget -nv $downloadURL -P $downloadLocation

done

#hey! why not dump all exit IPs to a file in /tmp and check them when doing subsequent file verifications. It would be great to not roll over exit nodes or get tricked into using an exit node more than once to download a file we're attempting to verify
#while $true;do proxychains curl http://canihazip.com/s; torpid=`sudo cat /run/tor/tor.pid`;sudo  kill -1 $torpid;sleep 10;done
