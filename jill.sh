#/usr/bin/env sh
#
# jill.sh
# Copyright (C) 2017 Abel Soares Siqueira <abel.s.siqueira@gmail.com>
#
# Distributed under terms of the GPLv3 license.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

JULIA_DOWNLOAD=${JULIA_DOWNLOAD:-"$HOME/packages/julias"}
JULIA_INSTALL=${JULIA_INSTALL:-"/usr/local/bin"}

function header() {
  echo "Jill - Julia Installer 4 Linux - Light"
  echo "Copyright (C) 2017 Abel Soares Siqueira <abel.s.siqueira@gmail.com>"
  echo "Distributed under terms of the GPLv3 license."
}

function badfolder() {
  echo "The folder '$JULIA_INSTALL' is not on your PATH, you can"
  echo "- 1) Add it to your path; or"
  echo "- 2) Run 'JULIA_INSTALL=otherfolder ./jill.sh'"
}

function hi() {
  header
  if [[ ! ":$PATH:" == *":$JULIA_INSTALL:"* ]]; then
    badfolder
    exit 1
  fi
  echo "This script will:"
  echo ""
  # TODO: Expand to install older Julia?
  echo "  - Download latest stable Julia"
  echo "  - Create a link for julia"
  echo "  - Create a link for julia-VER"
  echo ""
  echo "Download folder: $JULIA_DOWNLOAD"
  echo "Link folder: $JULIA_INSTALL"
  echo ""
  if [ ! -d $JULIA_DOWNLOAD ]; then
    echo "Download folder will be created if required"
  fi
  if [ ! -w $JULIA_INSTALL ]; then
    echo "You'll be asked for your sudo password to install on $JULIA_INSTALL"
  fi
}

function confirm() {
  read -p "Do you accept these terms? (Y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy] ]]; then
    echo "Aborted"
    exit 1
  fi
}

function download_and_install() {
  mkdir -p $JULIA_DOWNLOAD
  cd $JULIA_DOWNLOAD
  wget https://julialang.org/downloads/ -O page.html
  arch="$(lscpu | grep Architecture | cut -d':' -f2 | tr -d '[:space:]')" 
  echo $JULIA_VERSION

  # Download specific version if requested
  if [ -n "${JULIA_VERSION+set}" ]; then
    url=$(grep "https.*linux/.*${JULIA_VERSION}.*${arch}.*gz" page.html -m 1 -o)
  else
    url=$(grep "https.*linux/.*${arch}.*gz" page.html -m 1 -o)
  fi

  [[ $url =~ julia-(.*)-linux ]] && version=${BASH_REMATCH[1]}
  major=${version:0:3}
  wget -c $url -O julia-$version.tar.gz
  mkdir -p julia-$version
  tar zxf julia-$version.tar.gz -C julia-$version --strip-components 1

  if [ ! -w $JULIA_INSTALL ]; then
    SUDO=sudo
  fi
  $SUDO rm -f $JULIA_INSTALL/julia{,-$major,-$version}
  julia=$PWD/julia-$version/bin/julia
  $SUDO ln -s $julia $JULIA_INSTALL/julia
  $SUDO ln -s $julia $JULIA_INSTALL/julia-$major
  $SUDO ln -s $julia $JULIA_INSTALL/julia-$version
}

# --------------------------------------------------------

hi
confirm
download_and_install
