#!/bin/bash

die() {
    echo "$@" >/dev/stderr
    exit 1
}

try() {
    "$@" || die "$@ failed (exit code $?)"
}

check-root() {
    if [[ "$UID" == "0" ]] || [[ "$EUID" == "0" ]]; then
        die "This script should NOT be run as ROOT! Aborting!"
    fi
}

check-eula() {
    echo "CHECK /data/eula.txt"
    if [[ ! "${EULA}" ]]; then
        cat <<EOF

ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR

You MUST agree to Mojang's EULA at
https://account.mojang.com/documents/minecraft_eula
and then set the EULA environment variable to "true" before this server will start.

ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR

EOF
        die "Administrator did not agree to EULA terms."
    fi

    echo "CREATE /data/eula.txt"
    cat >/data/eula.txt <<EOF
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
#Sat Jul 13 18:38:57 UTC 2019
eula=${EULA:-false}
EOF
}

maybe-create-server-properties() {
    echo "CHECK /data/server.properties"
    if [[ ! -f /data/server.properties ]]; then
        echo "CREATE /data/server.properties"
        cat >/data/server.properties <<EOF
max-tick-time=60000
generator-settings=
allow-nether=true
force-gamemode=false
gamemode=${GAMEMODE:-0}
enable-query=false
player-idle-timeout=0
difficulty=${DIFFICULTY:-1}
spawn-monsters=true
op-permission-level=4
pvp=true
snooper-enabled=false
generator-settings={"Topography-Preset":"Omnifactory"}
level-type=lostcities
hardcore=${HARDCORE:-false}
enable-command-block=${COMMANDBLOCK:-false}
max-players=${MAXPLAYERS:-20}
network-compression-threshold=256
resource-pack-sha1=
max-world-size=29999984
server-port=25565
server-ip=
spawn-npcs=true
allow-flight=true
level-name=world
view-distance=10
resource-pack=
spawn-animals=true
white-list=${WHITELIST:-false}
generate-structures=true
online-mode=true
max-build-height=256
level-seed=${SEED}
prevent-proxy-connections=false
use-native-transport=true
motd=${MOTD:-A Minecraft Server}
enable-rcon=true
rcon.port=25575
rcon.password=${RCONPASS}
EOF
    fi
}

echo "RUN /install/start.sh" "$@"
check-root
check-eula

echo "CP -Ru /install/* /data/"
try cp -Ru /install/* /data/

echo "CHOWN -R minecraft:minecraft /data/*"
try chown -R minecraft:minecraft /data/*

maybe-create-server-properties

echo "RUN /usr/bin/java -jar /data/forge-*.jar $@ nogui"
try /usr/bin/java -jar /data/forge-*.jar "$@" nogui
