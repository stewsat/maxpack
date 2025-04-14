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

export DEFAULT_CONFIG=$HOME/.local/share/maxpack/default/maxpack.cfg
export MAXPACK_RAW_GITHUB_URL='https://raw.githubusercontent.com/achengli/maxpack/refs/heads/main'
export MAXPACK_HOST_URL="NOT IMPLEMENTED"

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
}

function maxpack--read-config(){
"""
Read config file exporting it to bash env variables.
"""
  local config_file=$1
  while read line
  do
    local var=$(echo $line | cut -d'=' -f1)
    var=${var^^}
    local content=$(echo $line | cut -d'=' -f2)
    eval "export ${var}='${content}'"
  done < "$config_file"
}

function maxpack-install(){
  local package_name=$1
  local package_version=$2
  maxpack-load-config

  if [ -z "$package_name" ]; then
    echo "You must pass the name or url of the package"
    return -1
  elif [ -z "$package_version" ]; then
    echo "Latest version will be installed"
  fi

  # `out_code' mark which was the point the package wasn't found.
  local out_code=0
  # search locally
  if [ -e $MAXPACK_HOME/.cache/packages.list ]; then
    local package
    while read line
    do
      if [ -n "$(echo $line | grep -E $package_name)" ]; then
        $remote_package=$(echo $line | grep -Eo "[[:alnum:]_/\.-]+\$")
      else
        out_code=1
      fi
    done < $MAXPACK_HOME/.cache/packages.list
  else
    curl -o $MAXPACK_RAW_GITHUB_URL'/cfg/packages.list'
  fi
  # search in remote package collection
  
  while read line
  do
    echo $line
  done < $(curl $MAXPACK_HOST)
  local remote_package=$(curl $MAXPACK_HOST_URL) | grep -Eo "[[:alnum:]_/\.-]+\$")
  if [ -z "$remote_package" ];then 
    out_code=2
  fi

  # go to the url directly
  if [ -z "$(curl $package)" ]; then  
    out_code=3
  fi

  if [ $out_code == 0 ]; then
  elif [ $out_code == 1 ]; then
  elif [ $out_code == 2 ]; then
  else
  fi

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
