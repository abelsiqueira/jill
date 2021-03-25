#!/usr/bin/env bash
# jill.sh
# Copyright (C) 2017-2021 Abel Soares Siqueira <abel.s.siqueira@gmail.com>
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

JULIA_LTS=1.0.5
JULIA_LATEST=1.6

function usage() {
  echo """usage: jill.sh [options]

Install some version of the julia executable. By default, the latest version (currently $JULIA_LATEST-latest) is installed.

Options and arguments:
  -h, --help              : Show this help
  --lts                   : Install julia long term support version (Currently $JULIA_LTS)
  --rc                    : Install julia latest release candidate (requires jq)
  -u OLD, --upgrade OLD   : Copy environment from OLD version
  -v VER, --version VER   : Install julia version VER. Valid examples: 1.5.4, 1.5-latest, 1.5.0-rc1.
  -y, --yes, --no-confirm : Skip confirmation

Environment variables:
  JULIA_DOWNLOAD: Folder where the julia .tar.gz file will be downloaded and its contents will be decompressed.
    Defaults to /opt/julias when called by root or $HOME/packages/julias otherwise.
  JULIA_INSTALL: Folder where the julia link will be created.
    Defaults to /usr/local/bin when called by root or $HOME/.local/bin otherwise.
"""
}

# Skip confirm if -y is used.
SKIP_CONFIRM=0
# Copy over the old environment to the new one if -u is used.
UPGRADE_CONFIRM=0
JULIA_OLD=""

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
      usage
      shift
      exit 0
      ;;
    --lts)
      JULIA_VERSION=$JULIA_LTS
      shift
      ;;
    --rc)
      if ! command -v jq --version &> /dev/null
      then
        echo "Option --rc requires jq to be installed. Alternatively, use -v with x.y.z-rcN. Aborting"
        exit 1
      fi
      JULIA_VERSION=$(curl -L https://julialang-s3.julialang.org/bin/versions.json | jq -r '[keys[] | select(contains("rc"))] | .[-1]')
      if [ -z "$JULIA_VERSION" ]; then
        echo "Option --rc failed."
        exit 1
      fi
      shift
      ;;
    -u|--upgrade)
      UPGRADE_CONFIRM=1
      JULIA_OLD="$2"
      shift
      shift
      ;;
    -v|--version)
      JULIA_VERSION="$2"
      shift
      shift
      ;;
    -y|--yes|--no-confirm)
      SKIP_CONFIRM=1
      shift
      ;;
    *)    # unknown option
      echo "Invalid option: $1" >&2
      usage
      exit 1;
      ;;
esac
done

# For Linux, this script installs Julia into $JULIA_DOWNLOAD and make a
# link to $JULIA_INSTALL
# For MacOS, this script installs Julia into /Applications and make a
# link to $JULIA_INSTALL
if [[ "$(whoami)" == "root" ]]; then
  JULIA_DOWNLOAD=${JULIA_DOWNLOAD:-"/opt/julias"}
  JULIA_INSTALL=${JULIA_INSTALL:-"/usr/local/bin"}
else
  JULIA_DOWNLOAD=${JULIA_DOWNLOAD:-"$HOME/packages/julias"}
  JULIA_INSTALL=${JULIA_INSTALL:-"$HOME/.local/bin"}
fi
WGET="wget --retry-connrefused -t 3 -q"

function header() {
  echo "JILL - Julia Installer 4 Linux - Light"
  echo "Copyright (C) 2017-2021 Abel Soares Siqueira <abel.s.siqueira@gmail.com>"
  echo "Distributed under terms of the GPLv3 license."
  echo ""
}

function badfolder() {
  echo "The folder '$JULIA_INSTALL' is not on your PATH, you can"
  echo "- 1) Add it to your path; or"
  echo "- 2) Run 'JULIA_INSTALL=otherfolder ./jill.sh'"
  if [[ "$SKIP_CONFIRM" == "0" ]]; then
    read -p "Do you want to add '$JULIA_INSTALL' into your PATH? (Aborting otherwise) (Y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy] ]]; then
      echo "Aborted"
      exit 1
    fi
  fi
  echo 'export PATH="'"$JULIA_INSTALL"':$PATH"' | tee -a ~/.bashrc
  echo ""
  echo "run 'source ~/.bashrc' or restart your bash to reload the PATH"
  echo ""
}

