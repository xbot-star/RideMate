# RideMate / CampusRide is a Java Swing DESKTOP app, so we run it on a virtual
# screen inside the container and stream that screen to the browser with noVNC.
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jdk \
        xvfb x11vnc fluxbox \
        novnc websockify \
        fontconfig fonts-dejavu-core ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only the sources and data (the precompiled /bin folder is not used)
COPY src ./src
COPY data ./data
COPY supabase.properties ./supabase.properties
COPY start.sh /start.sh

# Compile everything inside the image
RUN mkdir -p bin \
    && javac -d bin $(find src -name "*.java") \
    && chmod +x /start.sh

ENV DISPLAY=:99
ENV PORT=10000
EXPOSE 10000

CMD ["/start.sh"]
