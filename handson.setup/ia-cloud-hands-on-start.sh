#!/bin/bash
#

echo "set ip-configuration and Wi-fi configration and hostname"

# 設定情報ファイル名を変数にセット
config_file="/boot/ia-cloud-hands-on-config.json"

# 設定変更するファイルを変数にセット
ip_conf_file="/etc/dhcpcd.conf"
wifi_conf_file="/etc/wpa_supplicant/wpa_supplicant.conf"
hostname_file="/etc/hostname"
hosts_file="/etc/hosts"

echo -e $config_file
echo -e $ip_conf_file
echo -e $wifi_conf_file
echo -e $hostname_file
echo -e $hosts_file

# ia-cloud 設定ファイルが存在したら
if [ -r $config_file ]; then

    # 固定IP設定があれば
    lan=`cat $config_file | jq -r '."lan-config"'`

    if [ -n "$lan" ]; then
        echo "固定IP設定"
        ip_address=`echo $lan | jq -r '."ip-address"'`
        default_gateway=`echo $lan | jq -r '."default-gateway"'`
echo $ip_address
echo $default_gateway
        # dhcpcd.confファイルがあるか確認し変更
        if [ -w $ip_conf_file ]; then
echo "IP設定書き込み"
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
    echo $wifi

    if [ -n "$wifi" ]; then
        echo -n "Wifi設定"
        type=`echo $wifi | jq -r '."type"'`
        ssid=`echo $wifi | jq -r '."ssid"'`
        password=`echo $wifi | jq -r '."password"'`
        echo $type
        # wpa_supplicant.confがあるか確認し変更
        if [ -w $wifi_conf_file ]; then
            # wifi暗号化wepの場合
            if [ $type == "wep" ]; then
                {
                  echo "country=JP"
                  echo "ctrl_interface=DIR/var/run/wpa_supplicant GROUP=netdev"
                  echo "update_config=1"
                  echo ""
                  echo ""
                  echo "network={"
                  echo "    ssid=$ssid"
                  echo "    key_mgmt=NONE"
                  echo "    wep_key0=$password"
                  echo "}"
                  echo ""
                } > $wifi_conf_file
            fi
            # wifi暗号化WPAの場合
            if [ $type == "wpa" ]; then
                {
                  echo "country=JP"
                  echo "ctrl_interface=DIR/var/run/wpa_supplicant GROUP=netdev"
                  echo "update_config=1"
                  echo ""
                  echo ""
                  echo "network={"
                  echo "    ssid=$ssid"
                  echo "    psk=$password"
                  echo "}"
                  echo ""
                } > $wifi_conf_file
            fi
        fi
    fi

    hostname=`cat $config_file | jq -r '."hostname"'`
    if [ -n $hostname ]; then
        echo "change hostname"

        if [ -w $hostname_file ]; then
          if [ -w $hosts_file ]; then

            echo $hostname > $hostname_file
            echo 127.0.01 $hostname >> $hosts_file
            sed -i -e /raspberrypi/d $hosts_file
          fi
        fi
    fi
    # 設定ファイルの名称を変更
    mv $config_file $config_file.org

fi
