#!/bin/sh

# converttocaf.sh
# http://discussions.apple.com/thread.jspa?messageID=8100058

##
## Shell script to batch convert all files in a directory to caf sound format for iPhone
## Place this shell script a directory with sound files and run it: 'sh converttocaf.sh'
## Any comments to 'support@ezone.com'
##
 
for f in *; do
	if  [ "$f" != "converttocaf.sh" ]
	then

# raw PCM -- very slightly smaller than input AIF (45.7 -> 45.4 MB on 38 trumpet notes)
#		/usr/bin/afconvert -f caff -d LEI16 $f ${f%.*}.caf

# IMA4 -- bit more than 1/4 size (45.7 -> 12.2 MB)
#     /usr/bin/afconvert -v -f caff -d ima4 $f ${f%.*}.caf

# IMA4 mono 22khz -- 7% tiny (45.7 -> 3.2)
     /usr/bin/afconvert -v -f caff -d ima4@22050 -c 1 $f ${f%.*}.caf

# AAC VBR around 1/8th (45.7 -> 6.2)
#      /usr/bin/afconvert -v -f caff -d aac -s 3 -q 127 -u vbrq 127 "$f" "${f%.*}.caf"

# 128k AAC ABR -- identical to VBR apparently, at 192k as well
#      /usr/bin/afconvert -v -f caff -d aac -s 1 -b 128000 -q 127 -u vbrq 127 $f ${f%.*}.caf

# 192k/128k AAC CBR -- about the same (45.7 -> 7.3/7.2)
#      /usr/bin/afconvert -v -f caff -d aac -s 0 -b 192000 -q 127 $f ${f%.*}.caf

#		echo "$f converted"
	fi
done