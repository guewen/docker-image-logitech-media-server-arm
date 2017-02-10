#!/bin/sh

if [ "$LOCAL_USER_ID" ] && [ -d "$LOCAL_USER_ID" ]; then
  usermod -u $LOCAL_USER_ID squeezeboxserver
fi

if [ "$SQUEEZE_VOL" ] && [ -d "$SQUEEZE_VOL" ]; then
  for subdir in prefs logs cache; do
    mkdir -p $SQUEEZE_VOL/$subdir
    chown -R squeezeboxserver:nogroup $SQUEEZE_VOL/$subdir
  done
fi

exec sudo -u squeezeboxserver -E /start-squeezebox.sh "$@"
