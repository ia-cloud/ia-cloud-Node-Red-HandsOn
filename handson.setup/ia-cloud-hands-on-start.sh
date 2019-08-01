#!/bin/bash
#

# 設定情報ファイル名を変数にセット
config_file="/boot/ia-cloud-hands-on-config.json"
log_file="/var/log/ia-cloud-hands-on-start.log"

# ログファイルにログを追記


# 設定変更するファイルを変数にセット
ip_conf_file="/etc/dhcpcd.conf"
wifi_conf_file="/etc/wpa_supplicant/wpa_supplicant.conf"
hostname_file="/etc/hostname"
hosts_file="/etc/hosts"

# ia-cloud 設定ファイルが存在したら
if [ -r $config_file ]; then

  date > $log_file
  {
    echo "set ip-configuration and Wi-fi configration and hostname"
    echo ""
    cat $config_file
  } >> $log_file

    # 固定IP設定があれば
    lan=`cat $config_file | jq -r '."lan-config"'`

    if [ -n "$lan" ]; then
        # lan設定をログファイルに
        echo $lan >> $log_file
        ip_address=`echo $lan | jq -r '."ip-address"'`
        default_gateway=`echo $lan | jq -r '."default-gateway"'`

        # dhcpcd.confファイルがあるか確認し変更
        if [ -w $ip_conf_file ]; then
            {
              echo ""
              echo -e "interface eth0"
              echo -e "static ip_address="$ip_address
              echo -e "static routers="$default_gateway
              echo ""
            } >> $ip_conf_file
        fi
    fi

    # Wifi設定があれば
    wifi=`cat $config_file | jq -r '."wifi-config"'`
    if [ -n "$wifi" ]; then

        # wifi設定をログファイルに
        echo $wifi >> $log_file

        type=`echo $wifi | jq -r '."type"'`
        ssid=`echo $wifi | jq -r '."ssid"'`
        password=`echo $wifi | jq -r '."password"'`

        # wpa_supplicant.confがあるか確認し変更
        if [ -w $wifi_conf_file ]; then
            # wifi暗号化wepの場合
            if [ $type == "wep" ]; then
                {
                  echo ""
                  echo "network={"
                  echo "    ssid=\"$ssid\""
                  echo "    key_mgmt=NONE"
                  echo "    wep_key0=\"$password\""
                  echo "}"
                  echo ""
                } >> $wifi_conf_file
            fi
            # wifi暗号化WPAの場合
            if [ $type == "wpa" ]; then
                {
                  echo ""
                  echo "network={"
                  echo "    ssid=\"$ssid\""
                  echo "    key_mgmt=WPA-PSK"
                  echo "    psk=\"$password\""
                  echo "}"
                  echo ""
                } >> $wifi_conf_file
            fi
        fi
    fi

    # ホストネイム設定があれば
    hostname=`cat $config_file | jq -r '."hostname"'`
    if [ -n $hostname ]; then
        # ホストネイム設定があればログファイルへ
        echo $hostname >> $log_file

        if [ -w $hostname_file ]; then
          if [ -w $hosts_file ]; then
            echo $hostname > $hostname_file
            sed -i -e /127\.0\.1\.1/d $hosts_file
            {
              echo -n "127.0.0.1"
              echo $hostname
            } >> $hosts_file
          fi
        fi
    fi

    # 設定ファイルの名称を変更
    mv $config_file $config_file.org

    # 設定を有効化するため、再起動
    shutdown -r now

fi
