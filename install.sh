if [[ $(id -u) == 0 ]]; then
  echo "Do you want to install maxpack as root?"
  opt=$(read)
  if [ -o [ "$opt" == "yes" ] [ "$opt" == "y" ] ]; then
    continue
  else
    exit
  fi
fi;

if [ $(id -u) == 0 ]; then
  if [ $(uname -s) == "Linux" ]; then
    export MAXPACK_INSTALL_PATH=/usr/bin/
  else
    export MAXPACK_INSTALL_PATH=/usr/local/bin/
  fi
else
  export MAXPACK_INSTALL_PATH=$HOME/.maxpack
  mkdir -p $MAXPACK_INSTALL_PATH
fi

cp maxpack.sh $MAXPACK_INSTALL_PATH/maxpack
chmod +x $MAXPACK_INSTALL_PATH/maxpack

if [ $(id -u) == 0 ]; then
  mkdir -p /usr/local/share/.maxpack/{pack,config,tmp}
else
  mkdir -p $HOME/.config/maxpack
  mkdir -p $HOME/.local/share/maxpack/{pack,config,tmp}
fi


