source	/cvmfs/sft.cern.ch/lcg/releases/LCG_88/gcc/6.2.0/x86_64-slc6/gcc-env.sh
source	/cvmfs/sft.cern.ch/lcg/releases/LCG_88/Python/2.7.13/x86_64-slc6-gcc62-opt/Python-env.sh
source	/cvmfs/sft.cern.ch/lcg/releases/LCG_88/ROOT/6.08.06/x86_64-slc6-gcc62-opt/ROOT-env.sh

HOME_DIR=$(pwd)
PROCESS=W_ew-BMNNP

#Install LHAPDF6
#----------------

wget http://www.hepforge.org/archive/lhapdf/LHAPDF-6.2.1.tar.gz
tar xzvf LHAPDF-6.2.1.tar.gz
cd LHAPDF-6.2.1
mkdir install
cd install
LHAPDF_DIR=$(pwd)
cd ..
./configure --prefix="${LHAPDF_DIR}"
make -j 12
make install

export PATH=${LHAPDF_DIR}/bin:$PATH
export LD_LIBRARY_PATH=${LHAPDF_DIR}/lib:$LD_LIBRARY_PATH
export PYTHONPATH=${LHAPDF_DIR}/lib/python2.7/site-packages:$PYTHONPATH

lhapdf install NNPDF30_nlo_as_0118

cd ${HOME_DIR}


#Install HepMC
#--------------

wget http://lcgapp.cern.ch/project/simu/HepMC/download/HepMC-2.06.08.tar.gz
tar xzvf HepMC-2.06.08.tar.gz
cd HepMC-2.06.08
./bootstrap
libtoolize
aclocal
autoconf
autoheader
automake --add-missing

mkdir install
cd install
HEPMC_DIR=$(pwd)

cd ..
./configure --prefix=${HEPMC_DIR} --with-momentum=GEV --with-length=MM

make -j 12
make check
make install
cd ${HOME_DIR}

#Install Pythia8
#----------------

wget http://home.thep.lu.se/~torbjorn/pythia8/pythia8235.tgz
tar xzvf pythia8235.tgz
cd pythia8235

mkdir install
cd install
PYTHIA8_DIR=$(pwd)
cd ..
./configure --prefix=${PYTHIA8_DIR} --with-hepmc2=${HEPMC_DIR} --with-lhapdf6=${LHAPDF_DIR}
make -j 12
make install 

export PATH=${PYTHIA8_DIR}/bin:${PATH}

cd examples

# compile HepMC example in Py8 to check that everything was installed properly
make main41


#Install Delphes
#-----------------

cd ${HOME_DIR}
wget cp3.irmp.ucl.ac.be/downloads/Delphes-3.4.1.tar.gz
tar xzvf Delphes-3.4.1.tar.gz
cd Delphes-3.4.1
make -j 12

export PYTHIA8=${PYTHIA8_DIR}
make -j 12 HAS_PYTHIA8=true

DELPHES_DIR=$(pwd)
cd ${HOME_DIR}

#Install Powheg and W electroweak process
#------------------------------------------

cd ${HOME_DIR}
svn checkout --username anonymous --password anonymous svn://powhegbox.mib.infn.it/trunk/POWHEG-BOX-V2

cd POWHEG-BOX-V2
POWHEG_DIR=$(pwd)

svn co --username anonymous --password anonymous svn://powhegbox.mib.infn.it/trunk/User-Processes-V2/${PROCESS}

# Compile process and install PHOTOS
#------------------------------------

cd $POWHEG_DIR/${PROCESS}
make pwhg_main

cd PHOTOS
PHOTOS_DIR=$(pwd)

chmod u+x configure
./configure --without-hepmc
make -j 12

export LD_LIBRARY_PATH=${PHOTOS_DIR}/lib:${LD_LIBRARY_PATH}
export PYTHIA8DATA=${PYTHIA8_DIR}/share/Pythia8/xmldoc


# Install Pythia8 and Photos executables needed by powheg to do Parton Shower
#-----------------------------------------------------------------------------

cd $POWHEG_DIR/${PROCESS}
make main-PYTHIA82-lhef

sed -i -e 's#Photos::setMomentumUnit#//Photos::setMomentumUnit#' photosCCF.cc
make main-PHOTOS-lhef
cd ${HOME_DIR}

# Save useful env variables
#----------------------------
# Now that main software needed has been installed it is convenient to create some script that automatically loads the necessary environment (something like "init.sh"), that contains the relevant env variables:

echo "source /cvmfs/sft.cern.ch/lcg/releases/LCG_88/gcc/6.2.0/x86_64-slc6/gcc-env.sh		     " >> init.sh
echo "source /cvmfs/sft.cern.ch/lcg/releases/LCG_88/Python/2.7.13/x86_64-slc6-gcc62-opt/Python-env.sh" >> init.sh
echo "source /cvmfs/sft.cern.ch/lcg/releases/LCG_88/ROOT/6.08.06/x86_64-slc6-gcc62-opt/ROOT-env.sh   " >> init.sh

echo "export HEPMC_DIR='${HEPMC_DIR}'" >> init.sh
echo "export LHAPDF_DIR='${LHAPDF_DIR}'" >> init.sh
echo "export PYTHIA8_DIR='${PYTHIA8_DIR}'" >> init.sh
echo "export PYTHIA8='${PYTHIA8_DIR}'" >> init.sh
echo "export POWHEG_DIR='${POWHEG_DIR}'" >> init.sh
echo "export DELPHES_DIR='${DELPHES_DIR}'" >> init.sh

echo "export PATH=\$LHAPDF_DIR/bin:\$PATH" >> init.sh
echo "export LD_LIBRARY_PATH=\$LHAPDF_DIR/lib:\$LD_LIBRARY_PATH" >> init.sh
echo "export PYTHONPATH=\$LHAPDF_DIR/lib/python2.7/site-packages:\$PYTHONPATH" >> init.sh

echo "export PATH=\$PYTHIA8_DIR/bin:\$PATH" >> init.sh
echo "export LD_LIBRARY_PATH=\$PYTHIA8_DIR/lib:\$LD_LIBRARY_PATH" >> init.sh
echo "export PYTHIA8DATA=\$PYTHIA8_DIR/share/Pythia8/xmldoc" >> init.sh
echo "export LD_LIBRARY_PATH=\$PHOTOS_DIR/lib:\$LD_LIBRARY_PATH" >> init.sh


# move init script to home and run it
mv init.sh ${HOME_DIR}
cd ${HOME_DIR}
source init.sh 

# Clean un-necessary tarballs
cd ${HOME_DIR}
rm HepMC-2.06.08.tar.gz pythia8235.tgz LHAPDF-6.2.1.tar.gz Delphes-3.4.1.tar.gz

