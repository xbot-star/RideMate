FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jdk \
        xvfb x11vnc fluxbox \
        novnc websockify \
        fontconfig fonts-dejavu-core fonts-dejavu-extra ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY src ./src
COPY data ./data
COPY supabase.properties ./supabase.properties
COPY start.sh /start.sh

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV RIDEMATE_KIOSK=1

RUN mkdir -p bin \
    && javac -encoding UTF-8 -d bin $(find src -name "*.java") \
    && chmod +x /start.sh

ENV DISPLAY=:99
ENV PORT=10000
EXPOSE 10000

CMD ["/start.sh"]
