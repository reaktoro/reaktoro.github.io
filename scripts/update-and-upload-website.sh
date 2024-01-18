#!/bin/bash

set -e  # exit when any command fails

script_path=$(realpath "$0")
script_dir=$(dirname $script_path)
root_dir=$script_dir/../

git checkout main
git reset --hard origin/main

mkdir -p $root_dir/_workspace_
cd $root_dir/_workspace_

wget https://github.com/reaktoro/reaktoro-jupyter-book/archive/refs/heads/main.zip -O main.zip
unzip -o -qq main.zip

cd reaktoro-jupyter-book-main
utils/scripts/build-website.sh

rsync -av _build/html/ $root_dir/

cd $root_dir

git add --all
git commit -a -m "Automatic website update"
git push origin
