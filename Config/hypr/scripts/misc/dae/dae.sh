#!/usr/bin/env bash

# proxy=https://mirror.ghproxy.com/

# if [[ -n $1 ]]; then
    # sudo cp ~/.linuxConfig/configs/config.dae /etc/dae/config.dae
# fi

sudo mkdir -p /etc/dae/
sudo install -m 655 ./updategeo.sh /usr/bin/updategeo
sudo install -m 644 ../custom-services/updategeo.service /lib/systemd/system/updategeo.service
sudo install -m 644 ../custom-services/updategeo.timer /lib/systemd/system/updategeo.timer
sudo systemctl daemon-reload
sudo systemctl enable updategeo.timer
sudo systemctl start updategeo
