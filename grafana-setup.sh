#!/bin/bash
# Hardware requirements: Ubuntu 20.04 instance with mimum t2.micro type instance & port 3000 should be allowed on the security groups
sudo apt-get install -y adduser libfontconfig1
sudo wget https://dl.grafana.com/oss/release/grafana_7.3.4_amd64.deb
sudo dpkg -i grafana_7.3.4_amd64.deb
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
sudo systemctl enable grafana-server.service