# DIY実践IoT活用ハンズオンワークショップ

## RaspberryPi（Raspbian）のインストールとネットワーク環境設定に関するドキュメントとスクリプトおよび設定データ

## 概要
これら一連のファイルは、IAF ia-cloudプロジェクトが実施支援する、DIY実践IoT活用ハンズオンワークショップ（以下ハンズオンWS）で使用されるRaspberryPi(Raspbian)のインストールと環境設定に必要なデータファイル、スクリプトおよびそれらのドキュメントである。

## ハンズオンWS用マスターSDの作成 （その1：PC or Mac での作業）

### マスターマイクロSDカードの作成
- Raspbian公式サイトから、イメージファイルをダウンロード。(2019年7月時点では、Buster Desktop版を利用)
- 使用するマイクロSDカードの容量は、最小8GB、最大32GBである。ハンズオンWS用に同一のSDカードをDiskコピーで作成するため、マスターカードにはコピー時間の短い8GBを使用する。
- マイクロSDカードにイメージを転送
#### 最新版Busterは、Node-REDのインストールスクリプトが、Node.jsインストール時に、npmがないとのエラーを吐いて止まってしまうため、後述のインストールスクリプト実行前に、atp-getのupdateコマンドを実行する必要がある


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

- 削除予定  
また、設定ファイルに "resize" = "yes" が設定されていると、resize2fsコマンドを実行し、ファイルシステムをパーティションの最大まで拡張する。

変更後は、ia-cloud-hands-on-config.json のファイル名を、ia-cloud-hands-on-config.json.org に変更し再起動を行う。  

#### Raspbianの /boot 直下に、handson.setup/ia-cloud-hands-on-config.json.org を配置する。  
このファイルは、個別にネットワーク設定を変更するスクリプト、ia-cloud-hands-on-config.shが参照するデータファイルである。ハンズオンWS用の個別の起動マイクロSDカードの作成の際に、必要な設定を行なった後ia-cloud-hands-on-config.jsonにファイル名変更される。  
このファイルの内容は以下である。
```
{
  "name" : "RaspberryPi configuration at the first boot",
  "comment" : "test for configuration procedure",
  "lan-config" : { "ip-address" : "192.168.xx.xx/24", "default-gateway" : "192.168.xx.xx" },
  "wifi-config" : { "type" : "wep", "ssid" : "xxxxxxxxxx", "password" : "xxxxxxxxx" },
  "hostname" : "xxxxxxxxx"
}
```

#### Raspbianの初回起動時に実行される、/boot/cmdline.txtのコピーを保存する

Raspbianの /boot 直下にある、cmdline.txt を、cmdline.txt.org にコピーする
このファイルは、Raspbianの起動時に実行されるコマンドファイルである。初回起動時にSDカードのパーティションの拡張を行い、そのスクリプト起動コマンドを削除してしまうので、コピーDisk作成時に復元するため、コピーを保存する。

#### Node-RED環境や起動時実行の環境など一連の操作をまとめたスクリプトを配置する。

後述のNode-REDインストールをはじめ一連の環境設定のための手順をスクリプトにまとめたファイル、handson.setup/ia-cloud-hands-on-install.shを、/bootに配置する。

## ハンズオンWS用マスターSDの作成 （その2：RaspberryPi での作業）

### Raspbianのインストール
以下の手順を追うこと。

- RaspberyyPiに装着し起動（マウス・キーボード・モニタが必要）
- Busterの初期画面が起動。初期設定画面に従い、インストールを継続
- countryをJAPANに設定
- piユーザのパスワード変更を求められるが無視して続行
- モニタスクリーンのアンダースキャンの確認：どっちでも良い。
- ネットワークの設定は、インストール実行時の環境で設定（LANはデフォルトでDHCP有効になっている。Wifiの場合はここで設定）
- アップデート後再起動。
- 再起動後、Busterのデスクトップ画面が起動する。
- Raspbianのメインメニューから、設定 -> RaspberryPiの設定　を起動
- システムのタブから解像度の設定を選択し、解像度をCEA mode4 1280X720 60Hz 16:9 に設定
- インターフェースタブで、カメラ・SSH・VNC・SPI・I2C・Serial Port　を有効にする。
- 再起動を求められるので再起動
- 再起動後、ユーザpiのパスワードを変更していないとの警告が出るが、ここは無視。

***次のスクリプト、　　  
/boot/ia-cloud-hands-on-install.sh  
は、以下の一連の手順を自動実行する。途中で、会話型の入力を求められるので「ｙ」を入力する必要はある。***

### ia-cloud関連カスタムNodeとその依存コード類のインストール
RaspberryPiのコンソールないしは、VNC/SSHから操作。

まず、Raspbian Busterでのインストールスクリプト前に、以下のコマンドでaptをupdateする。
```
sudo apt update          // aptのupdateコマンド
```
以下のコマンドラインで、必要なJSONハンドリングモジュールをインストールする
```
sudo apt install jq          // JSON処理シェルコマンド
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

マスターSDカードの作成は終了。


#### シャットダウンし、マイクロSDカードを取り出す。


## ハンズオンWS用の個別の起動マイクロSDカードの作成（PC or Mac での作業）

以下の手順で、実際のハンズオンで各受講者が使用する個別のマイクロSDカードを作成する。

### マスターSDカードのイメージファイルを作成する。（以下、Macでの例）

マスターのSDカードをMacに接続し、ターミナルから以下の作業を実施。  

SDカードのイメージファイルは、ホームディレクトリーのhands-on-master.imgとして保存される。
マスターSDカードのマウント先が、/dev/disk2 とすると、
```
sudo dd if=/dev/rdisk2 of=hands-on-master.img bs=1m
```
途中経過は表示されないが、Ctl+ｔで経過を表示できる。  


### 受講者が使用する個別のマイクロSDカードを作成。（ハンズオンWS参加者の数だけ実行）

#### ハンズオンで使用するマイクロSDカードをフォーマットし、hands-on-master.imgを転送する。
使用するSDカードのは、容量32GBの物を使用する。  
SDカード転送アプリを利用。(Mac:balenaEtcher、Windows:Win32DiskImager等)

#### コピーしたSDカードでの起動確認と、パーティション・ファイルシステムの拡張
コピーしたSDカードを挿入し、Raspbianが起動することを確認する。  
現在のrootファイルシステムのパーティションを削除し、新しい最大のパーティションを作成する。
```
sudo fdisk /dev/mmcblk0
```
以下、対話型のコマンド実行
```
Welcome to fdisk (util-linux 2.33.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p
Disk /dev/mmcblk0: 29.8 GiB, 32026656768 bytes, 62552064 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x54916f85

Device         Boot  Start      End  Sectors  Size Id Type
/dev/mmcblk0p1        8192   532480   524289  256M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      540672 15138815 14598144    7G 83 Linux

Command (m for help): d
Partition number (1,2, default 2): 2

Partition 2 has been deleted.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 2
First sector (2048-62552063, default 2048): 540672
Last sector, +/-sectors or +/-size{K,M,G,T,P} (540672-62552063, default 62552063):

Created a new partition 2 of type 'Linux' and of size 29.6 GiB.
Partition #2 contains a ext4 signature.

Do you want to remove the signature? [Y]es/[N]o: N

Command (m for help): w
The partition table has been altered.
Syncing disks.

pi@raspberrypi:~ $ sudo resize2fs /dev/mmcblk0p2
resize2fs 1.44.5 (15-Dec-2018)
Filesystem at /dev/mmcblk0p2 is mounted on /; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/mmcblk0p2 is now 7751424 (4k) blocks long.


```

ファイルシステムをパーティション最大に拡張する。
```
sudo resize2fs /dev/mmcblk0p2
```
結果
```
reresize2fs 1.44.5 (15-Dec-2018)
Filesystem at /dev/mmcblk0p2 is mounted on /; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/mmcblk0p2 is now 7751424 (4k) blocks long.
```
これで、ファイルシステムが拡張された。ファイルマネージャで残り容量が29GBあることを確認する。

**これで、ハンズオンWS用のSDカードは完成である。各参加者用に、上記の表題「受講者が使用する個別のマイクロSDカードを作成。（ハンズオンWS参加者の数だけ実行）」からここまでを枚数分繰り返す。**

#### 参加者ごとのネットワーク設定のための起動時設定ファイルを編集し、リネームする。
/boot/ia-cloud-hands-on-config.json.orgを編集し、必要なネットワーク設定を記述する。  
ラズパイ上で作業しても、PCやMac上で作業しても構わない。

```
{
  "name" : "RaspberryPi configuration at the first boot",     // 名称を自由に設定
  "comment" : "test for configuration procedure",             // コメントを自由に記述
  "lan-config" : { "ip-address" : "192.168.xx.xx/24", "default-gateway" : "192.168.xx.xx" },    // 固定IPアドレスを設定
  "wifi-config" : { "type" : "wpsかwepを設定", "ssid" : "ssid文字列を設定", "password" : "パスワード文字列を設定" },      // WifiのSSIDとパスワードを設定
  "hostname" : "ホストネイムを設定"                                // hostnameの設定
}
```
- ファイル名ia-cloud-hands-on-config.json.orgをia-cloud-hands-on-config.jsonに変更する。

**Raspbianを再起動すると、新しい設定が反映され、個別のSDカードが完成する。**
