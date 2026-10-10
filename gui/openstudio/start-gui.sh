#!/bin/bash
set -Eeuo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"
mkdir -p "$XDG_RUNTIME_DIR" "$HOME/.cache" "$HOME/.config"
chmod 700 "$XDG_RUNTIME_DIR"

cleanup() {
  status=$?
  trap - EXIT INT TERM
  kill "${APP_PID:-}" "${WS_PID:-}" "${VNC_PID:-}" "${WM_PID:-}" "${XVFB_PID:-}" 2>/dev/null || true
  wait 2>/dev/null || true
  exit "$status"
}
trap cleanup EXIT INT TERM

Xvfb "$DISPLAY" -screen 0 "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x24" -nolisten tcp -ac &
XVFB_PID=$!
for _ in $(seq 1 50); do
  xdpyinfo -display "$DISPLAY" >/dev/null 2>&1 && break
  sleep 0.1
done
xdpyinfo -display "$DISPLAY" >/dev/null 2>&1

fluxbox >/tmp/fluxbox.log 2>&1 &
WM_PID=$!
x11vnc -display "$DISPLAY" -rfbport 5900 -localhost -forever -shared -nopw -quiet >/tmp/x11vnc.log 2>&1 &
VNC_PID=$!
websockify --web=/usr/share/novnc/ 5800 127.0.0.1:5900 >/tmp/websockify.log 2>&1 &
WS_PID=$!

/opt/openstudio-app/bin/OpenStudioApp >/tmp/openstudio-app.log 2>&1 &
APP_PID=$!
wait "$APP_PID"
