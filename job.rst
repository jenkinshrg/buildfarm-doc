==================
テストジョブの管理
==================

テストジョブをテストサーバーで実行させる手順について説明します。

予め実行したいスクリプトを含むリポジトリをマスターサーバー、スレーブサーバーからアクセス可能な場所へ配置して下さい。

テスト対象となるソースコードや実行ファイルをスクリプト内で取得する場合はリポジトリに含まれている必要はありません。

テストを実行するために必要な要件を満たすスレーブサーバーを指定して下さい。複数の環境で実行したい場合は複数のジョブを追加して下さい。

ジョブ一覧
==========

現在のジョブ構成は以下の通りです。

.. csv-table::
  :header: ジョブ名, 説明, 備考
  :widths: 5, 5, 5

  drcutil, リポジトリ変更監視,
  drcutil-build-32, ビルド（32ビット環境）, dockerコンテナ上で実行
  drcutil-build-64, ビルド（64ビット環境）、単体テスト、静的解析, dockerコンテナ上で実行
  drcutil-task-balancebeam, タスクシーケンス（平均台歩行）, デスクトップ環境で実行
  drcutil-task-terrain, タスクシーケンス（不整地歩行）, デスクトップ環境で実行
  drcutil-task-valve, タスクシーケンス（バルブ回し）, デスクトップ環境で実行
  drcutil-task-wall, タスクシーケンス（壁開け）, デスクトップ環境で実行
  report, レポートアップロード,

ジョブの追加
============

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーへジョブを登録します。

.. code-block:: bash

  $ ./scripts/createjob.sh <jobname> <repository> <directory> <branch> <node> <os> <distro> <arch> <triiger> <func> <test> <url>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 例（デフォルト値）, 備考

  jobname, ジョブ名, debug,
  repository, リポジトリ, https://github.com/jenkinshrg/drcutil.git,
  directory, ディレクトリ, drcutil,
  branch, ブランチ, jenkins,
  node, 実行ノード, slave,
  os, OS種別(none/ubuntu/debian), none, noneの場合はスレーブサーバーの実環境で実行
  distro, ディストリビューション(trusty/wheezy), trusty, osがnone以外の場合に指定、debootstrapで指定可能なもの
  arch, アーキテクチャ(amd64/i386), amd64, osがnone以外の場合に指定、debootstrapで指定可能なもの
  triiger, 実行トリガ(none/scm/upstream/periodic), none,
  func, テスト種別(all/build/task), all,
  test, 対象テスト(all/balancebeam/terrain/valve/wall), all,
  url, マスターサーバーURL, http://jenkinshrg.a01.aist.go.jp,

ブラウザでジョブが登録されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

タスクシーケンス追加時
----------------------

実行するタスクシーケンスを追加したい場合はtestに任意のタスクを指定してジョブを追加して下さい。

.. code-block:: bash

  $ ./scripts/createjob.sh <jobname> <repository> <directory> <branch> <node> <os> <distro> <arch> <triiger> <func> <test> <url>

OSバージョン追加時
------------------

実行するOSバージョンを追加したい場合はos、distro、archに任意のバージョンを指定してジョブを追加して下さい。

.. code-block:: bash

  $ ./scripts/createjob.sh <jobname> <repository> <directory> <branch> <node> <os> <distro> <arch> <triiger> <func> <test> <url>

スレーブ追加時
------------------

実行するスレーブサーバーを追加したい場合はノード名を指定してジョブを追加して下さい。

.. code-block:: bash

  $ ./scripts/createjob.sh <jobname> <repository> <directory> <branch> <node> <os> <distro> <arch> <triiger> <func> <test> <url>

ジョブの削除
============

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーからジョブを削除します。

.. code-block:: bash

  $ ./scripts/deletejob.sh <jobname> <url>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 例（デフォルト値）, 備考

  jobname, ジョブ名, debug,
  url, マスターサーバーURL, http://jenkinshrg.a01.aist.go.jp,

ブラウザでジョブが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

.. warning::

  スクリプト実行時はマスターサーバーが起動していることを予め確認して下さい。
