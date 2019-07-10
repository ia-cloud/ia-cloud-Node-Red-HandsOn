# DIY実践IoT活用ハンズオンワークショップ

## RaspberryPi（Raspbian）のインストールとネットワーク環境設定に関するドキュメントとスクリプトおよび設定データ

## 概要
これら一連のファイルは、IAF ia-cloudプロジェクトが実施支援する、DIY実践IoT活用ハンズオンワークショップ（以下ハンズオンWS）で使用されるRaspberryPi(Raspbian)のインストールと環境設定に必要なデータファイル、スクリプトおよびそれらのドキュメントである。

## ハンズオンWS用マスターSDの作成 （その1：PC or Mac での作業）

### マスターマイクロSDカードの作成
- Raspbian公式サイトから、イメージファイルをダウンロード。(2019年7月時点では、Buster Desktop版を利用)
- 最新版Busterは、Node-REDのインストールスクリプトが、Node.jsインストール時に、npmがないとのエラーを吐いて止まってしまうため、後述のインストールスクリプト実行前に、atp-getのupdateコマンドを実行する必要がある。
- マイクロSDカードにイメージを展開

### Node-RED（core）のインストールスクリプトの準備
Node-REDのインストールスクリプト node-red-install/node-red-install.shを、マスターマイクロSDカードの/boot 直下に配置する。  
このスクリプトは、Node-REDユーザ会の公式サイトにある、オールインワンインストールスクリプト　　
```
bash <(curl -sL https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/update-nodejs-and-nodered)
```
から、curlしたスクリプトをファイル化し、使用するNode-REDのバージョンを@latestから、@0.19.4 に変更したものである。  
/node-red-install/node-red-install.org が変更前のスクリプトである。  
このスクリプトは、Node.js、npmのインストールなど全てを含んでいる。

### RaspberryPiのネットワーク設定スクリプトおよび設定データを準備する　　
raspbian起動時にネットワーク設定変更のスクリプトを走らせるため、

#### /boot に、handson.setup/ia-cloud-hands-on-start.service.orgを配置する。

```
[Unit]
Description = excute ia-cloud start up script
After=local-fs.target
ConditionPathExists=/opt/ia-cloud/bin

[Service]
ExecStart=/opt/ia-cloud/bin/ia-cloud-hands-on-start.sh
Restart=no
Type=simple

[Install]
WantedBy=multi-user.target

```
#### /boot にhandson.setup/ia-cloud-hands-on-start.shを配置する。  
このスクリプトは、/boot直下にia-cloud-hands-on-config.jsonが存在すると、それを読み込んで、そこに記述された内容によって、ネットワーク設定を変更するため以下のファイルを変更する。
  * /etc/dhcpcd.conf
  * /etc/wpa_supplicant/wpa_supplicant.conf
  * /etc/test_hostname
  * /etc/test_hosts

変更するのは、IPアドレス・デフォルトゲートウエイ、WifiのSSIDとパスワード、hostnameである。  
変更後は、ia-cloud-hands-on-config.json のファイル名を、ia-cloud-hands-on-config.json.org に変更し再起動を行う。  


#### Raspbianの /boot 直下に、handson.setup/ia-cloud-hands-on-config.json.org を配置する。  
このファイルは、個別にネットワーク設定を変更するスクリプト、ia-cloud-hands-on-config.shが参照するデータファイルである。ハンズオンWS用の個別の起動マイクロSDカードの作成の際に、必要な設定を行なった後ia-cloud-hands-on-config.jsonにファイル名変更される。

## ハンズオンWS用マスターSDの作成 （その2：RaspberryPi での作業）

### Raspbianのインストール
以下の手順を追うこと。

- RaspberyyPiに装着し起動（マウス・キーボード・モニタが必要）
- Busterの初期画面が起動。初期設定画面に従い、インストールを継続
- countryをJAPANに設定
- piユーザのパスワード変更を求められるが無視して続行
- モニタスクリーンのアンダースキャンの確認：どっちでも良い。
- ネットワークの設定は、インストール実行時の環境で設定（LANはデフォルトでDHCP有効になっている。Wifiに場合はここで設定）
- アップデートで、少々時間がかかる。アップデート後再起動。
- 再起動後、Busterのデスクトップ画面が起動する。
- Raspbianのメインメニューから、設定 -> RaspberryPiの設定　を起動
- システムのタブから解像度の設定を選択し、解像度をCEA mode4 1280X720 60Hz 16:9 に設定
- インターフェースタブで、カメラ・SSH・VNC・SPI・I2C・Serial Port　を有効にする。
- 再起動を求められるので再起動
- 再起動後、ユーザpiのパスワードを変更していないとの警告が出るが、ここは無視。


