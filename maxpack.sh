#!/bin/bash

function maxpack-load-config(){
  if [ $(id -u) == 0 ]; then
    if [ -e '/usr/local/share/maxpack/maxpack.cfg' ]; then
      echo ''
    else
      echo ''
    fi
  else
    if [ -e "$HOME/.config/maxpack/maxpack.cfg" ]; then
      echo ''
    else
      echo ''
    fi
  fi
}

function maxpack--read-config(){
  local config_file=$1
  while read line
  do
    echo "linea >> "$line
  done < "$config_file"
}

function maxpack-install(){
  local package_name=$1
  local package_version=$2

  if [ -z "$package_name" ]; then
    echo "You must pass the name or url of the package"
    return -1
  elif [ -z "$package_version" ]; then
    echo "Latest version will be installed"
  fi

  # search locally

  # search in remote package collection
  
  # go to the url directly
}

function maxpack-remove(){
  return
}

function maxpack-clean(){
  return
}

function maxpack-list(){
  function maxpack-list-remote(){
    return
  }

  function maxpack-list-local(){
    return
  }

  function maxpack-list-all(){
    return
  }
  return 
}

function maxpack-list-versions(){
  return
}

function maxpack-version(){
  return
}

function maxpack--integrity(){
  return
}
