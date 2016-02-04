======================
スレーブサーバーの構築
======================

.. note::

  インターネット接続が可能なマシンを用意して下さい。マシンスペックによっては、マスターサーバーと同じマシンにスレーブサーバーを同居させることも可能です。

ユーザーがパスワード無しでsudoできるように設定しておきます。

.. code-block:: bash

  $ sudo sh -c 'echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

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

依存パッケージをインストールします。

.. code-block:: bash

  $ ./setup/common.sh

スレーブサーバーの追加
======================

スレーブサーバーを追加します。

マスターサーバーへスレーブサーバーを登録します。

.. code-block:: bash

  $ ./scripts/createnode.sh ubuntu-trusty-amd64-desktop /home/jenkins http://jenkinshrg.a01.aist.go.jp

ブラウザでスレーブサーバーが登録されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

スレーブサーバーを接続します。

.. code-block:: bash

  $ ./setup/slave.sh ubuntu-trusty-amd64-desktop http://jenkinshrg.a01.aist.go.jp

ブラウザでスレーブサーバーが接続されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

スレーブサーバーの削除
======================

スレーブサーバーを削除します。

マスターサーバーからスレーブサーバーを削除します。

.. code-block:: bash

  $ ./scripts/deletenode.sh ubuntu-trusty-amd64-desktop http://jenkinshrg.a01.aist.go.jp

ブラウザでスレーブサーバーが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