function hi() {
  header
  if [[ ! ":$PATH:" == *":$JULIA_INSTALL:"* ]]; then
    badfolder
  fi
  mkdir -p $JULIA_INSTALL # won't create if it's aborted earlier
  LATEST=0
  if [ -n "${JULIA_VERSION+set}" ]; then
    version=$JULIA_VERSION
  else
    LATEST=1
    version=$JULIA_LATEST-latest
  fi
  echo "This script will:"
  echo ""
  echo "  - Try to download julia version '$version'"
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
    echo "You don't have write permission to $JULIA_INSTALL."
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

function get_url_from_platform_arch_version() {
  platform=$1
  arch=$2
  version=$3
  # TODO: Accept ARM and FreeBSD
  [[ $arch == *"64" ]] && bit=64 || bit=32
  [[ $arch == "mac"* ]] && suffix=mac64.dmg || suffix=$platform-$arch.tar.gz
  minor=$(echo $version | cut -d. -f1-2 | cut -d- -f1)
  url=https://julialang-s3.julialang.org/bin/$platform/x$bit/$minor/julia-$version-$suffix
  echo $url
}

function install_julia_linux() {
  mkdir -p $JULIA_DOWNLOAD
  cd $JULIA_DOWNLOAD
  arch=$(uname -m)

  # Download specific version if requested
  LATEST=0
  if [ -n "${JULIA_VERSION+set}" ]; then
    version=$JULIA_VERSION
  else
    LATEST=1
    version=$JULIA_LATEST-latest
  fi
  echo "Downloading Julia version $version"
  if [ ! -f julia-$version.tar.gz ]; then
    url=$(get_url_from_platform_arch_version linux $arch $version)
    $WGET -c $url -O julia-$version.tar.gz
    if [ $? -ne 0 ]; then
      echo "error downloading julia-$version"
      rm julia-$version.tar.gz
      return
    fi
  else
    echo "already downloaded"
  fi
  if [ ! -d julia-$version ]; then
    mkdir -p julia-$version
    tar zxf julia-$version.tar.gz -C julia-$version --strip-components 1
  fi
  if [[ "$LATEST" == "1" ]]; then
    # Need to change suffix x.y-latest to x.y.z
    JLVERSION=$(./julia-$version/bin/julia -version | cut -d' ' -f3)
    if [ -d julia-$JLVERSION ]; then
      echo "Warning: Latest version $JLVERSION was already installed. Ignoring downloaded version."
      rm -rf julia-$version.tar.gz julia-$version
    else
      mv julia-$version.tar.gz julia-$JLVERSION.tar.gz
      mv julia-$version julia-$JLVERSION
    fi
    version=$JLVERSION
  fi

  major=${version:0:3}
  rm -f $JULIA_INSTALL/julia{,-$major,-$version}
  julia=$PWD/julia-$version/bin/julia

  if [[ "$UPGRADE_CONFIRM" == "1" ]]; then
    old_major=${JULIA_OLD:0:3}
    cp -r ~/.julia/environments/v${old_major} ~/.julia/environments/v${major}
  fi

  # create symlink
  ln -s $julia $JULIA_INSTALL/julia
  ln -s $julia $JULIA_INSTALL/julia-$major
  ln -s $julia $JULIA_INSTALL/julia-$version
}

function install_julia_mac() {
  mkdir -p $JULIA_DOWNLOAD
  cd $JULIA_DOWNLOAD
  arch="mac64"

  # Download specific version if requested
  LATEST=0
  if [ -n "${JULIA_VERSION+set}" ]; then
    version=$JULIA_VERSION
  else
    LATEST=1
    version=$JULIA_LATEST-latest
  fi
  if [ ! -f julia-$version.dmg ]; then
    url=$(get_url_from_platform_arch_version mac $arch $version)
    $WGET -c $url -O julia-$version.dmg
  fi

  major=${version:0:3}

  hdiutil attach julia-$version.dmg -quiet -mount required -mountpoint julia-$major
  if [ ! -d julia-$major ]; then
      # if it fails to mount for unknown reason, try it again after 1 second...
      sleep 1
      hdiutil attach julia-$version.dmg -quiet -mount required -mountpoint julia-$major
  fi

  INSTALL_PATH=/Applications/julia-$major.app
  EXEC_PATH=$INSTALL_PATH/Contents/Resources/julia/bin/julia
  rm -rf $INSTALL_PATH
  cp -a julia-$major/Julia-$major.app /Applications/

  if [[ "$UPGRADE_CONFIRM" == "1" ]]; then
    old_major=${JULIA_OLD:0:3}
    cp -r ~/.julia/environments/v${old_major} ~/.julia/environments/v${major}
  fi

  # create symlink
  ln -sf $EXEC_PATH $JULIA_INSTALL/julia
  ln -sf $EXEC_PATH $JULIA_INSTALL/julia-$major
  
  if [[ "$LATEST" == "1" ]]; then
    version=$($JULIA_INSTALL/julia -version | cut -d' ' -f3)
  fi
  ln -sf $EXEC_PATH $JULIA_INSTALL/julia-$version

  # post-installation
  umount julia-$major
}

# --------------------------------------------------------

# Main
hi
if [[ "$SKIP_CONFIRM" == "0" ]]; then
    confirm
fi
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
