#!/bin/bash

# Richard Morrison, October 2022
# https://github.com/richmorrison/OpenMC-Builder

# Exit on error
set -e

###############################################################
#
# Library download locations (and version tags where required)
#
###############################################################

Zliblink=https://zlib.net/fossils/zlib-1.3.1.tar.gz

LibAEClink=https://gitlab.dkrz.de/k202009/libaec.git
LibAECtag=v1.1.3

LibPNGlink=https://download.sourceforge.net/libpng/libpng-1.6.43.tar.gz

MPICHlink=https://www.mpich.org/static/downloads/4.2.1/mpich-4.2.1.tar.gz

HDF5link=https://github.com/HDFGroup/hdf5/releases/download/hdf5_1.14.4.3/hdf5-1.14.4-3.tar.gz

Eigen3link=https://gitlab.com/libeigen/eigen.git
Eigen3tag=3.4.0

MOABlink=https://bitbucket.org/fathomteam/moab.git
MOABtag=5.5.1

DAGMClink=https://github.com/svalinn/DAGMC.git
DAGMCtag=v3.2.3

LibMeshlink=https://github.com/libMesh/libmesh.git
LibMeshtag=v1.7.1

OpenMClink=https://github.com/openmc-dev/openmc.git
OpenMCtag=v0.14.0

nuclear_data_links=(
  https://anl.box.com/shared/static/9igk353zpy8fn9ttvtrqgzvw1vtejoz6.xz
  https://anl.box.com/shared/static/uhbxlrx7hvxqw27psymfbhi7bx7s6u6a.xz
  https://anl.box.com/shared/static/4jwkvrr9pxlruuihcrgti75zde6g7bum.xz
)

###############################################################
#
# Build configuration
#
###############################################################

jobs=4

topDir=`pwd`
compile_out_serial=${topDir}/serial
compile_out_mpi=${topDir}/mpi
srcDir=${topDir}/src
buildDir=${topDir}/build

build_parallel_suffix=_parallel

pythonvenv_serial=${topDir}/openmc_venv
pythonvenv_parallel=${topDir}/openmc_venv_parallel

nuc_lib_dir=${topDir}/nuclear_data

###############################################################
#
# Preliminaries
#
###############################################################

mkdir -p ${compile_out_serial}
mkdir -p ${compile_out_mpi}
mkdir -p ${srcDir}
mkdir -p ${buildDir}
mkdir -p ${nuc_lib_dir}

###############################################################
#
# Downloads/Clones
#
###############################################################

cd ${srcDir}

wget ${Zliblink}
git clone ${LibAEClink}
wget ${LibPNGlink}
wget ${MPICHlink}
wget ${HDF5link}
git clone ${Eigen3link}
git clone ${MOABlink}
git clone ${DAGMClink}
git clone ${LibMeshlink}
git clone ${OpenMClink}

###############################################################
#
# Extracts
#
###############################################################

cd ${srcDir}

