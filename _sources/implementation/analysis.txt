=====================================
動的解析
=====================================

目的
====

プログラム動的解析を行います。

手法
====

各種の解析ツールを利用してプログラムを動作させます。

フレームワーク
==============

OSコマンド、mtrace、valgrind等を利用します。

テストプログラムの例
====================

テスト対象プログラムをvalgrind経由で実行して出力されたレポートを確認します。

.. code-block:: bash

  valgrind --verbose --tool=memcheck --leak-check=full --show-reachable=no --undef-value-errors=no --track-origins=no --child-silent-after-fork=no --trace-children=no --gen-suppressions=no --xml=yes --xml-file=valgrind.xml testEigen3d

