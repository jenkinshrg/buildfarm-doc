==================
テストジョブの管理
==================

テストジョブをテストサーバーで実行させる手順について説明します。

予め実行したいスクリプトを含むリポジトリをマスターサーバー、スレーブサーバーからアクセス可能な場所へ配置して下さい。

テスト対象となるソースコードや実行ファイルをスクリプト内で取得する場合はリポジトリに含まれている必要はありません。

テストを実行するために必要な要件を満たすスレーブサーバーを指定して下さい。複数の環境で実行したい場合は複数のジョブを追加して下さい。

ジョブ一覧
==========

.. csv-table::
  :header: ジョブ名, 説明
  :widths: 5, 5

  drcutil, リポジトリ変更監視
  drcutil-build-32, ビルド（32ビット環境）
  drcutil-build-64, ビルド（64ビット環境）、単体テスト、静的解析
  drcutil-task-balancebeam, タスクシーケンス（平均台歩行）
  drcutil-task-terrain, タスクシーケンス（不整地歩行）
  drcutil-task-valve, タスクシーケンス（バルブ回し）
  drcutil-task-wall, タスクシーケンス（壁開け）
  report, レポートアップロード

ジョブの追加
============

.. warning::

  マスターサーバーが起動していることを確認して下さい。

マスターサーバーへジョブを登録します。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm
  $ ./scripts/createjob.sh <jobname> <repository> <directory> <branch> <node> <os> <distro> <arch> <triiger> <func> <test> <url>

.. csv-table::
  :header: パラメータ名, 説明, 例
  :widths: 5, 5, 5

  jobname, ジョブ名, drcutil-task-valve
  repository, リポジトリ, https://github.com/jenkinshrg/drcutil.git
  directory, ディレクトリ, drcutil
  branch, ブランチ, jenkins
  node, 実行ノード, slave
  os, OS種別, ubuntu
  distro, ディストリビューション, trusty
  arch, アーキテクチャ, amd64
  triiger, 実行トリガ, periodic
  func, テスト種別, task
  test, 対象テスト, valve
  url, マスターサーバーURL, http://jenkinshrg.a01.aist.go.jp

ブラウザでジョブが登録されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

ジョブの削除
============

.. warning::

  マスターサーバーが起動していることを確認して下さい。

マスターサーバーからジョブを削除します。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm
  $ ./scripts/deletejob.sh <jobname> <url>

ブラウザでジョブが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp
