=====================================
概要
=====================================

はじめに
========

buildfarmはhrpsys-base, choreonoid, OpenHRPなどのロボット関連ソフトウェアのビルドおよび各種テストの実行を自動化するための継続的インテグレーション（CI）環境です。

CIサーバーをオンプレミスに構築するためプライベートなリポジトリやオンプレミスに存在するリポジトリを含むテストや特定のハードウェア（GPUなど）やソフトウェア（OSなど）に依存するテストの実行が可能です。

.. graphviz::

   digraph {
      source1 [label="public repository"];
      source2 [label="private repository"];
      build [label="jenkinshrg"];
      report1 [label="mail server"];
      report2 [label="cloud storage"];
      report3 [label="web page"];
      source1 -> build [label="checkout source"];
      source2 -> build [label="checkout source"];
      build -> report1 [label="send messages"];
      build -> report2 [label="upload logs"];
      build -> report3 [label="update reports"];
   }
