#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

PID="$(cat $SCRIPT_DIR/chocobot.pid)"
PIDS="$(ps --pid $PID --ppid $PID -o pid=)"
for pid in $PIDS
do
  kill -2 $pid
done
