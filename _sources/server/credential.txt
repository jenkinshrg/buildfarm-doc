==============
認証情報の設定
==============

セキュリティー上の問題で認証情報が必要な場合は個別に設定して下さい。

.netrcの設定
============

http経由でアクセスする場合は.netrcをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp $HOME/.netrc /var/lib/jenkins
  $ sudo chown jenkins:jenkins /var/lib/jenkins/.netrc

.sshの設定
==========

ssh経由でアクセスする場合は.sshをマスターサーバーの$JENKINS_HOMEとスレーブサーバーの$HOMEへ格納しておきます。

.. code-block:: bash

  $ sudo cp -r $HOME/.ssh /var/lib/jenkins
  $ sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh

