#!/usr/bin/env bash

function get_version(){
  local version="$(cat $1 | grep -E 'version: ' | cut -d':' -f2)"
  echo $version
}

function whis(){
  echo $(whereis $1 | cut -d':' -f2 )
}

## Dependencies control
if [ -n "$(whis git)" ]; then
  echo 'Git: ok'
else
  echo 'Git must be installed'
  exit
fi

mkdir -p $HOME/.maxpack/{packages}

git clone https://github.com/achengli/maxpack.git $HOME/.maxpack/tmp/maxpack

_version=$(get_version $HOME/.maxpack/tmp/maxpack/package.info)
mkdir -p $HOME/.maxpack/packages/maxpack/versions/maxpack-$version/
mv $HOME/.maxpack/tmp/maxpack $HOME/.maxpack/packages/maxpack/versions/maxpack-$version

cp $HOME/.maxpack/packages/maxpack/versions/maxpack-$version/init.mac $HOME/.maxpack/init.mac

cp $HOME/.maxpack/packages/maxpack/versions/maxpack-$version/init.sh $HOME/.maxpack/init.sh

chmod +x $HOME/.maxpack/init.sh
mkdir -p $HOME/.maxima/
echo "/* Maxpack initializing */" >> $HOME/.maxima/maxima-init.mac
echo 'load("operatingsystem")$' >> $HOME/.maxima/maxima-init.mac
echo 'load(concat(getenv("HOME"), "/.maxpack/init.mac"))$' >> $HOME/.maxima/maxima-init.mac

source $HOME/.maxpack/init.sh
