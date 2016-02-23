==================
テストジョブの管理
==================

テストジョブをテストサーバーで実行させる手順について説明します。

現在運用中のジョブ構成は以下の通りです。

.. csv-table::
  :header: ジョブ名, 説明, 備考
  :widths: 5, 5, 5

  drcutil, リポジトリ変更監視,
  drcutil-build-32, ビルド（32ビット環境）, dockerコンテナ上のOSで実行
  drcutil-build-64, ビルド（64ビット環境）、単体テスト、静的解析, dockerコンテナ上のOSで実行
  drcutil-task-balancebeam, タスクシーケンス（平均台歩行）, デスクトップ環境で実行
  drcutil-task-terrain, タスクシーケンス（不整地歩行）, デスクトップ環境で実行
  drcutil-task-valve, タスクシーケンス（バルブ回し）, デスクトップ環境で実行
  drcutil-task-wall, タスクシーケンス（壁開け）, デスクトップ環境で実行
  drcutil-upload, レポートアップロード,

事前準備
========

テストサーバーの確認
--------------------

以下のURLへブラウザで接続してテストを実行させるスレーブサーバーのノード名を確認して下さい。

http://jenkinshrg.a01.aist.go.jp

テストスクリプトの作成
----------------------

以下のURLへ実行したいスクリプトを作成して配置して下さい。

https://github.com/jenkinshrg/drcutil/tree/jenkins

ジョブの追加
============

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーへジョブを登録します。

.. code-block:: bash

  $ ./scripts/createjob.sh <jobname> <template> <nodename> <os> <distro> <arch> <script> [<script_args>]

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  jobname, ジョブ名, 任意
  template, ジョブ設定テンプレート(none/scm/upstream/periodic), none:レポートアップロード用（drcutil-upload専用）、scm:リポジトリ監視用（drcutil専用）、upstream:リポジトリ変更時起動用（dockerコンテナ環境専用）、periodic:定期起動用（実環境専用）
  node, 実行ノード名, 任意
  os, 実行OS(none/ubuntu/debian), noneの場合はスレーブサーバーの実OSで実行、none以外の場合はdockerコンテナ上のOSで実行
  distro, ディストリビューション(trusty/wheezy), osがnone以外の場合に有効、debootstrapで指定可能なもの
  arch, アーキテクチャ(amd64/i386), osがnone以外の場合に有効、debootstrapで指定可能なもの
  script, 実行スクリプト,  任意（.jenkins.sh:ビルド／タスクシーケンステスト用、.report.sh:レポートアップロード用）
  script_args, スクリプト引数,  任意（下記を参照）

以下のURLへブラウザで接続してジョブが登録されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

ビルドOSバージョン追加時
------------------------

ビルドを実行するOSバージョンを追加したい場合は以下のように指定してジョブを追加して下さい。

.. code-block:: bash

  $ ./scripts/createjob.sh <jobname> upstream <nodename> ubuntu xenial amd64 .jenkins.sh build

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  jobname, ジョブ名, 任意
  template, ジョブ設定テンプレート(none/scm/upstream/periodic), upstreamを指定
  node, 実行ノード名, 任意
  os, 実行OS(none/ubuntu/debian), 実行
  distro, ディストリビューション(trusty/wheezy), 
  arch, アーキテクチャ(amd64/i386), 
  script, 実行スクリプト, .jenkins.shを指定
  testname, テスト内容(build/task), buildを指定

タスクシーケンス追加時
----------------------

実行するタスクシーケンスを追加したい場合は以下のように指定してジョブを追加して下さい。

.. code-block:: bash

  $ ./scripts/createjob.sh <jobname> periodic <nodename> none none none .jenkins.sh task <robotname> <taskname> <autox> <autoy> <okx> <oky> <wait> <targetname> <targetport>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  jobname, ジョブ名, 任意
  template, ジョブ設定テンプレート(none/scm/upstream/periodic), periodicを指定
  node, 実行ノード名, 任意
  os, 実行OS(none/ubuntu/debian), noneを指定
  distro, ディストリビューション(trusty/wheezy), noneを指定
  arch, アーキテクチャ(amd64/i386), noneを指定
  script, 実行スクリプト, .jenkins.shを指定
  testname, テスト内容(build/task), taskを指定
  robotname, ロボット名, 任意
  taskname, ロボット名, 任意
  autox, ロボット名, 任意
  autoy, ロボット名, 任意
  okx, ロボット名, 任意
  oky, ロボット名, 任意
  wait, ロボット名, 任意
  targetname, ロボット名, 任意
  targetport, ロボット名, 任意

ジョブの削除
============

スクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

マスターサーバーからジョブを削除します。

.. code-block:: bash

  $ ./scripts/deletejob.sh <jobname>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  jobname, ジョブ名,

以下のURLへブラウザで接続してジョブが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp
