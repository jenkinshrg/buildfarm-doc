=====================================
マスタサーバーの構築
=====================================

インストール
============

githubから以下のリポジトリをクローンします。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git

マスターサーバーをインストールします。

.. warning::

他のアプリケーションがポート番号8080を使用していないか確認して下さい。

.. code-block:: bash

  $ cd buildfarm
  $ ./setup/master.sh
