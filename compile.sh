#!/bin/bash

set -e
set -x

cat > build.m <<END
addpath(genpath('.'))
mcc -m -R -nodisplay -d compiled main
exit
END

matlab -nodisplay -nosplash -r build && rm build.m

scp compiled/test login.expanse.sdsc.edu:/home/hayashis/test/wmaseg/compiled

