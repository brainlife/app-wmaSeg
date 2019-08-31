function main()

if ~isdeployed
    disp('adding paths');
    %addpath(genpath('/N/soft/rhel7/spm/8')) %spm needs to be loaded before vistasoft as vistasoft provides anmean that works
    addpath(genpath('/N/u/brlife/git/jsonlab'))
    addpath(genpath('/N/u/brlife/git/vistasoft'))
    addpath(genpath('/N/u/brlife/git/wma_tools'))
end

config = loadjson('config.json');
wbfg = fgRead(config.track);

classificationOut=[];
classificationOut.names=[];
classificationOut.index=zeros(length(wbfg.fibers),1);

atlasPath='aparc.a2009s+aseg.nii.gz';

tic

disp('creating priors')   
[categoryPrior] =bsc_streamlineCategoryPriors_v6(wbfg,atlasPath,2);
[~, effPrior] =bsc_streamlineGeometryPriors(wbfg);
disp('prior creation complete')

[AntPostclassificationOut]=bsc_segmentAntPostTracts_v3(wbfg,atlasPath,categoryPrior,effPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,AntPostclassificationOut);

[CCclassificationOut]=bsc_segmentCorpusCallosum_v3(wbfg,atlasPath,1,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,CCclassificationOut);

[SubCclassificationOut]=bsc_segmentSubCortical_v2(wbfg,atlasPath,categoryPrior,effPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,SubCclassificationOut);

[AslantclassificationOut]=bsc_segmentAslant(wbfg,atlasPath,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,AslantclassificationOut);

[MDLFclassificationOut]=bsc_segmentMdLF_ILF_v4(wbfg,atlasPath,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,MDLFclassificationOut);

[pArcTPCclassificationOut]=bsc_segpArcTPC(wbfg,atlasPath);
classificationOut=bsc_reconcileClassifications(classificationOut,pArcTPCclassificationOut);

[opticclassificationOut]=bsc_opticRadiationSeg_V7(wbfg,atlasPath, 0,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,opticclassificationOut);

[cerebellarclassificationOut]=bsc_segmentCerebellarTracts_v2(wbfg,atlasPath,0,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,cerebellarclassificationOut);

[VOFclassificationOut]=bsc_segmentVOF_v4(wbfg,atlasPath,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,VOFclassificationOut);

[CSTclassificationOut]=bsc_segmentCST(wbfg,atlasPath,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,CSTclassificationOut);

%do it again to compensate for something eating it earlier
[cingclassificationBool]=bsc_segmentCingulum_v3(wbfg,atlasPath,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,cingclassificationBool);

classification= wma_resortClassificationStruc(classificationOut);
toc

disp('done segmentation.. generating vis output')

mkdir('classification')
save('classification/classification.mat','classification');

fg_classified = bsc_makeFGsFromClassification_v4(classification, wbfg);
generate_productjson(fg_classified);

tractspath='classification/tracts';
mkdir(tractspath);
for it = 1:length(fg_classified)
    tract.name   = fg_classified{it}.name;
    tract.color = fg_classified{it}.colorRgb;

    fprintf('saving tract.json for %s\n', tract.name);

    %pick randomly up to 1000 fibers (pick all if there are less than 1000)
    fiber_count = min(1000, numel(fg_classified{it}.fibers));
    tract.coords = fg_classified{it}.fibers(randperm(fiber_count))';
    %tract.coords = cellfun(@(x)round(x,3), tract.coords', 'UniformOutput', false);
    savejson('', tract, 'FileName', fullfile(tractspath,sprintf('%i.json',it)), 'FloatFormat', '%.5g');

    all_tracts(it).name = fg_classified{it}.name;
    all_tracts(it).color = fg_classified{it}.colorRgb;
    all_tracts(it).filename = sprintf('%i.json',it);

    clear tract
end
savejson('', all_tracts, fullfile(tractspath, 'tracts.json'));

disp('all done');


end
