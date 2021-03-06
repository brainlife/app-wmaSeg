[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.188-blue.svg)](https://doi.org/10.25663/brainlife.app.188)

![alt text](wmaSeg.png)

# app-wmaSeg
Automatically segment a tractogram into major white matter tracts.

### Authors
- Daniel Bullock (dnbulloc@iu.edu)

### Contributors
- Soichi Hayashi (hayashis@iu.edu)
- Franco Pestilli (franpest@indiana.edu)

### Project Director
- Franco Pestilli (franpest@indiana.edu)

### Funding
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)
[![NIMH-T32-5T32MH103213-05](https://img.shields.io/badge/NIMH_T32-5T32MH103213--05-blue.svg)](https://projectreporter.nih.gov/project_info_description.cfm?aid=9725739)

### References 
[Avesani, P., McPherson, B., Hayashi, S. et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019).](https://doi.org/10.1038/s41597-019-0073-y)

[Bullock, D., Takemura, H., Caiafa, C. F., Kitchell, L., McPherson, B., Caron, B., & Pestilli, F. (2019). Associative white matter connecting the dorsal and ventral posterior human cortex. Brain Structure and Function, 224(8), 2631-2660.](https://doi.org/10.1007/s00429-019-01907-8)

## Running the App 

### On Brainlife.io

Visit https://doi.org/10.25663/brainlife.app.188 to run this app on the brainlife.io platform.  Requires a freesurfer input (as it makes use of the 2009 parcellation) and an input tractography.

### Running Locally (on your machine) using singularity & docker

Because this is compiled code which runs on singularity, you can download the repo and run it locally with minimal setup.  Ensure that you have singularity and freesurfer set up locally (freesurfer setup not necessary if relevant parcellation files have already been converted to nii.gz).

### Running Locally (on your machine)

Pull the wma toolkit repo:  https://github.com/DanNBullock/wma_tools

Ensure that vistasoft (https://github.com/vistalab/vistasoft)and spm (https://www.fil.ion.ucl.ac.uk/spm/software/ ; tested with spm8) are installed.

Run: https://github.com/DanNBullock/wma_tools/blob/master/wma_segMajTracks_BL_v2.m , but take care to ensure that the addpath-genpath statements are relevant to your local setup.

Utilize a config.json setup that is analagous to the one contained within this repo, listed as a sample.

### Sample Datasets

Visit brainlife.io and explore the following data sets to find viable freesurfer and tractography inputs:

03D: https://brainlife.io/pub/5a0f0fad2c214c9ba8624376

HCP freesurfer:  https://brainlife.io/project/5941a225f876b000210c11e5/detail
HCP tractography:  https://brainlife.io/project/5c3caea0a6747b0036dcbf9a/


## Output

The relevant output for this application is a classification structure.  The classification structure is a .mat file which contains a matlab structure (entitled classification) with two fields:  names and index.  The names field lists the names of tracts which were identified by this process as strings.  The index field is a 1 dimensional vector containing zeros for all unidentified streamlines, and integer index values corresponding to streamlines' membership in the corresponding structure of the names vector.

#### Product.json

Not relevant for this App as it does not geenrate processed data. 

### Dependencies

This App only requires [singularity](https://www.sylabs.io/singularity/) and (in some cases) Freesurfer to run. If you don't have singularity, you will need to install following dependencies.  

https://singularity.lbl.gov/docs-installation
https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall
 
