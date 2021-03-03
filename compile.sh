#!/bin/bash

cat > build.m <<END
addpath(genpath('.'))
mcc -m -R -nodisplay -d compiled main
exit
END

matlab -nodisplay -nosplash -r build && rm build.m



