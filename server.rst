====================
テストサーバーの管理
====================

Contents:

.. toctree::
   :maxdepth: 2

   master
   slave
   credential
   proxy

マスターサーバーの構築
======================

テストジョブの実行管理、履歴管理のためマスターサーバーが必要となります。

マスターサーバー上でもテストを実行することは可能ですが、設定データや履歴データのバックアップを考慮してマスターサーバーではテストは実行せず、必ずスレーブサーバーを追加して運用する設定とします。

インストール
============

.. note::

  インターネット接続が可能なマシンを用意して下さい。ハイスペックなマシンは必要ありませんが、サイズの大きなログを長期間保存する場合は大きめのハードディスクを用意して下さい。

.. note::

  ネットワーク設定、セキュリティーアップデート、その他必要なソフトウェアのインストールなどは事前に行っておいて下さい。

.. warning::

  他のアプリケーションがポート番号8080を使用していないか確認して下さい。

githubから以下のリポジトリをクローンします。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーをインストールします。(必要なプラグインのインストール、設定のカスタマイズを含みます)

.. code-block:: bash

  $ ./setup/master.sh

ブラウザで以下のURLが正しく表示されることを確認して下さい。

http://localhost:8080

仮想マシン
============

virtualboxをインストールします。

.. code-block:: bash

  $ ./setup/virtualbox.sh

vagrantをインストールします。

.. code-block:: bash

  $ ./setup/vagrant.sh

マスターサーバーを起動します。

.. code-block:: bash

  $ vagrant up

スレーブサーバーの構築
======================

テストジョブを実行するためのスレーブサーバーを用意して下さい。

.. note::

  インターネット接続が可能なマシンを用意して下さい。マシンスペックによっては、マスターサーバーと同じマシンにスレーブサーバーを同居させることも可能です。

.. note::

  ネットワーク設定、セキュリティーアップデート、その他必要なソフトウェアのインストールなどは事前に行っておいて下さい。

.. note::

  jenkinshrgでユーザーを作成しておいて下さい。

ユーザーがパスワード無しでsudoできるように設定しておきます。

.. code-block:: bash

  $ sudo sh -c 'echo "jenkinshrg ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

choreonoidを実行する場合はプロプライエタリなドライバをインストールしてシステム設定にて変更しておきます。

.. code-block:: bash

  $ sudo add-apt-repository -y ppa:xorg-edgers/ppa
  $ sudo apt-get update
  $ sudo apt-get -y install nvidia-current nvidia-settings

.. warning::

  自動ログイン、スクリーンセーバー、画面ロックを解除しておきます。

.. warning::

  マスターサーバーが起動していることを確認して下さい。

インストール
============

gitをインストールします。

.. code-block:: bash

  $ sudo apt-get update
  $ sudo apt-get install git

githubから以下のリポジトリをクローンします。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

スレーブサーバーの追加
======================

スレーブサーバーを追加します。

マスターサーバーへスレーブサーバーを登録します。

.. code-block:: bash

  $ ./scripts/createnode.sh <nodename> <workspace> <url>

ブラウザでスレーブサーバーが登録されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

スレーブサーバーを接続します。

.. code-block:: bash

  $ ./setup/slave.sh <nodename> <url>

ブラウザでスレーブサーバーが接続されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

スレーブサーバーの削除
======================

スレーブサーバーを削除します。

マスターサーバーからスレーブサーバーを削除します。

.. code-block:: bash

  $ ./scripts/deletenode.sh <nodename> <url>

ブラウザでスレーブサーバーが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

仮想マシン
======================

virtualbox、vagrantをインストールします。

マスターサーバーを起動します。

.. code-block:: bash

  $ vagrant up

ブラウザで以下のURLが正しく表示されることを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

スレーブサーバーを起動します。

.. code-block:: bash

  $ vagrant up slave
  $ vagrant up debian-wheezy-i386
  $ vagrant up ubuntu-trusty-amd64

認証情報の設定
==============

テストサーバーでは対話形式のコマンドは実行できないため、テストジョブで認証情報が必要な外部サーバーへアクセスを行う場合は事前に以下の設定が必要となります。

マスターサーバー、スレーブサーバー全てに対してそれぞれ設定が必要となります。

セキュリティー面を考慮して認証情報を設定ファイルやスクリプトに保存しないで下さい。

gitの設定
=========

http経由でアクセスする場合は.netrcをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp $HOME/.netrc /var/lib/jenkins
  $ sudo chown jenkins:jenkins /var/lib/jenkins/.netrc

ssh経由でアクセスする場合は.sshをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp -r $HOME/.ssh /var/lib/jenkins
  $ sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh

subversionの設定
================

subversionの場合は.subversionをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp -r $HOME/.subversion /var/lib/jenkins
  $ sudo chown -R jenkins:jenkins /var/lib/jenkins/.subversion

リバースプロキシの設定
======================

.. note::

  インターネット接続が可能なマシンを用意して下さい。

.. warning::

  他のアプリケーションがポート番号80を使用していないか確認して下さい。

インストール
============

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

ブラウザで以下のURLが正しく表示されることを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

