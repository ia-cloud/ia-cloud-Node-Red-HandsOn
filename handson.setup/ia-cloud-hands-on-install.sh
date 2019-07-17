#!/bin/bash
echo "---- apt レポジトリーのアップデート ----"
sudo apt update
echo "---- JSONハンドリングコマンド jq のインストール ----"
sudo apt install jq
echo "---- Node-RED 0.19.04のインストール ----"
/boot/node-red-install.sh
echo "---- GrovePi Nodes のインストール ----"
cd ~/.node-red; npm install node-red-contrib-grovepi
echo "---- ia-cloud-fds のインストール ----"
cd ~/.node-red; npm install ia-cloud/node-red-contrib-ia-cloud-fds
echo "---- ia-cloud-dashboard のインストール ----"
cd ~/.node-red; npm install ia-cloud/node-red-contrib-ia-cloud-dashboard
echo "---- 起動時設定スクリプトの配置 ----"
sudo mkdir -p /opt/ia-cloud/bin
sudo mv /boot/ia-cloud-hands-on-start.sh /opt/ia-cloud/bin/
echo "---- 自動起動サービスの設定 ----"
sudo mv /boot/ia-cloud-hands-on-start.service.org /etc/systemd/system/ia-cloud-hands-on-start.service
sudo systemctl daemon-reload
sudo systemctl enable ia-cloud-hands-on-start.service
