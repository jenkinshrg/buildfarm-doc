====
概要
====

はじめに
========

buildfarmはhrpsys-base, choreonoid, OpenHRPなどのロボット関連ソフトウェアの各種テストの実行を自動化するための継続的インテグレーション（CI）環境です。

JENKINSサーバーをオンプレミスに構築するためプライベートなリポジトリやオンプレミスに存在するリポジトリを含むテストや特定のハードウェア（GPUなど）やソフトウェア（OSなど）に依存するテストの実行が可能です。

.. graphviz::

   digraph {
      source1 [label="public repository"];
      source2 [label="private repository"];
      build [label="buildfarm"];
      report1 [label="mail server"];
      report2 [label="cloud storage"];
      report3 [label="web page"];
      source1 -> build [label="checkout source"];
      source2 -> build [label="checkout source"];
      build -> report1 [label="send messages"];
      build -> report2 [label="upload logs"];
      build -> report3 [label="upload reports"];
   }
   
テストの種類と実装方法
======================

テストの種類と実装方法について説明します。

ビルド
------

ソースコードの変更に対して正常にビルド、インストールできる状態にあるかを確認します。

必要であれば事前にソースコードの取得、依存パッケージのインストールなどを行い、cmakeなどのビルド手順(コンパイル、インストール)を実行します。

* テストプログラムの例

.. code-block:: bash

  $ cmake .
  $ make install

単体テスト
----------

共通で利用されるライブラリ(クラスや関数)レベルでの機能の正常性を確認します。

Google Test(C++)等のユニットテストフレームワークを利用し、対象となるライブラリをリンクしたテストプログラムを作成してクラス／関数の入出力や分岐などを確認します。

* テストプログラムの例

gtestをインストールしておきます。

.. code-block:: bash

  $ sudo apt-get install libgtest-dev

テストプログラムを作成します。

.. code-block:: c++

  #include <gtest/gtest.h>
  #include "Eigen3d.h"
  
  using namespace hrp;
  
  TEST(Eigen3d, omegaFromRot)
  {
      Matrix33 m;
      Vector3 v;
  
      m << 1.0,   0,   0,
             0, 1.0,   0,
             0,   0, 1.0;
      v = omegaFromRot(m);

      EXPECT_EQ(v[0], 0);
      EXPECT_EQ(v[1], 0);
      EXPECT_EQ(v[2], 0);
  }

CMakeLists.txtに以下の記述を追加します。

.. code-block:: cmake

  enable_testing()
  add_subdirectory(/usr/src/gtest ${CMAKE_CURRENT_BINARY_DIR}/gtest)

  add_executable(testEigen3d testEigen3d.cpp Eigen3d.cpp)
  target_link_libraries(testEigen3d gtest gtest_main pthread)
  set_target_properties(testEigen3d PROPERTIES COMPILE_FLAGS "-g -O0 -coverage" LINK_FLAGS "-g -O0 -coverage")
  add_test(testEigen3d ${EXECUTABLE_OUTPUT_PATH}/testEigen3d)

cmakeでビルドした後にctestでテストプログラムを実行します。

.. code-block:: bash

  $ ctest --verbose --test-action Test

出力されるレポートを確認します。

コンパイルオプションを指定しておけば、lcov等を利用してカバレッジを分析することも可能です。

コンポーネントテスト
--------------------

共通的に利用されるモジュール化されたコンポーネントの単体／結合テストを行います。

rtshellなどのツールを利用、もしくはpython等でテストプログラムを作成し、RTCプロファイルで規定されているインターフェース仕様に従い、インスタンスのアクティビティ／コンテキストの遷移、データポート／サービスポートの入出力、コンフィグレーションの設定などを確認します。

総合テスト
----------

個別のロボットに特化したロボットソフトウェアの総合テストを行います。

ターゲットとするロボットが持つ目的（災害対応など）や機能（歩行やリーチングなど）をタスクとして定義し、Choreonoid等によりロボット／環境モデルとタスクシーケンスを作成してシミュレーションを行います。

* テストプログラムの例

.. code-block:: bash

  $ choreonoid testbed-terrain.cnoid --start-simulation

GUI操作の自動化が必要な場合はxautomation等を利用します。

imagemagick recordmydesktop等により実行時の静止画や動画を保存しておきます。

動的解析
--------

実行プログラムの動的解析を行います。

テスト対象の実行プログラムに対してvalgrind等を実行して出力されたレポートを確認します。

* テストプログラムの例

.. code-block:: bash

  $ valgrind --verbose --tool=memcheck --leak-check=full --show-reachable=no --undef-value-errors=no --track-origins=no --child-silent-after-fork=no --trace-children=no --gen-suppressions=no --xml=yes --xml-file=valgrind.xml testEigen3d

静的解析
--------

ソースコードの静的解析を行います。

テスト対象ソースコードに対してcppcheck等を実行して出力されたレポートを確認します。

* テストプログラムの例

.. code-block:: bash

  $ cppcheck --enable=all --inconclusive --xml --xml-version=2 --force src 2> cppcheck.xml


