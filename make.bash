#!/bin/bash

# Define the sequencer program name
sncNAME="sncEVG"

# Setup the epics environment
#EPICS_BASE
#EPICS_MODULES

# Pre
cd src/

#1: {sncNAME}.i
gcc -E -x c ${sncNAME}.st > ${sncNAME}.i

#2: {sncNAME}.c
${EPICS_MODULES}/seq/bin/linux-x86_64/snc +m ${sncNAME}.i

#3: {sncNAME}.o
gcc -c ${sncNAME}.c -o ${sncNAME}.o -fno-builtin \
-I. -I.. \
-I${EPICS_MODULES}/seq/include \
-I${EPICS_BASE}/include \
-I${EPICS_BASE}/include/compiler/gcc \
-I${EPICS_BASE}/include/os/Linux

#4: {sncNAME}
g++ -o ${sncNAME} ${sncNAME}.o -rdynamic -m64 \
-L${EPICS_BASE}/lib/linux-x86_64 \
-L${EPICS_MODULES}/seq/lib/linux-x86_64 \
-Wl,-rpath,${EPICS_BASE}/lib/linux-x86_64 \
-Wl,-rpath,${EPICS_MODULES}/seq/lib/linux-x86_64 \
-lseq -lpv -lqsrv -lpvAccessIOC -lpvAccessCA -lpvAccess -lpvData -ldbRecStd -ldbCore -lca -lCom

# Post
mv ${sncNAME} ../bin
