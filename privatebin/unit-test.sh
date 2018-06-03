#!/bin/sh

MOCHA_LOG=$(mktemp mocha_XXXXXX.log)

# run mocha (in background)
cd /home/user/privatebin/js && mocha 2> "$MOCHA_LOG" > "$MOCHA_LOG" &

# run phpunit (in foreground)
cd /home/user/privatebin/tst && phpunit

# present mocha results, when done
echo
wait
cat "$MOCHA_LOG"
rm "$MOCHA_LOG"

