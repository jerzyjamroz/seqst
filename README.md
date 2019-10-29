Not finished and development stopped.
--

# Standalone sequencers for the ESS timing system
The programs manage the runtime routines and states of the EVG and EVR timing hardware.
* sncEVG
* sncEVR

# Requirements
* Epics environment: setEpicsEnv.bash: EPICS_BASE, EPICS_MODULES
* Or
* ${E3_REQUIRE_LOCATION}/bin/setE3Env.bash

# Build
* bash make.bash

# Usage
* IOC and DEV variables have to be defined
* Example: bin/sncEVG "IOC=MTCA, DEV=EVG"

# Future
* .rpm package distribution