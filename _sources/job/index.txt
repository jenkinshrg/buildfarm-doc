==================
ジョブの追加・削除
==================

.. note::

  予めテスト対象となるソースコードのリポジトリを用意して下さい。

.. warning::

  マスターサーバーが起動していることを確認して下さい。

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

ジョブの作成
============

以下のような手順のテストスクリプトを作成してリポジトリへ登録して下さい。

* ソースコードの取得
* 依存パッケージのインストール
* ビルドの実行
* 各種テストの実行

ジョブの追加
============

ジョブを追加します。

マスターサーバーへジョブを登録します。

.. code-block:: bash

  $ ./scripts/createjob.sh drcutil-task-walk https://github.com/jenkinshrg/drcutil.git drcutil jenkins ubuntu-trusty-amd64-desktop periodic http://jenkinshrg.a01.aist.go.jp

ブラウザでジョブが登録されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

ジョブを実行します。

.. code-block:: bash

  $ ./scripts/buildjob.sh drcutil-task-walk http://jenkinshrg.a01.aist.go.jp

ブラウザでジョブが実行されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

ジョブの削除
============

ジョブを削除します。

マスターサーバーからジョブを削除します。

.. code-block:: bash

  $ ./scripts/deletejob.sh drcutil-task-walk http://jenkinshrg.a01.aist.go.jp

ブラウザでジョブが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

