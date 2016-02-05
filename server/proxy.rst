======================
リバースプロキシの設定
======================

.. note::

  インターネット接続が可能なマシンを用意して下さい。

.. warning::

  他のアプリケーションがポート番号80を使用していないか確認して下さい。

インストール
============

githubから以下のリポジトリをクローンします。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

webサーバーをインストールしてリバースプロキシ設定を行います。

.. code-block:: bash

  $ ./setup/nginx.sh

ブラウザで以下のURLが正しく表示されることを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

