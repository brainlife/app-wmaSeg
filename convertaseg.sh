#!/bin/bash
fsurfer=`jq -r '.freesurfer' config.json`
mri_convert $fsurfer/mri/aparc+aseg.mgz aparc+aseg.nii.gz
mri_convert $fsurfer/mri/aparc.a2009s+aseg.mgz aparc.a2009s+aseg.nii.gz
