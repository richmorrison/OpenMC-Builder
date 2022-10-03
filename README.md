# OpenMC-Builder

A shell script to download and compile OpenMC and all dependencies.

This script downloads and compiles the dependencies for OpenMC, and places them in the local directory tree. Unless something goes wrong (ie running the script in a system directory) no changes are made to the "OS" parts of the filesystem. There is no need to run with "sudo".

After compilation of serial and parallel versions of OpenMC is complete, python venv's are also built, with all python dependencies installed, ready to be activated as any other python venv. Nuclear data is also retrieved. References to nuclear data locations either from the Python API or environment variables must be created. (It is possible to put references to a preferred nuclear data library inside the python venv definitions.)

Downloaded source for dependencies is kept by the script for record.

The script creates two directory trees for parallel and serial versions of OpenMC and dependencies. This is inefficient - it is possible to put all library versions side-by-side in the same lib directory. However, I wish to check the resulting binaries to confirm that the correct libs have been linked. Having two directory trees makes visual inspection easier.

I don't believe I've included all necessary dependencies for the more advanced uses of OpenMC. The OpenMC Dockerfile is a good place to look for an overview of all available options.

It is not my intent to keep this script frequently updated against newer versions of OpenMC and Deps. I will update it as/when I need. However, upversioning the various libraries etc should be straight-forward.

At the time of writing, some dependency versions are slightly ahead of those specified in the OpenMC docker image for the specified version of OpenMC. Therefore, it is assumed that compiled OpenMC binary output by this script does not reflect the binary contained in the OpenMC docker image, which is presumably used in testing. For a version of OpenMC that reflects a QA tested version, see the OpenMC project page.

I'm not affiliated with the OpenMC dev team. I refer you to the OpenMC project (https://github.com/openmc-dev/openmc) for compilation information and checked/tested/correct compilation/methods.
