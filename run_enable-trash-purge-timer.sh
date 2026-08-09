#!/bin/sh
set -eu
if systemctl --user enable --now trash-purge.timer 2>/dev/null; then
    echo "trash-purge.timer: enabled and started"
else
    echo "WARNING: trash-purge.timer: could not enable (no user session bus?)" >&2
fi
