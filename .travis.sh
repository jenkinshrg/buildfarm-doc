#!/bin/bash

set -ex

sudo apt-get update -qq
sudo apt-get install -qq -y python-pip graphviz
sudo pip install -r requires.txt

make html

if [ "$TRAVIS_PULL_REQUEST" == "false" -a "$TRAVIS_BRANCH" == "master" ]; then
  cd ~/
  git clone --branch gh-pages https://github.com/$TRAVIS_REPO_SLUG doc
  cd doc
  cp -r $TRAVIS_BUILD_DIR/_build/html/* ./
  git status
  git add -f .
  git commit -m "Build documents from $TRAVIS_COMMIT" .
  git remote -v
  git push --quiet https://$GH_TOKEN@github.com/$TRAVIS_REPO_SLUG.git gh-pages
fi

