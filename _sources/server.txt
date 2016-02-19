====================
テストサーバーの管理
====================

テストサーバーを構築、運用するための手順について説明します。

サーバー構成
============

.. csv-table::
  :header: ホスト名, 用途, DNS名, IPアドレス, 備考
  :widths: 5, 5, 5, 5, 5

  master, マスターサーバー（実行、履歴管理）, jenkinshrg.a01.aist.go.jp, 固定, ラック中段、eth2
  slave, スレーブサーバー（テスト実行）, dhcp, dhcp, ラック下段、eth2

事前準備
========

物理マシンの設置
----------------

インターネット接続が可能なマシンを設置して下さい。

マスターサーバーは特にハードウェア要件はありませんが、サイズの大きなログを長期間保存する場合は大きめのハードディスクを用意して下さい。

スレーブサーバーはテストの実行に必要なハードウェア要件（GPUなど）にあったものを用意して下さい。

マスターサーバーとスレーブサーバーを同じマシンに同居させることも可能ですが、テスト実行による悪影響が発生する場合があるため別マシンにすることを推奨します。

OSインストール
--------------

OSはテストの実行に必要なソフトウェア要件にあったものを用意して下さい。（Ubuntu 14.04 LTSで動作確認済みです）

ハードウェアに依存しないテストの場合はvirtualbox等の仮想マシンを利用して1つのスレーブサーバーで異なるOS環境でのテスト実行が可能です。（テスト内容によっては正常動作しない場合があります）

カーネルに依存しないテストの場合はdocker等のlinuxコンテナを利用して1つのスレーブサーバーで異なるOS環境でのテスト実行が可能です。（テスト内容によっては正常動作しない場合があります）

ホスト名、ユーザー名は任意で設定して下さい。

設置場所の環境に合わせてネットワーク設定を行って下さい。

セキュリティーアップデート、その他必要なソフトウェアがあればインストールを行って下さい。

.. warning::

  GPUなどプロプライエタリなドライバが必要な場合はインストールしてシステム設定にて変更しておきます。

.. code-block:: bash

  $ sudo add-apt-repository -y ppa:xorg-edgers/ppa
  $ sudo apt-get update
  $ sudo apt-get -y install nvidia-current nvidia-settings

.. warning::

  システム設定にて自動ログイン、スクリーンセーバー、画面ロックは解除しておきます。

マスターサーバーの構築
======================

テストジョブの実行と履歴管理のためにマスターサーバーが必要となります。

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

ブラウザで正しく表示されることを確認して下さい。

http://localhost:8080

リバースプロキシの設定
----------------------

.. warning::

  マスターサーバーはスレーブサーバーやWebアクセスする場合にDNS名や固定IPアドレスでアクセスできるように設定して下さい。

マスターサーバーへリバースプロキシを設定する場合の例を示します。

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

ブラウザで以下のURLが正しく表示されることを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

スレーブサーバーの構築
======================

テストジョブを実行するためにスレーブサーバーが必要となります。

マスターサーバー上でもテストを実行することは可能ですが、設定データや履歴データのバックアップを考慮してマスターサーバーではテストは実行せず、必ずスレーブサーバーでテストを実行する運用が好ましいです。

インストール
------------

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm
  
スレーブサーバーをインストールします。

.. code-block:: bash

  $ ./setup/slave.sh

スレーブサーバーの追加
----------------------

.. warning::

  マスターサーバーが起動していることを確認して下さい。

スレーブサーバーを追加します。

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーへスレーブサーバーを登録します。

.. code-block:: bash

  $ ./scripts/createnode.sh <nodename> <workspace> <url>

ブラウザでスレーブサーバーが接続されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

スレーブサーバーの削除
----------------------

.. warning::

  マスターサーバーが起動していることを確認して下さい。

スレーブサーバーを削除します。

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーからスレーブサーバーを削除します。

.. code-block:: bash

  $ ./scripts/deletenode.sh <nodename> <url>

ブラウザでスレーブサーバーが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

認証情報の設定
==============

