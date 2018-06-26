#!/bin/bash
module load matlab/2017a

log=compiled/commit_ids.txt
true > $log
echo "/N/u/brlife/git/encode" >> $log
(cd /N/u/brlife/git/encode && git log -1) >> $log
echo "/N/u/brlife/git/vistasoft" >> $log
(cd /N/u/brlife/git/vistasoft && git log -1) >> $log
echo "/N/u/brlife/git/jsonlab" >> $log
(cd /N/u/brlife/git/jsonlab && git log -1) >> $log
echo "/N/u/kitchell/Karst/Applications/mba" >> $log
(cd /N/u/kitchell/Karst/Applications/mba && git log -1) >> $log
echo "/N/u/brlife/git/wma" >> $log
(cd /N/u/brlife/git/wma && git log -1) >> $log

cat > build.m <<END
addpath(genpath('/N/u/brlife/git/encode'))
addpath(genpath('/N/u/brlife/git/vistasoft'))
addpath(genpath('/N/u/brlife/git/jsonlab'))
addpath(genpath('/N/soft/mason/SPM/spm8'))

addpath(genpath('/N/u/kitchell/Karst/Applications/mba'))
addpath(genpath('/N/u/brlife/git/wma'))

mcc -m -R -nodisplay -d compiled main
exit
END
matlab -nodisplay -nosplash -r build && rm build.m
