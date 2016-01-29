================================
仮想マシン上でのテスト環境の構築
================================

.. note::

  インターネット接続が可能なマシンを用意して下さい。

.. warning::

  他のアプリケーションがポート番号8080を使用していないか確認して下さい。

インストール
============

githubから以下のリポジトリをクローンします。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

virtualboxをインストールします。

.. code-block:: bash

  $ ./setup/virtualbox.sh

vagrantをインストールします。

.. code-block:: bash

  $ ./setup/vagrant.sh

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

ブラウザでスレーブサーバーが接続されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

