function [] = main()

if ~isdeployed
    switch getenv('ENV')
        case 'IUHPC'
            disp('loading paths for IUHPC')
            addpath(genpath('/N/u/brlife/git/encode'))
            addpath(genpath('/N/u/brlife/git/vistasoft'))
            addpath(genpath('/N/u/brlife/git/jsonlab'))
            %addpath(genpath('/N/u/brlife/git/wma'))
            addpath(genpath('/N/u/kitchell/Karst/Applications/mba'))
            addpath(genpath('/N/soft/mason/SPM/spm8'))
            addpath(genpath('/N/dc2/projects/lifebid/code/kitchell/wma'))
            
        case 'VM'
            disp('loading paths for Jetstream VM')
            addpath(genpath('/usr/local/encode'))
            addpath(genpath('/usr/local/vistasoft'))
            addpath(genpath('/usr/local/jsonlab'))
            addpath(genpath('/usr/local/wma'))
    end
end

% load my own config.json
config = loadjson('config.json');

% Load an FE strcuture created by the sca-service-life

%#function sptensor
%load(config.fe);

fsdir = 'freesurfer';
% run wma

classification = wma_wrapperDev(config.wbfg,fsdir);

% make fg_classified

fg_classified = bsc_makeFGsFromClassification(classification, config.wbfg);

save('output.mat','fg_classified', 'classification');

tracts = fg2Array(fg_classified);

mkdir('tracts');

% Make colors for the tracts
cm = parula(length(tracts));
for it = 1:length(tracts)
   tract.name   = strrep(tracts(it).name, '_', ' ');
   all_tracts(it).name = strrep(tracts(it).name, '_', ' ');
   all_tracts(it).color = cm(it,:);
   tract.color  = cm(it,:);

   %tract.coords = tracts(it).fibers;
   %pick randomly up to 1000 fibers (pick all if there are less than 1000)
   fiber_count = min(1000, numel(tracts(it).fibers));
   tract.coords = tracts(it).fibers(randperm(fiber_count)); 
   
   savejson('', tract, fullfile('tracts',sprintf('%i.json',it)));
   all_tracts(it).filename = sprintf('%i.json',it);
   clear tract
end

savejson('', all_tracts, fullfile('tracts/tracts.json'));


% saving text file with number of fibers per tracts
tract_info = cell(length(fg_classified), 2);

possible_error = 0;
for i = 1:length(fg_classified)
    tract_info{i,1} = fg_classified(i).name;
    tract_info{i,2} = length(fg_classified(i).fibers);
    if length(fg_classified(i).fibers) < 20
        possible_error=1;
    end
end

if possible_error==1
    results.quality_check = 'ERROR: Some tracts have less than 20 streamlines. Check quality of data!';
else
    results.quality_check = 'Data should be fine, but please view to double check';
end
savejson('', results, 'product.json');


T = cell2table(tract_info);
T.Properties.VariableNames = {'Tracts', 'FiberCount'};

writetable(T,'output_fibercounts.txt')

end



