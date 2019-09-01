function main()

if ~isdeployed
    disp('adding paths');
    addpath(genpath('/N/u/brlife/git/jsonlab'))
    addpath(genpath('/N/u/hayashis/git/vistasoft'))
    addpath(genpath('/N/u/hayashis/git/wma_tools'))
end

config = loadjson('config.json');
wbfg = fgRead(config.track);

classificationOut=[];
classificationOut.names=[];
classificationOut.index=zeros(length(wbfg.fibers),1);

atlas=niftiRead('aparc.a2009s+aseg.nii.gz');

tic

disp('creating priors')   
[categoryPrior] =bsc_streamlineCategoryPriors_v6(wbfg,atlas,2);
[~, effPrior] =bsc_streamlineGeometryPriors(wbfg);
disp('prior creation complete')

disp('1) bsc_segmentAntPostTracts_v3--------------------------------------------------------------');
[AntPostclassificationOut]=bsc_segmentAntPostTracts_v3(wbfg,atlas,categoryPrior,effPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,AntPostclassificationOut);

disp('2) bsc_segmentCorpusCallosum_v3--------------------------------------------------------------');
[CCclassificationOut]=bsc_segmentCorpusCallosum_v3(wbfg,atlas,1,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,CCclassificationOut);

disp('3) bsc_segmentSubCortical_v2--------------------------------------------------------------');
[SubCclassificationOut]=bsc_segmentSubCortical_v2(wbfg,atlas,categoryPrior,effPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,SubCclassificationOut);

disp('4) bsc_segmentAslant--------------------------------------------------------------');
[AslantclassificationOut]=bsc_segmentAslant(wbfg,atlas,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,AslantclassificationOut);

disp('5) bsc_segmentMdLF_ILF_v4--------------------------------------------------------------');
[MDLFclassificationOut]=bsc_segmentMdLF_ILF_v4(wbfg,atlas,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,MDLFclassificationOut);

disp('6) bsc_segpArcTPC--------------------------------------------------------------');
[pArcTPCclassificationOut]=bsc_segpArcTPC(wbfg,atlas);
classificationOut=bsc_reconcileClassifications(classificationOut,pArcTPCclassificationOut);

disp('7) bsc_opticRadiationSeg_V7--------------------------------------------------------------');
[opticclassificationOut]=bsc_opticRadiationSeg_V7(wbfg,atlas, 0,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,opticclassificationOut);

disp('8) bsc_segmentCerebellarTracts_v2--------------------------------------------------------------');
[cerebellarclassificationOut]=bsc_segmentCerebellarTracts_v2(wbfg,atlas,0,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,cerebellarclassificationOut);

disp('9) bsc_segmentVOF_v4--------------------------------------------------------------');
[VOFclassificationOut]=bsc_segmentVOF_v4(wbfg,atlas,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,VOFclassificationOut);

disp('10) bsc_segmentCST--------------------------------------------------------------');
[CSTclassificationOut]=bsc_segmentCST(wbfg,atlas,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,CSTclassificationOut);

disp('11) bsc_segmentCingulum_v3 --------------------------------------------------------------');
%do it again to compensate for something eating it earlier
[cingclassificationBool]=bsc_segmentCingulum_v3(wbfg,atlas,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,cingclassificationBool);

disp('12) wma_resortClassificationStruci --------------------------------------------------------------');
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
