#!/bin/bash
[[ -z $IPOD ]]&&IPOD=iPod-touch.local
cat debs/ws.hbang.irccloud_$(grep -E ^Version: _/DEBIAN/control|cut -d " " -f 2)_iphoneos-arm.deb|ssh root@$IPOD "(cat ->/tmp/tmp.deb&&dpkg -i /tmp/tmp.deb&&(killall IRCCloud;sblaunch ws.hbang.irccloud))"
