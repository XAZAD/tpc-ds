echo Killing
ps aux| grep dsdgen| grep -v grep | awk '{ print $2 }'| xargs kill -9