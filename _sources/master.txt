=====================================
マスタサーバーの構築
=====================================

.. note::

  インターネット接続が可能なマシンを用意して下さい。ハイスペックなマシンは必要ありませんが、サイズの大きなログを長期間保存する場合は大きめのハードディスクを用意して下さい。

.. warning::

  他のアプリケーションがポート番号8080を使用していないか確認して下さい。

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

マスターサーバーをインストールします。

.. code-block:: bash

  $ ./setup/master.sh

ブラウザで以下のURLが正しく表示されることを確認して下さい。

http://localhost:8080

