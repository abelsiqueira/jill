<p>
  <img width="150" align='right' src="jill.jpg">
</p>

# jill - Julia Installer 4 Linux - Light

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/abelsiqueira/jill/CI?style=flat-square)
[![DOI](https://img.shields.io/badge/DOI-10.5281/zenodo.4552552-blue?style=flat-square)](https://zenodo.org/badge/latestdoi/110103530?style=flat-square)
![Julia 1.5.3](https://img.shields.io/badge/tested_on_julia-1.5.3-3a5fcc.svg?style=flat-square&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAMAAAAolt3jAAAB+FBMVEUAAAA3lyU3liQ4mCY4mCY3lyU4lyY1liM3mCUskhlSpkIvkx0zlSEeigo5mSc8mio0liKPxYQ/nC5NozxQpUBHoDY3lyQ5mCc3lyY6mSg3lyVPpD9frVBgrVFZqUpEnjNgrVE3lyU8mio8mipWqEZhrVJgrVFfrE9JoTkAVAA3lyXJOjPMPjNZhCowmiNOoz1erE9grVFYqUhCnjFmk2KFYpqUV7KTWLDKOjK8CADORj7GJx3SJyVAmCtKojpOoz1DnzFVeVWVSLj///+UV7GVWbK8GBjPTEPMQTjPTUXQUkrQSEGZUycXmg+WXbKfZ7qgarqbYraSVLCUV7HLPDTKNy7QUEjUYVrVY1zTXFXPRz2UVLmha7upeMCqecGlcb6aYLWfaLrLPjXLPjXSWFDVZF3VY1zVYlvRTkSaWKqlcr6qesGqecGpd8CdZbjo2+7LPTTKOS/QUUnVYlvVY1zUXVbPSD6TV7OibLuqecGqecGmc76aYbaibLvKOC/SWlPMQjrQUEjRVEzPS0PLPDL7WROZX7WgarqibLucY7eTVrCVWLLLOzLGLCLQT0bIMynKOC7FJx3MPjV/Vc+odsCRUa+SVLCDPaWVWLKWWrLJOzPHOTLKPDPLPDPLOzLLPDOUV6+UV7CVWLKVWLKUV7GUWLGPUqv///8iGqajAAAAp3RSTlMAAAAAAAAAAAAAABAZBAAAAABOx9uVFQAAAB/Y////eQAAADv0////pgEAAAAAGtD///9uAAAAAAAAAAcOQbPLfxgNAAAAAAA5sMyGGg1Ht8p6CwAAFMf///94H9j///xiAAAw7////65K+f///5gAABjQ////gibg////bAAAAEfD3JwaAFfK2o0RAAAAAA4aBQAAABEZAwAAAAAAAAAAAAAAAAAAAIvMfRYAAAA6SURBVAjXtcexEUBAFAXAfTM/IDH6uAbUqkItyAQYR26zDeS0UxieBvPVbArjXd9GS295raa/Gmu/A7zfBRgv03cCAAAAAElFTkSuQmCC)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/abelsiqueira/jill?color=purple&logo=github&style=flat-square)

[Julia](https://julialang.org) light installer for Linux.

---

On Linux, the best way to install Julia is to use the Generic Linux
Binaries. And while **all Linux users** love manually downloading,
unpacking, and linking their software, this script does it for you.

_Disclaimer: MacOS support was dropped. Let me know if you want to help maintain it._
## Quick version - Install latest stable linux

Simply run

    sudo bash -ci "$(curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"

Sudo is optional. If you prefer to not use it, make sure to add `$HOME/.local/bin` to your `PATH`.

## More options - Download jill.sh

Either download the jill.sh script, e.g.

    wget https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh

or

    curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh > jill.sh

or clone the full repo (for instance, if you had SSL issues as in #32):

    git clone https://github.com/abelsiqueira/jill

You can use the script via `bash jill.sh` or make it executable using `chmod a+x jill.sh`. We'll use the former version here.

**Usage**:

    bash jill.sh [options]

If no options are given, this will install the latest stable Julia.
The .tar.gz and unpacked folder will be kept on the environment variable `JULIA_DOWNLOAD`, and the `julia` executable will be linked in `JULIA_INSTALL`.

By default, we use

- `JULIA_DOWNLOAD=/opt/julias` and `JULIA_INSTALL=/usr/local/bin` if you have root permission (e.g. called with `sudo`).
- `JULIA_DOWNLOAD=$HOME/packages/julias` and `JULIA_INSTALL=$HOME/.local/bin` otherwise.

The following options are avaiable:

- `-h, --help`: Show a help.
- `--lts`: Install the Long Term Support version (Currently 1.0.5).
- `--rc`: Install the latest release candidate (uses `jq` to query the versions from julialang.org).
- `-u OLD, --upgrade OLD`: Copy the environment from OLD version.
- `-v VER, --version VER`: Install julia version VER. Valid examples: 1.5.3, 1.5-latest, 1.5.0-rc1.
- `-y, --yes, --no-confirm`: Skip confirmation.

## LICENSE

This script is licensed under the GNU GPLv3 (see
[LICENSE.md](LICENSE.md)). This dosn't affect your Julia usage at all.
