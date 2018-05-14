#!/bin/bash
module load matlab/2017a

#THIS IS STILL TODO.. doesn't work yet

cat > build.m <<END
addpath(genpath('/N/u/brlife/git/encode'))
addpath(genpath('/N/u/brlife/git/vistasoft'))
addpath(genpath('/N/u/brlife/git/jsonlab'))
addpath(genpath('/N/soft/mason/SPM/spm8'))

addpath(genpath('/N/u/kitchell/Karst/Applications/mba'))
%addpath(genpath('/N/dc2/projects/lifebid/code/kitchell/wma'))
addpath(genpath('/N/u/brlife/git/wma'))

mcc -m -R -nodisplay -d compiled main
exit
END
matlab -nodisplay -nosplash -r build && rm build.m
