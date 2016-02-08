==================
テストジョブの管理
==================

テストジョブをテストサーバーで実行させる手順について説明します。

.. note::

  予め実行したいスクリプトを含むリポジトリをスレーブサーバーからアクセス可能な場所へ配置して下さい。テスト対象となるソースコードや実行ファイルをスクリプト内で取得する場合はリポジトリに含まれている必要はありません。

.. warning::

  マスターサーバーが起動していることを確認して下さい。

githubから以下のリポジトリをクローンします。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

ジョブの追加
============

ジョブを追加します。

マスターサーバーへジョブを登録します。

.. code-block:: bash

  $ ./scripts/createjob.sh <jobname> <repository> <directory> <branch> <node> <triiger> <function> <test> <url>

ブラウザでジョブが登録されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

ジョブの削除
============

ジョブを削除します。

マスターサーバーからジョブを削除します。

.. code-block:: bash

  $ ./scripts/deletejob.sh <jobname> <url>

ブラウザでジョブが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

