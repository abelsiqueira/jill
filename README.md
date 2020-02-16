# JILL - Julia Installer 4 Linux (and MacOS) - Light

[![Build
Status](https://travis-ci.org/abelsiqueira/jill.svg?branch=master)](https://travis-ci.org/abelsiqueira/jill)

Simply install latest [Julia](https://julialang.org) for Linux and MacOS. For more functionality and flexibility you can try the python fork [jill.py](https://github.com/johnnychen94/jill.py)

Last tested version: ![Julia 1.3.0](https://img.shields.io/badge/julia-1.3.0-3a5fcc.svg?style=flat-square&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAMAAAAolt3jAAAB+FBMVEUAAAA3lyU3liQ4mCY4mCY3lyU4lyY1liM3mCUskhlSpkIvkx0zlSEeigo5mSc8mio0liKPxYQ/nC5NozxQpUBHoDY3lyQ5mCc3lyY6mSg3lyVPpD9frVBgrVFZqUpEnjNgrVE3lyU8mio8mipWqEZhrVJgrVFfrE9JoTkAVAA3lyXJOjPMPjNZhCowmiNOoz1erE9grVFYqUhCnjFmk2KFYpqUV7KTWLDKOjK8CADORj7GJx3SJyVAmCtKojpOoz1DnzFVeVWVSLj///+UV7GVWbK8GBjPTEPMQTjPTUXQUkrQSEGZUycXmg+WXbKfZ7qgarqbYraSVLCUV7HLPDTKNy7QUEjUYVrVY1zTXFXPRz2UVLmha7upeMCqecGlcb6aYLWfaLrLPjXLPjXSWFDVZF3VY1zVYlvRTkSaWKqlcr6qesGqecGpd8CdZbjo2+7LPTTKOS/QUUnVYlvVY1zUXVbPSD6TV7OibLuqecGqecGmc76aYbaibLvKOC/SWlPMQjrQUEjRVEzPS0PLPDL7WROZX7WgarqibLucY7eTVrCVWLLLOzLGLCLQT0bIMynKOC7FJx3MPjV/Vc+odsCRUa+SVLCDPaWVWLKWWrLJOzPHOTLKPDPLPDPLOzLLPDOUV6+UV7CVWLKVWLKUV7GUWLGPUqv///8iGqajAAAAp3RSTlMAAAAAAAAAAAAAABAZBAAAAABOx9uVFQAAAB/Y////eQAAADv0////pgEAAAAAGtD///9uAAAAAAAAAAcOQbPLfxgNAAAAAAA5sMyGGg1Ht8p6CwAAFMf///94H9j///xiAAAw7////65K+f///5gAABjQ////gibg////bAAAAEfD3JwaAFfK2o0RAAAAAA4aBQAAABEZAwAAAAAAAAAAAAAAAAAAAIvMfRYAAAA6SURBVAjXtcexEUBAFAXAfTM/IDH6uAbUqkItyAQYR26zDeS0UxieBvPVbArjXd9GS295raa/Gmu/A7zfBRgv03cCAAAAAElFTkSuQmCC)

On Linux, the best way to install Julia is to use the Generic Linux
Binaries. And while **all Linux users** love manually downloading,
unpacking, and linking their software, this script does it for you.

Simply run

    bash -ci "$(curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"

installs Julia into `$HOME/.local/bin`.

If you want to install Julia system-wide, you can add an `sudo` prefix

    sudo bash -ci "$(curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"

If you want to install to other places, you can specify the `JULIA_DOWNLOAD` and `JULIA_INSTALL` folder

    JULIA_DOWNLOAD=downloadfolder JULIA_INSTALL=linkfolder bash -ci "$(curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"

The script will then download Julia in `JULIA_DOWNLOAD` and make a link to `JULIA_INSTALL`.

To download a specific older version, use

    JULIA_VERSION=x.y.z bash -ci "$(curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"

Where `x.y.z` is the desired version.


If you wish to run the install script without interactive prompts, please clone this repository and run the following:

    bash jill.sh -y

## LICENSE

This script is licensed under the GNU GPLv3 (see
[LICENSE.md](LICENSE.md)). This dosn't affect your Julia usage at all.
