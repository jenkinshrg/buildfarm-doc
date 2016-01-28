======================
スレーブサーバーの構築
======================

.. warning::

  マスターサーバーが起動していることを確認して下さい。

githubから以下のリポジトリをクローンします。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

スレーブサーバーの追加
======================

スレーブサーバーを追加します。

.. note::

  インターネット接続が可能なマシンを用意して下さい。マシンスペックによっては、マスターサーバーと同じマシンにスレーブサーバーを同居させることも可能です。

ユーザーがパスワード無しでsudoできるように設定しておきます。

.. code-block:: bash

  $ sudo sh -c 'echo "tokunaga ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

choreonoidを実行する場合はプロプライエタリなドライバをインストールして変更しておきます。
また自動ログイン、スクリーンセーバー、画面ロックを解除しておきます。

.. code-block:: bash

  $ sudo add-apt-repository -y ppa:xorg-edgers/ppa
  $ sudo apt-get update
  $ sudo apt-get -y install nvidia-current nvidia-settings

マスターサーバーへスレーブサーバーを登録します。

.. code-block:: bash

  $ ./scripts/createnode.sh slave

ブラウザでスレーブサーバーが登録されたことを確認して下さい。

http://localhost:8080

スレーブサーバーを接続します。

.. code-block:: bash

  $ ./setup/slave.sh

ブラウザでスレーブサーバーが接続されたことを確認して下さい。

http://localhost:8080

スレーブサーバーの削除
======================

スレーブサーバーを削除します。

マスターサーバーからスレーブサーバーを削除します。

.. code-block:: bash

  $ ./scripts/deletenode.sh slave

ブラウザでスレーブサーバーが削除されたことを確認して下さい。

http://localhost:8080

