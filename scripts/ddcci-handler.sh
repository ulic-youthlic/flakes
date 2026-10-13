# shellcheck shell=bash
# Body only: buildBashTool wraps this with a shebang, `set -euo pipefail` and a
# PATH built from the overlay's runtimeInputs.
#
# Invoked as a systemd template unit, so $1 is the i2c device name from %i.

echo Trying to attach ddcci to "$1"
success=0
i=0
id=$(echo "$1" | cut -d "-" -f 2)
while ((success < 1)) && ((i++ < 5)); do
  if ddcutil getvcp 10 -b "$id"; then
    if echo ddcci 0x37 >"/sys/bus/i2c/devices/$1/new_device"; then
      success=1
      echo ddcci attached to "$1"
    fi
  fi
  echo "Try $i"
  sleep 1
done
