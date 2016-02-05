==============
認証情報の設定
==============

テストサーバーでは対話形式のコマンドは実行できないため、テストジョブで認証情報が必要な外部サーバーへアクセスを行う場合は事前に以下の設定が必要となります。

マスターサーバー、スレーブサーバー全てに対してそれぞれ設定が必要となります。

セキュリティー面を考慮して認証情報を設定ファイルやスクリプトに保存しないで下さい。

gitの設定
=========

http経由でアクセスする場合は.netrcをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp $HOME/.netrc /var/lib/jenkins
  $ sudo chown jenkins:jenkins /var/lib/jenkins/.netrc

ssh経由でアクセスする場合は.sshをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp -r $HOME/.ssh /var/lib/jenkins
  $ sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh

subversionの設定
================

subversionの場合は.subversionをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp -r $HOME/.subversion /var/lib/jenkins
  $ sudo chown -R jenkins:jenkins /var/lib/jenkins/.subversion

