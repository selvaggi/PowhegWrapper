[]() Package installation
--------------------------

Install all needed packages (LHAPDF, HEPMC, PYTHIA8, DELPHES and POWHEG_V2) at once (to be done only once):
```
./install.sh
```

[]() Run instructions
----------------------


First load the required environment on lxplus:
```
source init.sh
```

Then go to process directory and generate LHE file:

```
cd  POWHEG-BOX-V2/W_ew-BMNNP/runtest-lhc-8Tev-wp
../pwhg_main
```

Now add the following lines to cinfiguration file ```powheg.input```:

```
SI_inputfile 'pwgevents.lhe'
SI_savelhe 1
```

And generate showered events:

```
../main-PYTHIA82-lhef
```

The output ```output_shower_events.lhe``` LHE file contains showered events. 

