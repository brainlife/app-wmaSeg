#!/bin/bash


fsurfer=`jq -r '.freesurfer' config.json`

source $FREESURFER_HOME/SetUpFreeSurfer.sh


mri_convert $fsurfer/mri/aparc.a2009s+aseg.mgz  freesurfer/mri/aparc.a2009s+aseg.nii.gz