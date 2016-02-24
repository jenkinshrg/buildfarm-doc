==================
テストジョブの管理
==================

テストジョブをテストサーバーで実行させる手順について説明します。

現在運用中のジョブ構成は以下の通りです。

.. csv-table::
  :header: ジョブ名, 説明, 備考
  :widths: 5, 5, 5

  drcutil, リポジトリ変更監視, 毎時レポジトリ変更時に実行
  drcutil-build-32, ビルド（32ビット環境）, drcutilが終了時に実行、dockerコンテナ環境で実行
  drcutil-build-64, ビルド（64ビット環境）、単体テスト、静的解析, drcutilが終了時に実行、dockerコンテナ環境で実行
  drcutil-task-balancebeam, タスクシーケンス（平均台歩行）, 毎時実行、実環境で実行
  drcutil-task-terrain, タスクシーケンス（不整地歩行）, 毎時実行、実環境で実行
  drcutil-task-valve, タスクシーケンス（バルブ回し）, 毎時実行、実環境で実行
  drcutil-task-wall, タスクシーケンス（壁開け）, 毎時実行、実環境で実行
  drcutil-upload, レポートアップロード, drcutil以外が終了時に実行

.. note::

  自動アップデート、リブートを実施するため6:00-8:00の時間帯はテストを停止します。

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
  template, ジョブ設定テンプレート(none/scm/upstream/periodic), none:レポートアップロード用（drcutil-uploadジョブ専用）、scm:リポジトリ監視用（drcutilジョブ専用）、upstream:リポジトリ変更時ビルド確認用（dockerコンテナ環境で実行）、periodic:タスクシーケンス定期確認用（実環境で実行）
  node, 実行ノード名, 稼働中のスレーブを指定
  os, 実行OS(none/ubuntu/debian), noneの場合はスレーブサーバーの実OSで実行、none以外の場合はdockerコンテナ上のOSで実行
  distro, ディストリビューション, osがnone以外の場合に有効、debootstrapで指定可能なものから選択
  arch, アーキテクチャ, osがnone以外の場合に有効、debootstrapで指定可能なものから選択
  script, 実行スクリプト,  任意（現状は.jenkins.sh:ビルド／タスクシーケンステスト用、.report.sh:レポートアップロード用を格納）
  script_args, スクリプト引数,  任意（.jenkins.shスクリプトを実行する場合は下記を参照）

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
  node, 実行ノード名, 稼働中のスレーブを指定
  os, 実行OS(none/ubuntu/debian), debianもしくはubuntuを指定
  distro, ディストリビューション, debootstrapで指定可能なものから選択
  arch, アーキテクチャ, debootstrapで指定可能なものから選択
  script, 実行スクリプト, .jenkins.shを指定
  testname, テスト内容(build/task), buildを指定

タスクシーケンス追加時
----------------------

.. warning::

  現状はタスク成功判定にdrcutil/.jenkins/getRobotPos.py（ロボット状態取得）、drcutil/.jenkins/getRobotPos.py（ターゲット状態取得）を行ったあと、drcutil/.jenkins/<taskname>-getRobotPos.py（ロボット状態判定）、drcutil/.jenkins/<taskname>-getRobotPos.py（ターゲット状態判定）を実行しているため事前にスクリプトの登録が必要です。

実行するタスクシーケンスを追加したい場合は以下のように指定してジョブを追加して下さい。

.. code-block:: bash

  $ ./scripts/createjob.sh <jobname> periodic <nodename> none none none .jenkins.sh task <robotname> <taskname> <autox> <autoy> <okx> <oky> <wait> [<targetname>] [<targetport>]

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  jobname, ジョブ名, 任意
  template, ジョブ設定テンプレート(none/scm/upstream/periodic), periodicを指定
  node, 実行ノード名, 稼働中のスレーブを指定
  os, 実行OS(none/ubuntu/debian), noneを指定
  distro, ディストリビューション, noneを指定
  arch, アーキテクチャ, noneを指定
  script, 実行スクリプト, .jenkins.shを指定
  testname, テスト内容(build/task), taskを指定
  robotname, ロボット名, share/hrpsys/samples配下のディレクトリ名を指定
  taskname, タスク名, share/hrpsys/samples/<robotname>配下のcnoidファイルを拡張子なしで指定
  autox, 「自動」ボタンX座標, タスクパネルの「自動」ボタンの画面上のX座標を指定 
  autoy, 「自動」ボタンY座標, タスクパネルの「自動」ボタンの画面上のY座標を指定
  okx, 「OK」ボタンX座標, タスクパネルの「OK」ボタンの画面上のX座標を指定
  oky, 「OK」ボタンY座標, タスクパネルの「OK」ボタンの画面上のY座標を指定
  wait, 終了待ち時間（秒）, タスクシーケンスが終了する予測時間を指定
  targetname, 成功確認用ターゲット名, 省略可、現状はvalveタスクのバルブ回転確認で使用(valve_leftを指定)
  targetport, 成功確認用ターゲットポート名, 省略可、現状はvalveタスクのバルブ回転確認で使用(qを指定)

以下のURLへブラウザで接続してジョブが登録されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

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
