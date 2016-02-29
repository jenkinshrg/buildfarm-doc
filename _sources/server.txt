====================
テストサーバーの管理
====================

テストサーバーを構築、運用するための手順について説明します。

現在運用中のサーバー構成は以下の通りです。

.. csv-table::
  :header: ノード名, 用途, ジョブ同時実行数, 備考

  master, テスト実行管理, 0, ラック中段、固定IP
  slave1, テスト実行環境（並列実行可能ジョブ用）, 4, ラック上段、dhcp
  slave2, テスト実行環境（並列実行不可ジョブ用）, 1, ラック下段、dhcp

.. note::

  マスターサーバーとスレーブサーバーを同じマシンに同居させて1台で運用することも可能ですが、テスト実行へ悪影響が発生する可能性があるため別マシンにすることを推奨します。

.. note::

  マスターサーバー上でもテストを実行することは可能ですが、設定データや履歴データのバックアップ時に不要なワークスペースが含まれてしまうためマスターサーバーではテストを実行させない運用としています。（マスターサーバーのジョブ同時実行数を0に設定）

.. note::

  テスト内容によっては並列実行させるとリソースの競合や負荷の問題が発生する場合があるため、並列実行可能なスレーブサーバーと並列実行が不可能なスレーブサーバーに分けて運用しています。（スレーブサーバーのジョブ同時実行数で設定）

.. note::

  ハードウェアに依存しないテストの場合はvirtualbox等の仮想マシンを利用してスレーブサーバーを追加すれば異なるOS環境でのテスト実行が可能です。（テスト内容によっては正常動作しない場合があります）

.. note::

  カーネルに依存しないテストの場合はdocker等のlinuxコンテナを利用してスレーブサーバーを追加せずに異なるOS環境でのテスト実行が可能です。（テスト内容によっては正常動作しない場合があります）

事前準備
========

マスターサーバーとスレーブサーバー共通で実施するインストール手順を説明します。

マシンの設置
------------

インターネット接続が可能なマシンを設置して下さい。

マスターサーバーは特にハードウェア要件はありませんが、サイズの大きなログを長期間保存する場合は大きめのハードディスクを用意して下さい。

スレーブサーバーはテストの実行に必要なハードウェア要件（GPUなど）にあったものを用意して下さい。

現在運用中のマシンスペックは以下の通りです。

.. csv-table::
  :header: 項目, スペック, 備考

  CPU, core i5,
  メモリ, 15GB,
  ハードディスク, 150GB SSD, マスターサーバーのみUSB-HDD 5TBを/var/lib/jenkinsへマウント
  network, ethernet×3, eth2のみ使用

OSインストール
--------------

テストの実行に必要なソフトウェア要件（OSバージョンなど）にあったOSをインストールして下さい。

インストーラーの設定は以下の通りです。

.. csv-table::
  :header: 設定項目, 設定内容, 備考

  パーティション, 任意, LVMを設定
  タイムゾーン, 任意, Asia/Tokyoを設定
  言語, 任意, 日本語を設定
  ホスト名, 任意, master、slave1、slave2を設定 
  ユーザー名, 任意, jenkinshrgを設定

インストール終了後にセキュリティーアップデートを行って下さい。

ネットワークは設置場所の環境に合わせて適切に設定して下さい。

ミラーサーバーは設置場所の環境に合わせて最速なものに変更しておきます。

NVIDIAのグラフィックボードなどプロプライエタリなドライバでないと正しく動作しない場合はドライバをインストールして「システム設定」の「ソフトウェアとアップデート」の「追加のドライバ」で選択して変更の適用をしておきます。（以下にNVIDIAドライバのインストール例を示します）

.. code-block:: bash

  $ sudo add-apt-repository -y ppa:xorg-edgers/ppa
  $ sudo apt-get update
  $ sudo apt-get -y install nvidia-current nvidia-settings

.. note::

  本手順はUbuntu 14.04 LTS Desktopで動作確認しています。

