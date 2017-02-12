#!/bin/sh

exec squeezeboxserver \
	--prefsdir $SQUEEZE_VOL/prefs \
	--logdir $SQUEEZE_VOL/logs \
	--cachedir $SQUEEZE_VOL/cache "$@"
