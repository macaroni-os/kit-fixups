#!/bin/bash

# This script will split redis.conf into sub-sections which are stored in
# /etc/redis/conf/, while a master config file in /etc/redis/redis.conf
# includes all these sub-sections.

csplit -f splitfile_ redis.conf /^###########/ '{*}' > /dev/null
count=0
rm -f includes
install -d conf
for x in splitfile_*; do
	if [ $count -ge 3 ]; then
		fn=$(cat $x | head -n1 | sed -e 's/#*//g' | tr '[A-Z]/' '[a-z]_');
		fn=$(echo $fn | tr ' ' '_').conf
		echo "include /etc/redis/conf/$fn" >> includes
		mv $x conf/$fn
	fi
	count=$(( $count + 1 ))
done
mv -f splitfile_00 redis.conf
cat splitfile_01 >> redis.conf; rm splitfile_01
cat includes >> redis.conf; rm includes
echo >> redis.conf
cat splitfile_02 >> redis.conf; rm splitfile_02
