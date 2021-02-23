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
echo "yy" | bash jill.sh --version $VERSION
julia-$VERSION -v

msg "Testing if the version is correct"
[[ $(julia-$VERSION -v) == "julia version $VERSION" ]]

msg "Installing latest Julia without interactive prompt"
bash jill.sh -y

msg "Installing Julia LTS version"
bash jill.sh -y --lts
[[ $(julia-1.0.5 -v) == "julia version 1.0.5" ]]

julia -e 'using Pkg; Pkg.update(); Pkg.add("Example")'

msg "Upgrading to the latest Julia"
bash jill.sh -y -u 1.0.5
julia -e 'using Pkg; Pkg.status()' | grep Example

msg "Installing release candidate version"
bash jill.sh --rc -y
RC=$(julia -v | cut -d' ' -f3)

msg "Testing if the version is correct"
[[ $(julia-$RC -v) == "julia version $RC" ]]
