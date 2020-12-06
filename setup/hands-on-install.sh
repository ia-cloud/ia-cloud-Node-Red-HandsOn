#!/bin/bash
echo "---- apt レポジトリーのアップデート ----"
sudo apt update
echo "---- JSONハンドリングコマンド jq のインストール ----"
sudo apt install jq
echo "---- nodeバージョン管理 n のインストール ----"
sudo apt install npm
sudo apt install nodejs
sudo npm install n -g
sudo n 10
sudo apt purge -y nodejs npm
node -v
echo "---- Node-RED のインストール ----"
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)

echo "---- 起動時設定スクリプトの配置 ----"
sudo mkdir -p /opt/ia-cloud/bin
sudo mv /boot/ia-cloud/hands-on-start.sh /opt/ia-cloud/bin/
echo "---- 自動起動サービスの設定 ----"
sudo mv /boot/ia-cloud/hands-on-start.service.org /etc/systemd/system/hands-on-start.service
sudo systemctl daemon-reload
sudo systemctl enable hands-on-start.service
