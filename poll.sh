#!/bin/bash

export $(cat config.env | xargs)
_CURRENT_VALUE=
_NUMBER_READ=0
_START_TIME=`date +%s`

cleanup ()
{
_STOP_TIME=`date +%s`
_DIFF_TIME=$((_STOP_TIME - _START_TIME))
echo ""
echo "==== Exiting ===="
echo "Read $_NUMBER_READ values in $_DIFF_TIME seconds"
exit 0
}

trap cleanup SIGINT SIGTERM

echo "==== Starting ===="
echo "Using port: $IOLINK_PORT"

while [ 1 ]
do
  _NEW_VALUE=`curl -s --location --request POST 'http://192.168.0.1/iolink/sickv1/readDevice' --header 'Content-Type: application/json' --data-raw '{ "header": { "portNumber": '$IOLINK_PORT' }, "data": { "processData": "in" } }' | $JQ_BINARY '.data.processDataIn."2"'` 2>/dev/null
  _NUMBER_READ=$((_NUMBER_READ+1))
  if [ "$_NEW_VALUE" != "$_CURRENT_VALUE" ]; then
    if [ -z "$_CURRENT_VALUE" ]; then # first read
      echo "First read OK"
    else
      if [ "$_NEW_VALUE" = "true" ]; then
        echo "Entered"
      else
        echo "Left"
      fi
    fi
    _CURRENT_VALUE="$_NEW_VALUE"
  else
    echo -n "."
  fi
done