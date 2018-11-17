#!/bin/sh

MOCHA_LOG=$(mktemp -t mocha_XXXXXX.log)

# run mocha (in background)
cd /home/user/privatebin/js && mocha 2> "$MOCHA_LOG" > "$MOCHA_LOG" &
MOCHA_PID=$!

# run phpunit (in foreground)
cd /home/user/privatebin/tst && phpunit
PHPUNIT_EXIT=$?
echo

if [ "$PHPUNIT_EXIT" -ne 0 ]
then
    rm "$MOCHA_LOG"
    echo "\033[0;31mphp unit tests failed!\033[0m"
    exit $PHPUNIT_EXIT
fi

# present mocha results, when done
wait $MOCHA_PID
MOCHA_EXIT=$?
cat "$MOCHA_LOG"
rm "$MOCHA_LOG"

if [ "$MOCHA_EXIT" -ne 0 ]
then
    echo "\033[0;31mjavascript unit tests failed!\033[0m"
    exit $MOCHA_EXIT
fi
echo "\033[0;32mall unit tests passed - good work!\033[0m"