.. warning::

  マスターサーバーは固定IPアドレスでjenkinshrg.a01.aist.go.jpでアクセスできるようにDNSに登録されている必要があります。

.. warning::

  スレーブサーバーはchoreonoidによるGUIテスト自動化の妨げとなるため「システム設定」の「ユーザーアカウント」にてログインユーザーを自動ログインに設定、「画面の明るさとロック」にて画面オフしない、ロックしない、パスワードなしに設定しておく必要があります。

ツールスクリプトの用意
----------------------

gitをインストールします。

.. code-block:: bash

  $ sudo apt-get install git

サーバーの構築を行うツールスクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm
  
共通パッケージのインストール
----------------------------

マスターサーバーとスレーブサーバーで共通で必要なパッケージをインストールして下さい。(設定のカスタマイズを含みます)

.. code-block:: bash

  $ ./setup/common.sh

その他必要なソフトウェアがあればインストールを行って下さい。

認証情報の設定
--------------

テストジョブでは対話形式のコマンドは実行できないため、認証情報が必要な外部サーバーへアクセスを行う場合は事前に以下の設定が必要となります。（セキュリティー面を考慮して認証情報を設定ファイルやスクリプトに保存しないで下さい）

マスターサーバー、スレーブサーバー全てに対してそれぞれ設定を行って下さい。

