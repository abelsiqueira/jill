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

if [[ "$(whoami)" == "root" ]]; then
  JULIA_DOWNLOAD=${JULIA_DOWNLOAD:-"/opt/julias"}
  JULIA_INSTALL=${JULIA_INSTALL:-"/usr/local/bin"}
else
  JULIA_DOWNLOAD=${JULIA_DOWNLOAD:-"$HOME/packages/julias"}
  JULIA_INSTALL=${JULIA_INSTALL:-"$HOME/.local/bin"}
fi

function header() {
  echo "Jill - Julia Installer 4 Linux (and MacOS) - Light"
  echo "Copyright (C) 2017 Abel Soares Siqueira <abel.s.siqueira@gmail.com>"
  echo "Distributed under terms of the GPLv3 license."
}

function badfolder() {
  echo "The folder '$JULIA_INSTALL' is not on your PATH, you can"
  echo "- 1) Add it to your path; or"
  echo "- 2) Run 'JULIA_INSTALL=otherfolder ./jill.sh'"

  read -p "Do you want to add '$JULIA_INSTALL' into your PATH? (Y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy] ]]; then
    echo "Aborted"
    exit 1
  else
    mkdir -p $JULIA_INSTALL
    echo 'export PATH="'"$JULIA_INSTALL"':$PATH"' | tee -a ~/.bashrc
    echo ""
    echo "run 'source ~/.bashrc' or restart your bash to reload the PATH"
    echo ""
  fi
}

function hi() {
  header
  if [[ ! ":$PATH:" == *":$JULIA_INSTALL:"* ]]; then
    badfolder
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
    echo "You don't have write permission to $JULIA_INSTALL or the dir doesn't exist"
    exit 1
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

function install_julia_linux() {
  mkdir -p $JULIA_DOWNLOAD
  cd $JULIA_DOWNLOAD
  wget https://julialang.org/downloads/ -O page.html
  arch="$(LC_ALL=C lscpu | grep Architecture | cut -d':' -f2 | tr -d '[:space:]')"

  # Download specific version if requested
  if [ -n "${JULIA_VERSION+set}" ]; then
    url=$(grep "https.*linux/.*${JULIA_VERSION}.*${arch}.*gz" page.html -m 1 -o)
  else
    url=$(grep "https.*linux/.*${arch}.*gz" page.html -m 1 -o)
  fi

  [[ $url =~ julia-(.*)-linux ]] && version=${BASH_REMATCH[1]}
  if [ -z "$version" ]; then
    echo "No version $JULIA_VERSION found, it may not be supported anymore"
    exit 1
  fi
  major=${version:0:3}
  wget -c $url -O julia-$version.tar.gz
  mkdir -p julia-$version
  tar zxf julia-$version.tar.gz -C julia-$version --strip-components 1

  rm -f $JULIA_INSTALL/julia{,-$major,-$version}
  julia=$PWD/julia-$version/bin/julia
  ln -s $julia $JULIA_INSTALL/julia
  ln -s $julia $JULIA_INSTALL/julia-$major
  ln -s $julia $JULIA_INSTALL/julia-$version
}

function install_julia_mac() {
  mkdir -p $JULIA_DOWNLOAD
  cd $JULIA_DOWNLOAD
  wget https://julialang.org/downloads/ -O page.html
  arch="mac64"

  # Download specific version if requested
  if [ -n "${JULIA_VERSION+set}" ]; then
    url=$(grep "https.*mac/.*${JULIA_VERSION}.*${arch}.*dmg" page.html -m 1 -o)
  else
    url=$(grep "https.*mac/.*${arch}.*dmg" page.html -m 1 -o)
  fi

  [[ $url =~ julia-(.*)-mac ]] && version=${BASH_REMATCH[1]}
  if [ -z "$version" ]; then
    echo "No version $JULIA_VERSION found, it may not be supported anymore"
    exit 1
  fi
  major=${version:0:3}
  wget -c $url -O julia-$version.dmg

  hdiutil attach julia-$version.dmg -quiet

  INSTALL_PATH=/Applications/julia-$major.app
  EXEC_PATH=$INSTALL_PATH/Contents/Resources/julia/bin/julia
  rm -rf $INSTALL_PATH
  cp -a /Volumes/julia-$version/Julia-$major.app /Applications/

  # create symlink
  ln -sf $EXEC_PATH $JULIA_INSTALL/julia
  ln -sf $EXEC_PATH $JULIA_INSTALL/julia-$major
  ln -sf $EXEC_PATH $JULIA_INSTALL/julia-$version

  # post-installation
  umount /Volumes/julia-$version
}

# --------------------------------------------------------

# Main
hi
confirm
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*) install_julia_linux ;;
    Darwin*) install_julia_mac ;;
    # CYGWIN*)    machine=Cygwin;;
    # MINGW*)     machine=MinGw;;
    *)
        echo "Unsupported platform $(unameOut)" >&2
        exit 1
        ;;
esac
