=====================================
概要
=====================================

はじめに
========

buildfarmはhrpsys-base, choreonoid, OpenHRPなどのロボット関連ソフトウェアのビルドおよび各種テストの実行を自動化するための継続的インテグレーション（CI）環境です。

CIサーバーをオンプレミスに構築するためプライベートなリポジトリやオンプレミスに存在するリポジトリを含むテストの実行が可能です。

.. graphviz::

   digraph {
      "source(github.com)" -> "test(jenkins)"
      "source(choreonoid.org)" -> "test(jenkins)"
      "source(atom)" -> "test(jenkins)"
      "test(jenkins)" -> "report(github)"
      "test(jenkins)" -> "report(google)"
   }
