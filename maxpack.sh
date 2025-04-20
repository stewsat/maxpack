#!/bin/bash
## <Maxpack -- A maxima package manager>
## Copyright (C) 2025 Yassin Achengli
## 
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

export MAXPACK_HOME=$HOME/.config/maxpack
export DEFAULT_CONFIG=$MAXPACK_HOME/maxpack.cfg
export MAXPACK_HOST_URL="NOT IMPLEMENTED"

function echoerr(){
  local echomsg=$1
  if [ -z "$echomsg" ]; then
    echoerr "echoerr: bad usage"
  else
    echo -e '\033[0;31m[ERROR] - \033[0m'$echomsg
  fi
  exit $2
}

function maxpack-load-config(){
"""
Load maxpack configuration with priority order:
1. default config '$HOME/.local/share/maxpack/default/maxpack.cfg'
2. maxpack user defined config
"""
  if [ $(id -u) == 0 ]; then
    if [ -e '/usr/local/share/maxpack/maxpack.cfg' ]; then
      maxpack--read-config /usr/local/share/maxpack/default/maxpack.cfg
      maxpack--read-config /usr/local/share/maxpack/maxpack.cfg
    else
      maxpack--read-config /usr/local/share/maxpack/default/maxpack.cfg
    fi
  else
    if [ -e "$HOME/.config/maxpack/maxpack.cfg" ]; then
      maxpack--read-config /usr/local/share/maxpack/default/maxpack.cfg
      maxpack--read-config $HOME/.config/maxpack/maxpack.cfg
    else
      maxpack--read-config $DEFAULT_CONFIG
    fi
  fi
  export maxpack_config_loaded=yes
}

function maxpack--read-config(){
"""
Read config file exporting it to bash env variables.
"""
  local config_file=$1
  while read line
  do
    local var=$(echo $line | cut -d'=' -f1 | xargs)
    var=${var^^} # to uppercase
    local content=$(echo $line | cut -d'=' -f2 | xargs)
    eval "export ${var}=\"${content}\""
  done < "$config_file"
}

function maxpack-install(){
  local package_name=$1
  local package_version=$2

  if [ -z "$maxpack_config_loaded" ]; then
    maxpack-load-config
  fi

  if [ -z "$package_name" ]; then
    echoerr "maxpack-install: You must pass a package name and OPTIONALLY a version of the package" -1
  elif [ -z "$package_version" ]; then
    echo "Latest version of ${package_name:0:20} will be installed"
    package_version=latest
  fi

  if ![ -f $MAXPACK_HOME/remote.list ]; then
    echoerr "maxpack-install: No remote is defined" -1
  fi

  for f in $MAXPACK
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
