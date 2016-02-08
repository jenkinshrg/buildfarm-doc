==================
テストジョブの管理
==================

テストジョブをテストサーバーで実行させる手順について説明します。

ジョブの追加
============

予め実行したいスクリプトを含むリポジトリをスレーブサーバーからアクセス可能な場所へ配置して下さい。テスト対象となるソースコードや実行ファイルをスクリプト内で取得する場合はリポジトリに含まれている必要はありません。

テストを実行するために必要な要件を満たすスレーブサーバーを指定して下さい。複数の環境で実行したい場合は複数のジョブを追加して下さい。

.. warning::

  chroot、docker等でスレーブの環境を意識せずに任意の環境でクリーンビルドを可能とする方法を現在検討中です。

.. warning::

  マスターサーバーが起動していることを確認して下さい。

ジョブを追加します。

マスターサーバーへジョブを登録します。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm
  $ ./scripts/createjob.sh <jobname> <repository> <directory> <branch> <node> <triiger> <func> <test> <url>

ブラウザでジョブが登録されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

ジョブの削除
============

.. warning::

  マスターサーバーが起動していることを確認して下さい。

ジョブを削除します。

マスターサーバーからジョブを削除します。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm
  $ ./scripts/deletejob.sh <jobname> <url>

ブラウザでジョブが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