テストジョブでは対話形式のコマンドは実行できないため、認証情報が必要な外部サーバーへアクセスを行う場合は事前に以下の設定が必要となります。

マスターサーバー、スレーブサーバー全てに対してそれぞれ設定を行って下さい。

セキュリティー面を考慮して認証情報を設定ファイルやスクリプトに保存しないで下さい。

gitの設定
---------

http経由でアクセスする場合は$HOME/.netrcをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp $HOME/.netrc /var/lib/jenkins
  $ sudo chown jenkins:jenkins /var/lib/jenkins/.netrc

.. code-block:: bash

  $ sudo cp $HOME/.netrc /home/jenkinshrg
  $ sudo chown jenkins:jenkins /home/jenkinshrg/.netrc

ssh経由でアクセスする場合は$HOME/.sshをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp -r $HOME/.ssh /var/lib/jenkins
  $ sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
  $ sudo -u jenkins ssh-keygen -N "" -f /var/lib/jenkins/.ssh/id_rsa
  $ sudo -i -u jenkins ssh-copy-id jenkinshrg@atom.a01.aist.go.jp

.. code-block:: bash

  $ sudo cp -r $HOME/.ssh /home/jenkinshrg
  $ sudo chown -R jenkins:jenkins /home/jenkinshrg/.ssh
  $ ssh-keygen -N "" -f ${HOME}/.ssh/id_rsa
  $ ssh-copy-id jenkinshrg@atom.a01.aist.go.jp

subversionの設定
----------------

subversionの場合は$HOME/.subversionをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp -r $HOME/.subversion /var/lib/jenkins
  $ sudo chown -R jenkins:jenkins /var/lib/jenkins/.subversion

.. code-block:: bash

  $ sudo cp -r $HOME/.subversion /home/jenkinshrg
  $ sudo chown -R jenkins:jenkins /home/jenkinshrg/.subversion

シャットダウン
==============

停電時などサーバーを停止させる場合は通常のシャットダウン手順で問題ありません。

再起動時も自動的にサービスが再開されます。

サーバー移設
============

サーバーの設置場所を変更するなどでMACアドレス、IPアドレスが変更になっても問題ありません。

マスターサーバーのDNSホスト名、固定IPアドレスが正しく疎通できるようMACアドレスを再設定して下さい。

バックアップ
============

テストジョブが実行されていないのを確認して以下の手順を実行して下さい。

.. code-block:: bash

  $ sudo service jenkins stop
  $ sudo tar zcvf jenkins.tar.gz -C /var/lib jenkins
  $ sudo service jenkins start

リストア
========

マスターサーバーのインストールを行ったあと以下の手順を実行して下さい。

.. code-block:: bash

  $ sudo service jenkins stop
  $ sudo tar zxvf jenkins.tar.gz -C /var/lib
  $ sudo service jenkins start

仮想マシンによるテストサーバーの構築（オプション）
=================================================

マスターサーバー、スレーブサーバーは仮想マシン上に構築することも可能です。

virtualbox、vagrantがインストールされていない場合はインストールして下さい。

マスターサーバーを仮想マシン上に構築する場合
--------------------------------------------

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーを起動します。

.. code-block:: bash

  $ vagrant up

スレーブサーバーを仮想マシン上に構築する場合
--------------------------------------------

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

Vagrantfileにスレーブの記述を追加します。（以下はUbuntu16.04LTSを追加する場合）

.. code-block:: ruby

  config.vm.define "ubuntu-xenial-amd64", autostart: false do |server|
    server.vm.box = "boxcutter/ubuntu1604"
    server.vm.provision "shell", path: "scripts/createnode.sh", args: "ubuntu-xenial-amd64 /home/vagrant http://jenkinshrg.a01.aist.go.jp", privileged: false
    server.vm.provision "shell", path: "setup/slave.sh", args: "ubuntu-xenial-amd64 http://jenkinshrg.a01.aist.go.jp", privileged: false
  end

スレーブサーバーを起動します。

.. code-block:: bash

  $ vagrant up ubuntu-xenial-amd64
