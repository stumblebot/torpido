# Torpido

This script will download a file from a bunch of different tor circuits

Dependencies:
- tor: installed as a service
- proxychains: configured to use tor


Use:
- -u: The URL of the file to download. [REQUIRED]
- -n: The number of times to attempt to download the file. Default is 5.
- -l: The location to download these files to. Default is the current directory.
- -w: The additional amount of time to wait between downloads. Torpido already waits 10 seconds to ensure that there has been enough time to create the next circuit.
- -h: Display this help