* gitの設定(共通）

gitのユーザー設定をしておきます。（$HOME/.gitconfigの作成）

.. code-block:: bash

  $ git config --global user.email "jenkinshrg@gmail.com"
  $ git config --global user.name "jenkinshrg"
  $ git config --global credential.helper store
  $ git config --global http.sslVerify false

* gitの設定(http経由）

http経由でアクセスする場合は$HOME/.git-credentialsを作成します。

.. code-block:: bash

  $ cat << EOL | tee $HOME/.git-credentials
  https://<username>:<password>@choreonoid.org
  https://<username>:<password>@github.com
  EOL

* gitの設定(ssh経由）

ssh経由でアクセスする場合は公開鍵を作成して登録します。

.. code-block:: bash

  $ ssh-keygen -N "" -f ${HOME}/.ssh/id_rsa
  $ ssh-copy-id <username>@atom.a01.aist.go.jp

$HOME/.ssh/configを作成します。

.. code-block:: bash

  $ cat << EOL | tee $HOME/.ssh/config
  Host atom.a01.aist.go.jp
  HostName atom.a01.aist.go.jp
  User <username>
  IdentityFile ~/.ssh/id_rsa
  StrictHostKeyChecking no
  EOL

* Google Driveの設定

ログをGoogle Driveへアップロードするために以下の設定を行って下さい。

Google Drive APIのclient_idとclient_secretをまだ作成していない場合は、Google Developers Consoleへjenkinshrgでログインして「API Manager」の「認証情報」で作成しておきます。

https://console.developers.google.com

$HOME/.jenkinshrg/env.shを作成します。

.. code-block:: bash

  $ mkdir -p $HOME/.jenkinshrg
  $ cat << EOL | tee $HOME/.jenkinshrg/env.sh
  export CLIENT_ID=<client_id>
  export CLIENT_SECRET=<client_secret>
  EOL

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/drcutil.git
  $ cd drcutil/.jenkins

$HOME/.jenkinshrg/env.shを読み込んで適当なファイルを転送することで初回の認証を行います。

.. code-block:: bash

  $ source $HOME/.jenkinshrg/env.sh
  $ python remoteBackup.py remoteBackup.py text/plain remoteBackup.py

認証コードの入力が促されます。

  $ Enter verification code:

ブラウザが自動起動されますので「アクセスを許可」すると認証コードが表示されますので入力するとファイル転送が行われ、$HOME/.jenkinshrg/jsonCredential.txtに認証情報が保存されます。

以降は認証なしでファイル転送が可能となります。

マスターサーバーの構築
======================

マスターサーバーで実施するインストール手順を説明します。

JENKINSのインストール
---------------------

JENKINSをインストールして下さい。

マスターサーバーをインストールします。(必要なプラグインのインストール、設定のカスタマイズを含みます)

.. code-block:: bash

  $ ./setup/master.sh

以下のURLへブラウザで接続して正しく表示されることを確認して下さい。

http://localhost:8080

.. note::

  jenkinsパッケージのインストールを行うとjenkinsユーザー、jenkinsグループが作成されます。
  
.. warning::

  他のアプリケーションがポート番号8080と9000を使用していないか予め確認して下さい。

リバースプロキシの設定
----------------------

マスターサーバーへTCPポート80でアクセスできるように設定して下さい。（以下にnginxでリバースプロキシを設定する場合の例を示します）

webサーバーをインストールします。

.. code-block:: bash

  $ sudo apt-add-repository -y ppa:nginx/stable
  $ sudo apt-get update
  $ sudo apt-get -y install nginx

リバースプロキシ設定を行います。

.. code-block:: bash

  $ cat << \EOL | sudo tee /etc/nginx/sites-available/default
  server {
          listen 80;
          server_name localhost;
          location / {
                  proxy_set_header Host $http_host;
                  proxy_pass http://localhost:8080;
          }
  }
  EOL
  $ sudo service nginx restart

以下のURLへブラウザで接続して正しく表示されることを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

.. warning::

  他のアプリケーションがポート番号80を使用していないか予め確認して下さい。

スレーブサーバーの構築
======================

スレーブサーバーで実施するインストール手順を説明します。

スレーブサーバーの登録
----------------------

スレーブサーバーの情報をマスターサーバーへ登録します。

マスターサーバーへスレーブサーバーを登録します。

.. code-block:: bash

  $ ./scripts/createnode.sh <nodename> <numexecutors>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  nodename, ノード名,
  numexecutors, ジョブ同時実行数,

以下のURLへブラウザで接続してスレーブサーバーが追加されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

JNLPスレーブの起動
------------------

JENKINSのスレーブサービスを起動して下さい。（自動起動の設定を含みます）

スレーブサーバーをインストールします。

.. code-block:: bash

  $ ./setup/slave_desktop.sh <nodename>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  nodename, ノード名,

以下のURLへブラウザで接続してスレーブサーバーが接続されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

.. note::

  通常スレーブサーバーの起動はシステムのサービス（デーモン）としてinit.dスクリプトなどで自動起動させますが、デスクトップアプリケーションを実行可能とするためにユーザーのデスクトップログイン時に自動起動されるランチャーを$HOME/.config/autostartへ登録する形で実現しています。通常のサービスで良い場合はslave.shを実行して下さい。

スレーブサーバーの削除
----------------------

不要になったスレーブサーバーの情報をマスターサーバーから削除します。

マスターサーバーからスレーブサーバーを削除します。

.. code-block:: bash

  $ ./scripts/deletenode.sh <nodename>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  nodename, ノード名,

以下のURLへブラウザで接続してスレーブサーバーが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

メンテナンス
============

アップデート
------------

unattended-upgradesにて自動でアップデート、リブートを実施するように設定しています。（cron.daily経由で6:25に起動され最大1800秒遅延して実行されます）

シャットダウン
--------------

テストジョブの実行が全て完了してから通常のシャットダウン手順を実行して下さい。（再起動時に自動的にサービスが再開されます）

JENKINSの画面で「JENKINSの管理」→「シャットダウンの準備」を行うことで新規テストジョブの実行を停止することができます。

サーバー移設
------------

サーバーの設置場所を移動するなどでMACアドレスやIPアドレスが変更になっても問題ありません。

サーバー交換
------------

故障などでハードウェア交換を行う場合は上記のインストール手順を再度実施して下さい。

JENKINSサーバーの各種設定と履歴データはマスターサーバー上の/var/lib/jenkinsにありますので、移行が必要な場合はマスターサーバーにて以下のバックアップ、リストア手順を実施して下さい。（スレーブサーバーのデータは消えてしまって問題ありません）

* バックアップ手順

.. code-block:: bash

  $ sudo service jenkins stop
  $ sudo tar zcvf jenkins.tar.gz -C /var/lib jenkins
  $ sudo service jenkins start

* リストア手順

.. code-block:: bash

  $ sudo service jenkins stop
  $ sudo tar zxvf jenkins.tar.gz -C /var/lib
  $ sudo service jenkins start

.. note::

  現在は上記のディレクトリ（/var/lib jenkins）を外付けHDDにマウントしていますので、旧マスターサーバーをシャットダウンして外付けHDDを外し、新マスターサーバーへ接続して/var/lib/jenkinsへの自動マウントを設定することでリストアが可能です。

仮想マシンによるテストサーバーの構築（オプション）
=================================================

仮想マシン上にマスターサーバー、スレーブサーバーを構築することも可能です。（テスト内容によっては正常動作しない場合があります）

仮想マシンのインストール
------------------------

virtualboxがインストールされていない場合はインストールして下さい。

.. code-block:: bash

  $ sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian '$(lsb_release -cs)' contrib' > /etc/apt/sources.list.d/virtualbox.list"
  $ wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
  $ sudo apt-get update
  $ sudo apt-get -y install virtualbox-5.0

vagrantがインストールされていない場合はインストールして下さい。

.. code-block:: bash

  $ wget -q https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb
  $ sudo dpkg -i vagrant_1.8.1_x86_64.deb
  $ rm vagrant_1.8.1_x86_64.deb

ローカル環境でのマスターサーバー、スレーブサーバーの起動
--------------------------------------------------------

ローカル環境でマスターサーバー、スレーブサーバーを起動したい場合は以下の手順で起動します。

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーを起動します。（Ubuntu14.04LTS環境でmasterというノード名でvirtualboxのプライベートネットワークで接続）

.. code-block:: bash

  $ vagrant up master

環境変数をローカル環境用に設定します。

.. code-block:: bash

  $ export JENKINS_URL=http://localhost:8080
  $ export REMOTE_FS=/home/jenkins-slave

マスターサーバーへスレーブサーバーを登録します。

.. code-block:: bash

  $ ./scripts/createnode.sh slave1 4
  $ ./scripts/createnode.sh slave2 1

スレーブサーバーを起動します。（Ubuntu14.04LTS環境でslave1、slave2というノード名でvirtualboxのプライベートネットワークで接続）

.. code-block:: bash

  $ vagrant up slave1 slave2

リモート環境へのスレーブサーバーの追加
--------------------------------------

リモートのマスターサーバーへスレーブサーバーを追加したい場合は以下の手順で起動します。

Vagrantfileにスレーブの記述を追加します。（以下はUbuntu16.04LTS環境でubuntu-xenial-amd64というノード名でhttp://jenkinshrg.a01.aist.go.jpへ接続する場合の例）

.. code-block:: ruby

  config.vm.define "ubuntu-xenial-amd64", autostart: false do |server|
    server.vm.box = "ubuntu/xenial64"
    server.vm.provision "shell", path: "scripts/createnode.sh", args: "ubuntu-xenial-amd64 /home/vagrant http://jenkinshrg.a01.aist.go.jp", privileged: false
    server.vm.provision "shell", path: "setup/slave.sh", args: "ubuntu-xenial-amd64 http://jenkinshrg.a01.aist.go.jp", privileged: false
  end

マスターサーバーへスレーブサーバーを登録します。

.. code-block:: bash

  $ ./scripts/createnode.sh ubuntu-xenial-amd64 1

環境変数をリモート環境用に設定します。

.. code-block:: bash

  $ export JENKINS_URL=http://jenkinshrg.a01.aist.go.jp
  $ export REMOTE_FS=/home/jenkins-slave

スレーブサーバーを起動します。

.. code-block:: bash

  $ vagrant up ubuntu-xenial-amd64
