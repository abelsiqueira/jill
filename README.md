# JILL - Julia Installer 4 Linux - Light

Simply install latest [Julia](https://julialang.org)
[![Build
Status](https://travis-ci.org/abelsiqueira/jill.svg?branch=master)](https://travis-ci.org/abelsiqueira/jill)

On Linux, the best way to install Julia is to use the Generic Linux
Binaries. And while **all Linux users** love manually downloading,
unpacking, and linking their software, this script does it for you.

Simply run

    bash -ci "$(curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"

If you want to avoid using sudo, create a folder, add it to your PATH
and then issue

    JULIA_INSTALL=yourfolder bash -ci "$(curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"

## LICENSE

This script is licensed under the GNU GPLv3 (see
[LICENSE.md](LICENSE.md)). This dosn't affect your Julia usage at all.
