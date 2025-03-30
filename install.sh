if [[ $(id -u) == 0 ]]; then
  echo "Do you want to install maxima package manager as root?"
  opt=$(read)
  if [[ "$opt" == "yes" ] || [ "$opt" == "y" ]]; then
    continue
  else
    exit
  fi

  if [[ $(uname -s) == "Linux" then ]]; then
    export INSTALL_PATH=/usr/bin/
  else
    export INSTALL_PATH=/usr/local/bin/
  fi
fi


