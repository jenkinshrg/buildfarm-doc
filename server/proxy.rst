======================
リバースプロキシの設定
======================

.. note::

  インターネット接続が可能なマシンを用意して下さい。

.. warning::

  他のアプリケーションがポート番号80を使用していないか確認して下さい。

インストール
============

webサーバーをインストールします。

.. code-block:: bash

  $ sudo apt-add-repository -y ppa:nginx/stable
  $ sudo apt-get update
  $ sudo apt-get -y install nginx

リバースプロキシ設定を行います。

.. code-block:: bash

  $ cat << \EOL | sudo tee /etc/nginx/sites-available/default
  server {
          listen 80;
          server_name localhost;
          location / {
                  proxy_set_header Host $http_host;
                  proxy_pass http://localhost:8080;
          }
  }
  EOL
  $ sudo service nginx restart

ブラウザで以下のURLが正しく表示されることを確認して下さい。

http://jenkinshrg.a01.aist.go.jp

