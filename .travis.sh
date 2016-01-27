#!/bin/bash

set -x

sudo apt-get update -qq
sudo apt-get install -qq -y python-pip
sudo pip install -r requires.txt

make html

