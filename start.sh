#!/bin/bash
set -e

PORT="${PORT:-10000}"
export DISPLAY=:99

# Open the app straight away when someone visits the site
cat > /usr/share/novnc/index.html <<HTML
<!DOCTYPE html>
<meta http-equiv="refresh" content="0;url=vnc.html?autoconnect=true&resize=scale">
HTML

# 1) Web server + WebSocket bridge (binds to Render's $PORT first)
websockify --web=/usr/share/novnc "$PORT" localhost:5900 &

# 2) Virtual screen and window manager
Xvfb :99 -screen 0 1280x800x24 &
sleep 2
fluxbox &

# 3) VNC server (set VNC_PASSWORD in Render to require a password)
if [ -n "$VNC_PASSWORD" ]; then
  x11vnc -display :99 -forever -shared -passwd "$VNC_PASSWORD" -rfbport 5900 -quiet &
else
  x11vnc -display :99 -forever -shared -nopw -rfbport 5900 -quiet &
fi
sleep 1

# 4) The Java app (restarts if the window is closed / app exits)
cd /app
while true; do
  java -Xmx300m -cp bin Main || true
  sleep 1
done
