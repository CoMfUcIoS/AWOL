#!/bin/bash

silent=$1

readarray hosts <<< `cat /home/pi/awol/Hostlist`

wakehost(){
  for i in {1..10}; do wakeonlan $1 &> /dev/null; done
  echoTime "Magic packages sent"
}

echoTime() {
  if [[ "$silent" != *"--silent"* ]] || [[ "$2" == "1" ]]; then
    echo "$(date)" - $1 >> /home/pi/awol/logs/awol.log
  fi
}

echoLine() {
  echoTime "--------------------------------------------------------------------"
}

echoLine
echoTime "AWOL Script is started"
echoLine

for i in "${!hosts[@]}"
do
  readarray -d \| -t opt <<< "${hosts[$i]}"
  readarray -d : -t meta <<< "${opt[0]}"
  mac="${opt[1]}"
  ping -c1 -w2 ${meta[1]} >/dev/null 2>&1 ;
  ping_sts=$?
  if [ $ping_sts -ne 0 ] ; then
    on_batt=$(apcaccess -p STATUS | tr "\n" " ")
    if [[ "$on_batt" == *"ONBAT"* ]]; then
      if  [[ "${meta[2]}" == *"always"* ]]; then
        echoTime "$((i+1)). Host ${meta[0]} is down" 1
        echoTime "${meta[0]} is configed to be Always on, waking it up" 1
        wakehost $mac
      else
        echoTime "   On Batteries... ignoring ${meta[0]}"
      fi
    else
      if  [[ "${meta[2]}" != *"skip"* ]]; then
        echoTime "$((i+1)). Host ${meta[0]} is down" 1
        echoTime "We are online, sending wake on lan magic packages to ${meta[0]}" 1
        wakehost $mac
      else
        echoTime "$((i+1)). Host ${meta[0]} is down"
        echoTime "${meta[0]} is configed to be skipped"
      fi
    fi
  else
    echoTime "$((i+1)). Host ${meta[0]} is up"
  fi
  echoLine
done

echoTime "Run Logrotate"
logrotate /home/pi/awol/logrotate.conf --state /home/pi/awol/logrotate-state --verbose &> /dev/null
echoTime "AWOL Script is finished"
echoLine