### ia-cloud関連カスタムNodeとその依存コード類のインストール（RaspberryPiのコンソールから操作）

Raspbian Busterでのインストールスクリプト前に、以下のコマンドでaptをupdateする。
```
sudo apt update          // aptのupdateコマンド
```
以下のコマンドラインで、必要なJSONハンドリングモジュールをインストールする
```
sudo apt-get install jq          // JSON処理シェルコマンド
```
Node.js npm Node-REDを一括インストールするスクリプトを実行
```
/boot/node-red-install.sh        // Node.jsとnom、Node-REDのインストール		
```
Node-REDのインストールでは、二つの確認メッセージが出るが、いずれも「ｙ」を入力
このインストールスクリプトの処理には、十数分かかる。  
スクリプトが完了すると、Raspbianのメインメニューのプログラミングに、node-REDが現れ、起動できるようになる.

```
cd ~/.node-red; npm install node-red-contrib-grovepi   	// Grovepiのインストール
cd ~/.node-red; npm install ia-cloud/node-red-contrib-ia-cloud-fds   // ia-cloud-fdsのインストール
cd ~/.node-red; npm install ia-cloud/node-red-contrib-ia-cloud-dashboard   // ia-cloud-dashboardのインストール

```
以上の3つのモジュールのインストールは、~/.node-red ディレクトリーで実行する必要があるので注意。  

ここまでで、Node-REDと必要なNodeモジュールがインストールされた。Node-REDを起動しブラウザーで接続すると、パレット上にia-cloud関連Nodeと、GrovePiのNodeが現れる。

### RaspberryPiのネットワーク設定スクリプトおよび設定データを配置する

raspbian起動時にネットワーク設定変更のスクリプトを走らせるため、必要なファイルを/bootから移動するため、以下の操作を行う。

#### /opt/ia-cloud/binを作成し、そこに/boot/ia-cloud-hands-on-start.shを移動する。  
```
sudo mkdir -p /opt/ia-cloud/bin
sudo mv /boot/ia-cloud-hands-on-start.sh /opt/ia-cloud/bin/
```
#### /boot/ia-cloud-hands-on-start.service.orgを/etc/systemd/system/に移動し、ia-cloud-hands-on-start.serviceに名称変更する。
```
sudo mv /boot/ia-cloud-hands-on-start.service.org /etc/systemd/system/ia-cloud-hands-on-start.service
```

#### systemdの変更設定を行う

systemdにユニットファイルを追加・更新したことを通知し、自動起動をenableに設定する。
```
sudo systemctl daemon-reload
sudo systemctl enable ia-cloud-hands-on-start.service
```

マスターSDカードの作癖は終了。
シャットダウンし、マイクロSDカードを取り出す。

## ハンズオンWS用の個別の起動マイクロSDカードの作成（PC or Mac での作業）

以下の手順で、実際の個別のマイクロSDカードを作成する。
- マスターSDカードをDiskコピーで必要枚数コピーし作成する。　　
- 個々のマイクロSDカードを、PCあるいはMacに挿入し、/boot/ia-cloud-hands-on-config.json.orgを編集し、必要なネットワーク設定を記述する。
```
{
  "name" : "RaspberryPi configuration at the first boot",     // 名称を自由に設定
  "comment" : "test for configuration procedure",             // コメントを自由に記述
	"lan-config" : { "ip-address" : "192.168.xx.xx/24", "default-gateway" : "192.168.xx.xx" },    // 固定IPアドレスを設定
	"wifi-config" : { "type" : "wpsかwepを設定", "ssid" : "ssid文字列を設定", "password" : "パスワード文字列を設定" },      // WifiのSSIDとパスワードを設定
	"hostname" : "ホストネイムを設定"                                  // hostnameの設定
}
```
- ファイル名ia-cloud-hands-on-config.json.orgをia-cloud-hands-on-config.jsonに変更する。
```
sudo mv /boot/ia-cloud-hands-on-config.json.org /boot/ia-cloud-hands-on-config.json
```
