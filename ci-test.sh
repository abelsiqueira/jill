#!/usr/bin/env bash

LTS=1.10.5
LTS_FAMILY=$(echo "$LTS" | cut -d. -f1-2)

if [ -z "$VERSION" ]; then
  echo "Variable VERSION must be set"
  exit 1
fi

msg() {
  echo -e "\033[0;31m$1\033[0m"
}

msg "Installing latest Julia"
echo "yy" | $SUDO bash jill.sh

msg "Testing julia is installed"
julia -v

version=$(julia -v | grep "[0-9]*\.[0-9]*\.[0-9]*" -o)
major=$(echo "$version" | cut -d. -f1-2)

msg "Testing julia-x.y.z is installed"
julia-"$version" -v

msg "Testing julia-x-y is installed"
julia-"$major" -v

msg "Installing specific Julia version"
echo "yy" | $SUDO bash jill.sh --version "$VERSION"
julia-"$VERSION" -v

msg "Testing if the version is correct"
[[ $(julia-"$VERSION" -v) == "julia version $VERSION" ]]

msg "Installing latest Julia without interactive prompt"
$SUDO bash jill.sh -y

msg "Installing Julia LTS version"
$SUDO bash jill.sh -y --lts
[[ $(julia-$LTS -v) == "julia version $LTS" ]]

julia -e 'using Pkg; Pkg.update(); Pkg.add("Example")'

msg "Upgrading to the latest Julia"
$SUDO bash jill.sh -y -u "$LTS_FAMILY"
julia -e 'using Pkg; Pkg.status()' | grep Example
julia -e 'using Pkg; Pkg.update()' # Issue 73

msg "Installing release candidate version"
$SUDO bash jill.sh --rc -y
RC=$(julia -v | cut -d' ' -f3)

msg "Testing if the version is correct"
[[ $(julia-"$RC" -v) == "julia version $RC" ]]
