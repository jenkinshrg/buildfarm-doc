====================
テストサーバーの管理
====================

テストサーバーを構築、運用するための手順について説明します。

現在運用中のサーバー構成は以下の通りです。

.. csv-table::
  :header: ノード名, 用途, ジョブ同時実行数, 備考

  master, テスト実行管理, 0, ラック中段、core i5、mem 15GB、HDD 150GB+5TB、eth2（固定IP)
  slave1, テスト実行環境（並列実行可能ジョブ用）, 3, ラック上段、core i5、mem 15GB、HDD 150GB、eth2（dhcp）
  slave2, テスト実行環境（並列実行不可ジョブ用）, 1, ラック下段、core i5、mem 15GB、HDD 150GB、eth2（dhcp）

.. note::

  マスターサーバーとスレーブサーバーを同じマシンに同居させて1台で運用することも可能ですが、テスト実行へ悪影響が発生する可能性があるため別マシンにすることを推奨します。

.. note::

  マスターサーバー上でもテストを実行することは可能ですが、設定データや履歴データのバックアップ時に不要なワークスペースが含まれてしまうためマスターサーバーではテストを実行させない運用としています。（マスターサーバーのジョブ同時実行数を0に設定）

.. note::

  テスト内容によっては並列実行させるとリソースの競合や負荷の問題が発生する場合があるため、並列実行可能なスレーブサーバーと並列実行が不可能なスレーブサーバーに分けて運用しています。（スレーブサーバーのジョブ同時実行数で設定）

事前準備
========

マスターサーバーとスレーブサーバー共通のインストール手順を説明します。

マシンの設置
------------

インターネット接続が可能なマシンを設置して下さい。

マスターサーバーは特にハードウェア要件はありませんが、サイズの大きなログを長期間保存する場合は大きめのハードディスクを用意して下さい。

スレーブサーバーはテストの実行に必要なハードウェア要件（GPUなど）にあったものを用意して下さい。

OSインストール
--------------

OSはテストの実行に必要なソフトウェア要件（OSバージョンなど）にあったものを用意して下さい。

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

  Ubuntu 14.04 LTS Desktopで動作確認しています。

.. note::

  ハードウェアに依存しないテストの場合はvirtualbox等の仮想マシンを利用してスレーブサーバーを追加すれば異なるOS環境でのテスト実行が可能です。（テスト内容によっては正常動作しない場合があります）

.. note::

  カーネルに依存しないテストの場合はdocker等のlinuxコンテナを利用してスレーブサーバーを追加せずに異なるOS環境でのテスト実行が可能です。（テスト内容によっては正常動作しない場合があります）

.. warning::

  マスターサーバーは固定IPアドレスでjenkinshrg.a01.aist.go.jpでアクセスできるようにDNSに登録されている必要があります。

.. warning::

  スレーブサーバーはchoreonoidによるGUIテスト自動化の妨げとなるため「システム設定」の「ユーザーアカウント」にてログインユーザーを自動ログインに設定、「画面の明るさとロック」にて画面オフしない、ロックしない、パスワードなしに設定しておく必要があります。

共通インストール
----------------

gitをインストールします。

.. code-block:: bash

  $ sudo apt-get install git

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm
  
マスターサーバーとスレーブサーバーで共通で必要なパッケージをインストールします。(設定のカスタマイズを含みます)

.. code-block:: bash

  $ ./setup/common.sh

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

その他必要なソフトウェアがあればインストールを行って下さい。

マスターサーバーの構築
======================

マスターサーバーで以下の手順を実施して下さい。

インストール
------------

.. warning::

  他のアプリケーションがポート番号8080と9000を使用していないか確認して下さい。

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm
  
マスターサーバーをインストールします。(必要なプラグインのインストール、設定のカスタマイズを含みます)

.. code-block:: bash

  $ ./setup/master.sh

.. note::

  jenkinsパッケージのインストールを行うとjenkinsユーザー、jenkinsグループが作成されます。
  
以下のURLへブラウザで接続して正しく表示されることを確認して下さい。

http://localhost:8080

リバースプロキシの設定
----------------------

マスターサーバーへTCPポート80でアクセスできるように設定します。（以下にnginxでリバースプロキシを設定する場合の例を示します）

webサーバーをインストールします。

.. warning::

  他のアプリケーションがポート番号80を使用していないか確認して下さい。

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

スレーブサーバーの構築
======================

スレーブサーバーで以下の手順を実施して下さい。

スレーブサーバーの登録
----------------------

スレーブサーバーの情報をマスターサーバーへ登録します。

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

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

インストール
------------

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm
  
スレーブサーバーをインストールします。

.. code-block:: bash

  $ ./setup/slave_desktop.sh <nodename>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  nodename, ノード名,

.. warning::

  通常スレーブサーバーの起動はシステムのサービス（デーモン）としてinit.dスクリプトなどで自動起動させますが、デスクトップアプリケーションを実行可能とするためにユーザーのデスクトップログイン時に自動起動されるランチャーを$HOME/.config/autostartへ登録する形で実現しています。通常のサービスで良い場合はslave.shを実行して下さい。

以下のURLへブラウザで接続してスレーブサーバーが接続されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

スレーブサーバーの削除
----------------------

スレーブサーバーの情報をマスターサーバーから削除します。

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーからスレーブサーバーを削除します。

.. code-block:: bash

  $ ./scripts/deletenode.sh <nodename>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  nodename, ノード名,

