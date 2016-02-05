=====================================
単体テスト
=====================================

目的
====

共通で利用されるライブラリ(クラスや関数)などの単体テストを行います。

手法
====

対象となるライブラリをリンクしたテストプログラムを作成してクラス／関数の入出力や分岐などを確認します。

テストプログラムはGoogle Test(C++)等のユニットテストフレームワークを利用して作成します。

テストプログラムの例
====================

gtestをインストールします。

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

  $ cmake .
  $ ctest --verbose --test-action Test

