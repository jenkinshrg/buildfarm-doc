==================
テストジョブの管理
==================

テストジョブをテストサーバーで実行させる手順について説明します。

現在運用中のジョブ構成は以下の通りです。

.. csv-table::
  :header: ジョブ名, 内容, 実行トリガ, 実行ノード, 備考

  drcutil, リポジトリ変更監視, 毎時レポジトリ変更時, slave1, 
  build-debian7-32, ビルド（32ビット環境）, drcutilが終了時に実行, slave1, dockerコンテナ環境でクリーンビルドを実行
  build-ubuntu1404-64, ビルド（64ビット環境）、単体テスト、静的解析, drcutilが終了時に実行, slave1, dockerコンテナ環境でクリーンビルドを実行
  build-ubuntu1604-64, ビルド（64ビット環境）、単体テスト、静的解析, drcutilが終了時に実行, slave1, dockerコンテナ環境でクリーンビルドを実行
  task-hrp2kai-balancebeam, タスクシーケンス（平均台歩行）, 毎時実行, masterとslave1以外, 実環境でGUIテストを実行
  task-hrp2kai-button, タスクシーケンス（ボタン押し）, 毎時実行, masterとslave1以外, 実環境でGUIテストを実行
  task-hrp2kai-terrain, タスクシーケンス（不整地歩行）, 毎時実行, masterとslave1以外, 実環境でGUIテストを実行
  task-hrp2kai-valve, タスクシーケンス（バルブ回し）, 毎時実行, masterとslave1以外, 実環境でGUIテストを実行
  task-hrp2kai-wall, タスクシーケンス（壁開け）, 毎時実行, masterとslave1以外, 実環境でGUIテストを実行
  task-hrp5p-balancebeam, タスクシーケンス（平均台歩行）, 毎時実行, masterとslave1以外, 実環境でGUIテストを実行
  task-hrp5p-terrain, タスクシーケンス（不整地歩行）, 毎時実行, masterとslave1以外, 実環境でGUIテストを実行
  task-hrp5p-valve, タスクシーケンス（バルブ回し）, 毎時実行, masterとslave1以外, 実環境でGUIテストを実行
  task-hrp5p-wall, タスクシーケンス（壁開け）, 毎時実行, masterとslave1以外, 実環境でGUIテストを実行
  drcutil-upload, レポートアップロード, drcutil以外が終了時に実行, slave1, 

.. note::

  パッケージのアップデート、リブートを自動で実施するため、5:00-8:00の時間帯はジョブを実行しない設定としています。

.. note::

  各種ログはジョブ毎に最大100回分の履歴を保持する設定としています。

.. note::

  各種ログはGoogle Driveにもアップロードします。（容量の問題で2日分のみ保存）

.. note::

  簡易レポートを作成してGithub Pagesへアップロードします。

事前準備
========

テストジョブを追加、削除する場合は以下の準備を行って下さい。

テストスクリプトの作成
----------------------

以下のURLへ実行したいスクリプトを作成して配置して下さい。

https://github.com/jenkinshrg/drcutil/tree/jenkins

テストサーバーの確認
--------------------

以下のURLへブラウザで接続してマスターサーバーが稼働していること、またテストを実行させるスレーブサーバーのノード名を確認して下さい。

http://jenkinshrg.a01.aist.go.jp

ツールスクリプトの用意
----------------------

ジョブの追加、削除を行うツールスクリプトをcloneしておきます。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

ジョブの追加
============

マスターサーバーへジョブを登録する場合は以下のスクリプトを実行して下さい。

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
  script, 実行スクリプト,  任意（現状は.jenkins.sh:ビルド／タスクシーケンステスト用、.report.sh:レポートアップロード用を用意）
  script_args, スクリプト引数,  任意（.jenkins.shスクリプトを実行する場合は下記を参照）

ビルドOSバージョン追加時
------------------------

ビルドを実行するOSバージョンを追加したい場合は以下のように指定してスクリプトを実行して下さい。

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

.. note::

  ビルドはdockerコンテナ上で隔離して実行しますので任意のスレーブサーバーを選択可能です。

.. warning::

  ビルドするOSバージョンを追加する場合はジョブの追加のみで対応可能ですが、依存パッケージが変わってしまう場合はスクリプトの修正が必要になる場合があります。

タスクシーケンス追加時
----------------------

実行するタスクシーケンスを追加したい場合は以下のように指定してスクリプトを実行して下さい。

.. code-block:: bash

  $ ./scripts/createtask.sh <jobname> <nodename> <robotname> <taskname> <autox> <autoy> <okx> <oky> <wait> [<targetname>] [<targetport>]

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  jobname, ジョブ名, 任意
  node, 実行ノード名, 稼働中のスレーブを指定
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

.. note::

  タスクシーケンスの実行は仮想マシンやdockerコンテナでは実行できず、並列実行もできませんので要件にあったスレーブサーバー（slave2)を選択して下さい。

.. warning::

  現状はchoreonoid起動後に自動ボタン、OKボタンを押下するため、xautomationパッケージのxteコマンドで画面上の座標をクリックしていますので、該当ボタンの座標をxteコマンドで事前に確認して設定する必要があります。

.. warning::

  現状はwaitで指定した時間待ち合わせした後にdrcutil/.jenkins/getRobotPos.py（ロボット状態取得）、drcutil/.jenkins/getRobotPos.py（ターゲット状態取得）を実行して状態を取得し、drcutil/.jenkins/<taskname>-getRobotPos.py（ロボット状態判定）、drcutil/.jenkins/<taskname>-getRobotPos.py（ターゲット状態判定）を実行して成功判定を行っているため、テストするタスクシーケンスを追加する場合はスクリプトを追加してからジョブを追加する必要があります。

ジョブの削除
============

不要になったジョブの情報をマスターサーバーから削除する場合は以下のスクリプトを実行して下さい。

.. code-block:: bash

  $ ./scripts/deletejob.sh <jobname>

* パラメータの説明

.. csv-table::
  :header: パラメータ名, 説明, 備考

  jobname, ジョブ名,

以下のURLへブラウザで接続してジョブが削除されたことを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

メンテナンス
============

ワークスペースのクリア
----------------------

ジョブを途中停止するなどした場合にワークスペースのデータが中途半端な状態になりエラーが解消されない場合があります。

その場合はJENKINSの画面で該当ジョブを選択して「ワークスペース」→「ワークスペースのクリア」を行って下さい。
