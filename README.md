# AWOL

A Script to run on a RPI zero to wake up machines if are dead depending on UPS status (On Batteries / On line)

requirements

```
apt get install wakeonlan logrotate apcupsd -y
```

Set up your apcupsd to either use usb to get the status or net.

put all files in folder `/home/pi/awol`  then
```
chmod u+x /home/pi/awol/awol.sh
```

Add your machines in your Hostlist file

example
```
test:10.0.20.111:always|xx:xx:xx:xx:xx:xx
test2:10.0.20.211:online|xx:xx:xx:xx:xx:xx
test3:10.0.20.5:skip|xx:xx:xx:xx:xx:xx
```

Described as following
title:ip:option|macaddress

test = title
10.0.20.111 = ip address of the host
online|always|skip = Online will wake up the host only when ups isnt on batteries, always will wake up the host no matter what, skip will ignore waking the host and continue
xx:xx:xx:xx:xx:xx = mac address of the host to be waken up

careful with `:` and `|`. There are there for a reason.

then add the following in your crontab
run `crontab -e` and paste
```
*/5 * * * * /home/pi/awol/awol.sh --silent
```
And now you check the hosts every 5 mins :)

The logs are under
`/home/pi/awol/logs/awol.log`
And rotating daily.


Happy wol magic :D
