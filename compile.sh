#!/bin/bash
#module unload matlab
#module load matlab/2019a

cat > build.m <<END
addpath(genpath('.'))
mcc -m -R -nodisplay -d compiled main
exit
END

matlab -nodisplay -nosplash -r build && rm build.m



