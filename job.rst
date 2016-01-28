=====================================
ジョブの追加・削除
=====================================

.. warning::

  マスターサーバーが起動していることを確認して下さい。

githubから以下のリポジトリをクローンします。

.. code-block:: bash

  $ git clone https://github.com/jenkinshrg/buildfarm.git
  $ cd buildfarm

ジョブの追加
============

ジョブを追加します。

.. note::

  予め実行させたいスクリプトを含むリポジトリを用意して下さい。

マスターサーバーへジョブを登録します。

.. code-block:: bash

  $ ./scripts/createnode.sh slave

ブラウザでジョブが登録されたことを確認して下さい。

http://localhost:8080

ジョブを実行します。

.. code-block:: bash

  $ ./scripts/buildjob.sh test

ブラウザでジョブが実行されたことを確認して下さい。

http://localhost:8080

ジョブの削除
============

ジョブを削除します。

マスターサーバーからジョブを削除します。

.. code-block:: bash

  $ ./scripts/deletejob.sh test

ブラウザでジョブが削除されたことを確認して下さい。

http://localhost:8080

