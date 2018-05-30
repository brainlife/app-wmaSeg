#!/bin/bash


fsurfer=`jq -r '.freesurfer' config.json`

source $FREESURFER_HOME/SetUpFreeSurfer.sh

mkdir -p freesurfer/mri

mri_convert $fsurfer/mri/aparc.a2009s+aseg.mgz  freesurfer/mri/aparc.a2009s+aseg.nii.gz

mri_convert $fsurfer/mri/aparc+aseg.mgz  freesurfer/mri/aparc+aseg.nii.gz