tar -xf ${Zliblink##*/}
tar -xf ${LibPNGlink##*/}
tar -xf ${MPICHlink##*/}
tar -xf ${HDF5link##*/}

###############################################################
#
# Set directories
#
###############################################################

cd ${srcDir}

zlibdir=`ls -d zlib-* | grep -v '.tar.gz'`
zlibdir_src=${srcDir}/${zlibdir}
zlibdir_build=${buildDir}/${zlibdir}

libaecdir=libaec
libaecdir_src=${srcDir}/${libaecdir}
libaecdir_build=${buildDir}/${libaecdir}

libpngdir=`ls -d libpng* | grep -v '.tar.gz'`
libpngdir_src=${srcDir}/${libpngdir}
libpngdir_build=${buildDir}/${libpngdir}

mpichdir=`ls -d mpich-* | grep -v '.tar.gz'`
mpichdir_src=${srcDir}/${mpichdir}
mpichdir_build=${buildDir}/${mpichdir}

hdf5dir=`ls -d hdf5-* | grep -v '.tar.gz'`
hdf5dir_src=${srcDir}/${hdf5dir}
hdf5dir_build=${buildDir}/${hdf5dir}
hdf5dir_build_parallel=${buildDir}/${hdf5dir}${build_parallel_suffix}

eigen3dir=eigen
eigen3dir_src=${srcDir}/${eigen3dir}
eigen3dir_build=${buildDir}/${eigen3dir}

moabdir=moab
moabdir_src=${srcDir}/${moabdir}
moabdir_build=${buildDir}/${moabdir}
moabdir_build_parallel=${buildDir}/${moabdir}${build_parallel_suffix}

dagmcdir=DAGMC
dagmcdir_src=${srcDir}/${dagmcdir}
dagmcdir_build=${buildDir}/${dagmcdir}

libmeshdir=libmesh
libmeshdir_src=${srcDir}/${libmeshdir}
libmeshdir_build=${buildDir}/${libmeshdir}
libmeshdir_build_parallel=${buildDir}/${libmeshdir}${build_parallel_suffix}

OpenMCdir=openmc
OpenMCdir_src=${srcDir}/${OpenMCdir}
OpenMCdir_build=${buildDir}/${OpenMCdir}
OpenMCdir_build_parallel=${buildDir}/${OpenMCdir}${build_parallel_suffix}

###############################################################
#
# Create build directories
#
###############################################################

mkdir -p ${zlibdir_build}
mkdir -p ${libaecdir_build}
mkdir -p ${libpngdir_build}
mkdir -p ${mpichdir_build}
mkdir -p ${hdf5dir_build}
mkdir -p ${hdf5dir_build_parallel}
mkdir -p ${eigen3dir_build}
mkdir -p ${moabdir_build}
mkdir -p ${moabdir_build_parallel}
mkdir -p ${dagmcdir_build}
mkdir -p ${libmeshdir_build}
mkdir -p ${libmeshdir_build_parallel}
mkdir -p ${OpenMCdir_build}
mkdir -p ${OpenMCdir_build_parallel}

###############################################################
#
# Zliblink
#
###############################################################

cd ${zlibdir_build}

${zlibdir_src}/configure --prefix=${compile_out_serial}
make -j${jobs}
make install

${zlibdir_src}/configure --prefix=${compile_out_mpi}
make -j${jobs}
make install

###############################################################
#
# LibAEC
#
###############################################################

cd ${libaecdir_src}
git checkout tags/${LibAECtag}

cd ${libaecdir_build}

cmake ${libaecdir_src} -DCMAKE_INSTALL_PREFIX=${compile_out_serial}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

cmake ${libaecdir_src} -DCMAKE_INSTALL_PREFIX=${compile_out_mpi}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

###############################################################
#
# LibPNG
#
###############################################################

cd ${libpngdir_build}

${libpngdir_src}/configure --prefix=${compile_out_serial}
make -j${jobs}
make install

${libpngdir_src}/configure --prefix=${compile_out_mpi}
make -j${jobs}
make install

###############################################################
#
# MPICH
#
###############################################################

cd ${mpichdir_build}

${mpichdir_src}/configure CPPFLAGS="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64" --prefix=${compile_out_mpi}
make -j${jobs}
make install

###############################################################
#
# HDF5
#
###############################################################

cd ${hdf5dir_build}
${hdf5dir_src}/configure --enable-shared CPPFLAGS="-I${compile_out_serial}/include" LDFLAGS="-L${compile_out_serial}/lib" --enable-fortran --enable-cxx --prefix=${compile_out_serial}
make -j${jobs}
make install

# It is not clear if the --disable-hl flag should be used here since the high-level library does not trigger the global lock. However, the high-level library is required by dagmc.
# I'll assume here that the codes and libraries compiled in this script are engineered to avoid simultaneous access.
cd ${hdf5dir_build_parallel}
CC=${compile_out_mpi}/bin/mpicc ${hdf5dir_src}/configure --enable-shared CPPFLAGS="-I${compile_out_mpi}/include" LDFLAGS="-L${compile_out_mpi}/lib" --enable-parallel --prefix=${compile_out_mpi}
make -j${jobs}
make install

###############################################################
#
# EIGEN3
#
###############################################################

cd ${eigen3dir_src}
git checkout tags/${Eigen3tag}

cd ${eigen3dir_build}

cmake ${eigen3dir_src} -DCMAKE_INSTALL_PREFIX=${compile_out_serial}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

cmake ${eigen3dir_src} -DCMAKE_INSTALL_PREFIX=${compile_out_mpi}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

###############################################################
#
# MOAB
#
###############################################################

cd ${moabdir_src}
git checkout tags/${MOABtag}

cd ${moabdir_build}
cmake ${moabdir_src} -DCMAKE_PREFIX_PATH=${compile_out_serial} -DENABLE_BLASLAPACK=OFF -DENABLE_HDF5=ON -DENABLE_ZLIB=ON -DCMAKE_INSTALL_PREFIX=${compile_out_serial}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

cd ${moabdir_build_parallel}
cmake ${moabdir_src} -DCMAKE_PREFIX_PATH=${compile_out_mpi} -DCMAKE_C_COMPILER=${compile_out_mpi}/bin/mpicc -DCMAKE_CXX_COMPILER=${compile_out_mpi}/bin/mpicxx -DCMAKE_Fortran_COMPILER=${compile_out_mpi}/bin/mpif90 -DENABLE_BLASLAPACK=OFF -DENABLE_HDF5=ON -DENABLE_MPI=ON -DENABLE_ZLIB=ON -DCMAKE_INSTALL_PREFIX=${compile_out_mpi}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

###############################################################
#
# DAGMC
#
###############################################################

cd ${dagmcdir_src}
git checkout tags/${DAGMCtag}
git submodule update --init --recursive

cd ${dagmcdir_build}

cmake ${dagmcdir_src} -DMOAB_DIR=${compile_out_serial} -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=${compile_out_serial}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

cmake ${dagmcdir_src} -DMOAB_DIR=${compile_out_mpi} -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=${compile_out_mpi}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

###############################################################
#
# LibMesh
#
###############################################################

cd ${libmeshdir_src}
git checkout tags/${LibMeshtag}
git submodule update --init --recursive

cd ${libmeshdir_build}
${libmeshdir_src}/configure CPPFLAGS=-I${compile_out_serial}/include LDFLAGS=-L${compile_out_serial}/lib --disable-mpi --prefix=${compile_out_serial}
make -j${jobs}
make install

cd ${libmeshdir_build_parallel}
${libmeshdir_src}/configure CC=${compile_out_mpi}/bin/mpicc CXX=${compile_out_mpi}/bin/mpicxx FC=${compile_out_mpi}/bin/mpifort F77=${compile_out_mpi}/bin/mpifort CPPFLAGS=-I${compile_out_mpi}/include LDFLAGS=-L${compile_out_mpi}/lib --with-mpi=${compile_out_mpi} --prefix=${compile_out_mpi}
make -j${jobs}
make install

###############################################################
#
# OpenMC
#
###############################################################

cd ${OpenMCdir_src}
git checkout tags/${OpenMCtag}
git submodule update --init --recursive

cd ${OpenMCdir_build}
# -DOPENMC_BUILD_TESTS=off due to compilation error
cmake ${OpenMCdir_src} \
    -DOPENMC_BUILD_TESTS=off \
    -DHDF5_PREFER_PARALLEL=off \
    -DOPENMC_USE_DAGMC=on \
    -DOPENMC_USE_LIBMESH=on \
    -DOPENMC_USE_OPENMP=off \
    -DOPENMC_USE_MPI=off \
    -DCMAKE_PREFIX_PATH=${compile_out_serial} \
    -DCMAKE_INSTALL_PREFIX=${compile_out_serial}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

cd ${OpenMCdir_build_parallel}
# -DOPENMC_BUILD_TESTS=off due to compilation error
cmake ${OpenMCdir_src} \
    -DOPENMC_BUILD_TESTS=off \
    -DHDF5_PREFER_PARALLEL=on \
    -DOPENMC_USE_DAGMC=on \
    -DOPENMC_USE_LIBMESH=on \
    -DOPENMC_USE_OPENMP=on \
    -DOPENMC_USE_MPI=on \
    -DCMAKE_CXX_COMPILER=${compile_out_mpi}/bin/mpicxx \
    -DCMAKE_PREFIX_PATH=${compile_out_mpi} \
    -DCMAKE_INSTALL_PREFIX=${compile_out_mpi}
cmake --build . --parallel ${jobs} --config Release
cmake --install . --config Release

###############################################################
#
# Build Python3 venv
#
###############################################################

# Create venv with serial HDF5

python3 -m venv ${pythonvenv_serial}
. ${pythonvenv_serial}/bin/activate

pip3 install wheel

# Required
pip3 install --no-cache-dir --no-binary=all NumPy
pip3 install --no-cache-dir --no-binary=all SciPy
pip3 install --no-cache-dir --no-binary=all pandas
env HDF5_DIR=${compile_out_serial} HDF5_MPI=OFF pip3 install --no-cache-dir --no-binary=all h5py
pip3 install --no-cache-dir --no-binary=all matplotlib
pip3 install --no-cache-dir --no-binary=all uncertainties
pip3 install --no-cache-dir --no-binary=all lxml

# Optionals
pip3 install --no-cache-dir --no-binary=all Cython
pip3 install --no-cache-dir --no-binary=all vtk
pip3 install --no-cache-dir --no-binary=all pytest

cd ${OpenMCdir_src}

env HDF5_DIR=${compile_out_serial} HDF5_MPI=OFF pip3 install --no-cache-dir --no-binary=all .

deactivate

ln -s ${compile_out_serial}/bin/openmc ${pythonvenv_serial}/bin

# Create venv with parallel HDF5

python3 -m venv ${pythonvenv_parallel}
. ${pythonvenv_parallel}/bin/activate

pip3 install wheel

# Required
pip3 install --no-cache-dir --no-binary=all NumPy
pip3 install --no-cache-dir --no-binary=all SciPy
pip3 install --no-cache-dir --no-binary=all pandas
env HDF5_DIR=${compile_out_mpi} HDF5_MPI=ON pip3 install --no-cache-dir --no-binary=all h5py
pip3 install --no-cache-dir --no-binary=all matplotlib
pip3 install --no-cache-dir --no-binary=all uncertainties
pip3 install --no-cache-dir --no-binary=all lxml

# Optionals
env MPICC=${compile_out_mpi}/bin/mpicc pip3 install --no-cache-dir --no-binary=all mpi4py
pip3 install --no-cache-dir --no-binary=all Cython
pip3 install --no-cache-dir --no-binary=all vtk
pip3 install --no-cache-dir --no-binary=all pytest

cd ${OpenMCdir_src}

env HDF5_DIR=${compile_out_mpi} HDF5_MPI=ON pip3 install --no-cache-dir --no-binary=all .

deactivate

ln -s ${compile_out_mpi}/bin/openmc ${pythonvenv_parallel}/bin

###############################################################
#
# Download data libraries
#
###############################################################

cd ${nuc_lib_dir}

for nuclear_data_link in ${nuclear_data_links[@]}; do
  wget ${nuclear_data_link}
  tar -xf ${nuclear_data_link##*/}
  rm ${nuclear_data_link##*/}
done
