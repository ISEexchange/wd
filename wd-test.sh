#!/bin/bash

# this script tests and shows usage of the `wd' binary.
# wd is a watchdog program that wraps any other program
# that can be reached via an absolute filesystem path.


# set a time-limit for wrapped commands
echo
echo "Setting EXPIRATION=2"
export EXPIRATION=2

echo
echo "About to run \`wd /bin/sleep 1'"
echo "    the command should finish normally, and"
echo "    wd's exit status should equal that of sleep"
wd /bin/sleep 1
echo "Exit status=$?"

echo
echo "About to run \`wd /bin/sleep 3'"
echo "    this one should exceed time-limit"
echo "    wd's exit status should be 210 (time_limit_exceeded)"
wd /bin/sleep 3
echo "Exit status=$?"
