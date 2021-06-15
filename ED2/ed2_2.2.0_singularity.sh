#!/bin/bash

module load singularity
pwd
singularity run --pwd=$(pwd) --contain \
-B /groups/dlebauer/ed2_results/pecan_remote:/groups/dlebauer/ed2_results/pecan_remote \
-B /groups/dlebauer/ed2_results/inputs/julianp/sites:/data/sites \
-B /groups/dlebauer/ed2_results/inputs/julianp/ed_inputs:/data/ed_inputs \
-B /groups/dlebauer/ed2_results/inputs/julianp/faoOLD:/data/faoOLD \
-B /groups/dlebauer/ed2_results/inputs/julianp/oge2OLD:/data/oge2OLD \
-B /groups/dlebauer/ed2_results/inputs/julianp/tests/ed2:/data/tests/ed2 \
/groups/dlebauer/ed2_results/global_inputs/pecan-model-ed2.sif /usr/local/bin/ed.2.2.0 -s
