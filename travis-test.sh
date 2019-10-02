#! /bin/sh

function msg() {
  echo -e "\033[0;31m$1\033[0m"
}

msg "Installing latest Julia"
echo "yy" | bash jill.sh

msg "Testing julia is installed"
julia -v

version=$(julia -v | grep "[0-9]*\.[0-9]*\.[0-9]*" -o)
major=$(echo $version | cut -d. -f1-2)

msg "Testing julia-x.y.z is installed"
julia-$version -v

msg "Testing julia-x-y is installed"
julia-$major -v

msg "Installing specific Julia version"
echo "yy" | JULIA_VERSION=$VERSION bash jill.sh
julia-$VERSION -v

msg "Testing if the version is correct"
[[ $(julia-$VERSION -v) == "julia version $VERSION" ]]

msg "Installing latest Julia without interactive prompt"
bash jill.sh -y
