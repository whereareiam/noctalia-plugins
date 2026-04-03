#!/usr/bin/env bash

set -euo pipefail

qs ipc -c noctalia-shell call plugin:veil toggleFocused
