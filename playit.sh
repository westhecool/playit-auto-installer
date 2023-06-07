#!/bin/bash
GREEN="\e[32m"
RED="\e[31m"
ENDCOLOR="\e[0m"
get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
if [[ "$(id -u)" != "0" ]]; then
    echo -e "$RED This script must be run as root $ENDCOLOR"
    exit 1
fi
if [[ $(apt) ]]; then
    echo -e "$GREEN Using apt $ENDCOLOR"
    curl -SsL https://playit-cloud.github.io/ppa/key.gpg | apt-key add -
    curl -SsL -o /etc/apt/sources.list.d/playit-cloud.list https://playit-cloud.github.io/ppa/playit-cloud.list
    apt update
    apt install playit -y
else
    echo -e "$GREEN apt not found, downloading playit from github $ENDCOLOR"
    v=$(get_latest_release playit-cloud/playit-agent)
    if [[ "$(arch)" == "x86_64" ]]; then
        curl -Lo /usr/local/bin/playit "https://github.com/playit-cloud/playit-agent/releases/download/$v/playit-${v#?}"
    elif [[ "$(arch)" == "aarch64" ]]; then
        curl -Lo /usr/local/bin/playit "https://github.com/playit-cloud/playit-agent/releases/download/$v/playit-${v#?}-aarch64"
    elif [[ "$(arch)" == "armv7l" ]]; then
        curl -Lo /usr/local/bin/playit "https://github.com/playit-cloud/playit-agent/releases/download/$v/playit-${v#?}-arm7"
    else
        echo -e "$RED Architecture not supported $ENDCOLOR"
        exit 1
    fi
    chmod +x /usr/local/bin/playit
fi
dontexit() {
    echo > /dev/null
}
echo -e "$GREEN You will now need to register the playit agent $ENDCOLOR"
echo -e "$GREEN Press ctrl+c when you are done (You may need to press ctrl+c twice) $ENDCOLOR"
echo -en "$GREEN Press enter to continue $ENDCOLOR"
read
trap dontexit SIGINT
playit &
PID=$!
wait $PID
echo -e "\033c"
echo "Installing playit service"
cat <<EOF > /etc/systemd/system/playit.service
[Unit]
Description=Playit.gg Agent
After=network.target

[Service]
WorkingDirectory=/etc/playit
ExecStart=/usr/local/bin/playit -s
Restart=always
RestartSec=120

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable playit.service
systemctl start playit.service
echo -e "$GREEN Done! $ENDCOLOR"