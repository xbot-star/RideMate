#!/bin/bash
set -e

PORT="${PORT:-10000}"
export DISPLAY=:99

# Open the app straight away; lower quality/compression settings = less lag
cat > /usr/share/novnc/index.html <<HTML
<!DOCTYPE html>
<meta http-equiv="refresh" content="0;url=vnc.html?autoconnect=true&resize=scale&quality=4&compression=4">
HTML

# 1) Web server + WebSocket bridge (binds to Render's $PORT first)
websockify --web=/usr/share/novnc "$PORT" localhost:5900 &

# 2) Virtual screen: 16-bit colour and a smaller size = far less data to stream
Xvfb :99 -screen 0 1100x760x16 -nolisten tcp &
sleep 2
fluxbox >/dev/null 2>&1 &

# 3) VNC server (set VNC_PASSWORD in Render to require a password)
VNC_OPTS="-display :99 -forever -shared -rfbport 5900 -quiet -nowireframe -noxrecord -nodpms"
if [ -n "$VNC_PASSWORD" ]; then
  x11vnc $VNC_OPTS -passwd "$VNC_PASSWORD" &
else
  x11vnc $VNC_OPTS -nopw &
fi
sleep 1

# 4) The Java app, tuned for a low-CPU container (restarts if it exits)
cd /app
while true; do
  java -Xms128m -Xmx300m \
       -XX:+UseSerialGC -XX:TieredStopAtLevel=1 -Xshare:auto \
       -Dfile.encoding=UTF-8 \
       -Dsun.java2d.opengl=false \
       -cp bin Main || true
  sleep 1
done