以下のURLへブラウザで接続してスレーブサーバーが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

認証情報の設定
==============

テストジョブでは対話形式のコマンドは実行できないため、認証情報が必要な外部サーバーへアクセスを行う場合は事前に以下の設定が必要となります。（セキュリティー面を考慮して認証情報を設定ファイルやスクリプトに保存しないで下さい）

マスターサーバー、スレーブサーバー全てに対してそれぞれ設定を行って下さい。

gitの設定(共通）
---------------

gitのユーザー設定をします。

.. code-block:: bash

  $ git config --global user.email "jenkinshrg@gmail.com"
  $ git config --global user.name "jenkinshrg"
  $ git config --global credential.helper store
  $ git config --global http.sslVerify false

マスターサーバーの場合は$HOME/.gitconfigを$JENKINS_HOME（/var/lib/jenkins）へコピーします。

.. code-block:: bash

  $ sudo cp $HOME/.gitconfig /var/lib/jenkins
  $ sudo chown jenkins:jenkins /var/lib/jenkins/.gitconfig

gitの設定(http経由）
--------------------

http経由でアクセスする場合は$HOME/.git-credentialsを作成します。

.. code-block:: bash

  $ cat << EOL | tee $HOME/.netrc
  https://<username>:<password>@choreonoid.org
  https://<username>:<password>@github.com
  EOL

マスターサーバーの場合は$HOME/.git-credentialsを$JENKINS_HOME（/var/lib/jenkins）へコピーします。

.. code-block:: bash

  $ sudo cp $HOME/.git-credentials /var/lib/jenkins
  $ sudo chown jenkins:jenkins /var/lib/jenkins/.git-credentials

gitの設定(ssh経由）
-------------------

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

マスターサーバーの場合は$HOME/.sshを$JENKINS_HOME（/var/lib/jenkins）へコピーします。

.. code-block:: bash

  $ sudo cp -r $HOME/.ssh /var/lib/jenkins
  $ sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh

Google Driveの設定
------------------

ログをGoogle Driveへアップロードするために以下の設定を行って下さい。

Google Developers Consoleへjenkinshrgでログインします。

https://console.developers.google.com

API Managerの認証情報でDrive APIのclient_idとclient_secretを作成します。

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

メンテナンス
============

アップデート
------------

unattended-upgradesにて自動アップデート、リブートを実施します。（cron.daily経由で6:25に起動され最大1800秒遅延して実行されます）

シャットダウン
--------------

テストジョブが実行されていないのを確認してから通常のシャットダウン手順を実行して下さい。（再起動時に自動的にサービスが再開されます）

サーバー移設
------------

サーバーの設置場所の変更などでMACアドレスやIPアドレスが変更になっても問題ありません。

サーバー交換
------------

故障などでハードウェア交換を行う場合は再度インストール手順を実施して下さい。（マスターサーバーのバックアップデータがある場合はリストア手順を実施して下さい）

バックアップとリストア
----------------------

テストサーバーの設定と履歴データはマスターサーバーにあります。（スレーブサーバーのデータは消えてしまっても問題ありません）

バックアップは以下の手順を実行して下さい。

.. code-block:: bash

  $ sudo service jenkins stop
  $ sudo tar zcvf jenkins.tar.gz -C /var/lib jenkins
  $ sudo service jenkins start

リストアは以下の手順を実行して下さい。

.. code-block:: bash

  $ sudo service jenkins stop
  $ sudo tar zxvf jenkins.tar.gz -C /var/lib
  $ sudo service jenkins start

仮想マシンによるテストサーバーの構築（オプション）
=================================================

仮想マシン上にマスターサーバー、スレーブサーバーを構築することも可能です。（テスト内容によっては正常動作しない場合があります）

ローカル環境でのマスターサーバー、スレーブサーバーの起動
--------------------------------------------------------

一時的な確認用などでローカル環境でテストサーバーを起動したいは以下の手順で起動します。

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーを起動します。（Ubuntu14.04LTS環境でmasterというノード名でvirtualboxのプライベートネットワークで接続）

.. code-block:: bash

  $ vagrant up master

スレーブサーバーを起動します。（Ubuntu14.04LTS環境でslaveというノード名でvirtualboxのプライベートネットワークで接続）

.. code-block:: bash

  $ vagrant up slave

リモート環境へのスレーブサーバーの追加
--------------------------------------

一時的な確認用などでリモートのマスターサーバーへスレーブサーバーを追加したいは以下の手順で起動します。

Vagrantfileにスレーブの記述を追加します。（以下はUbuntu16.04LTS環境でubuntu-xenial-amd64というノード名でhttp://jenkinshrg.a01.aist.go.jpへ接続する場合の例）

.. code-block:: ruby

  config.vm.define "ubuntu-xenial-amd64", autostart: false do |server|
    server.vm.box = "ubuntu/xenial64"
    server.vm.provision "shell", path: "scripts/createnode.sh", args: "ubuntu-xenial-amd64 /home/vagrant http://jenkinshrg.a01.aist.go.jp", privileged: false
    server.vm.provision "shell", path: "setup/slave.sh", args: "ubuntu-xenial-amd64 http://jenkinshrg.a01.aist.go.jp", privileged: false
  end

スレーブサーバーを起動します。

.. code-block:: bash

  $ vagrant up ubuntu-xenial-amd64
