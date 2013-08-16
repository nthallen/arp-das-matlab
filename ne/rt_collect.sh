#! /bin/bash
PATH=/usr/bin:/usr/local/bin:$PATH
hdr=$1
url=$2

function nl_log {
  now=`date +%H:%M:%S`
  echo "Collect $hdr: $now: $*"
  echo "Collect $hdr: $now: $*" >>$hdr.log
}

# create $hdr.0.raw
# mv $hdr.0.raw $hdr.1.raw
start='?Start=0'
lastrec=''
touch $hdr.run
rm -f $hdr.0.raw $hdr.1.raw $hdr.raw
nl_log "Starting"
nl_log "hdr=$hdr"
nl_log "url=$url"
while [ -f $hdr.run ]; do
  curl -o $hdr.0.raw $url$start 2>/dev/null
  if [ -f $hdr.0.raw ]; then
    if [ -n "$start" ]; then
      start=''
      cp -f $hdr.0.raw $hdr.raw
      mv $hdr.0.raw $hdr.1.raw
    else
      newrec=`cat $hdr.0.raw`
      if [ "$lastrec" != "$newrec" ]; then
        cat $hdr.0.raw >>$hdr.raw
        if [ -f $hdr.1.raw ]; then
          # Matlab hasn't picked this one up. Let's hide it...
          mv $hdr.1.raw $hdr.01.raw 2>/dev/null
        fi
        if [ -f $hdr.01.raw ]; then
          cat $hdr.0.raw >>$hdr.01.raw
          rm $hdr.0.raw
          mv -f $hdr.01.raw $hdr.1.raw
        elif [ -f $hdr.1.raw ]; then
          nl_log "Error: $hdr.1.raw still present after mv"
        else
          mv $hdr.0.raw $hdr.1.raw
        fi
      fi
    fi
  else
    nl_log "Error: curl produced no output"
  fi
  sleep 5
done
rm -f $hdr.1.raw $hdr.0.raw

nl_log "Terminating"

