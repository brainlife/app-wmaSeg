function [] = main()

switch getenv('ENV')
    case 'IUHPC'
        disp('loading paths for IUHPC')
        addpath(genpath('/N/u/brlife/git/encode'))
        addpath(genpath('/N/u/brlife/git/vistasoft'))
        addpath(genpath('/N/u/brlife/git/jsonlab'))
        addpath(genpath('/N/u/brlife/git/wma'))
    case 'VM'
        disp('loading paths for Jetstream VM')
        addpath(genpath('/usr/local/encode'))
        addpath(genpath('/usr/local/vistasoft'))
        addpath(genpath('/usr/local/jsonlab'))
        addpath(genpath('/usr/local/wma'))
end


% load my own config.json
config = loadjson('config.json');

% Load an FE strcuture created by the sca-service-life
load(config.fe);

% point to dt6 file
dt6 = fullfile(config.dt6,'/dti_trilin/dt6.mat')

% run wma
classification = wma_wrapper(fe, dt6, config.freesurfer);

%remove classified zero-weighted fibers
classification = wma_clearNonvalidClassifications(classification,fe);

% make fg_classified

fg_classified = bsc_makeFGsFromClassification(classification, fe);

save('output.mat','fg_classified', 'classification', '-v7.3');

tracts = fg2Array(fg_classified);

mkdir('tracts');



% Make colors for the tracts
cm = parula(length(tracts));
for it = 1:length(tracts)
   tract.name   = tracts(it).name;
   all_tracts(it).name = tracts(it).name;
   all_tracts(it).color = cm(it,:);
   tract.color  = cm(it,:);
   tract.coords = tracts(it).fibers;
   savejson('', tract, fullfile('tracts',sprintf('%i.json',it)));
   all_tracts(it).filename = sprintf('%i.json',it);
   clear tract
end

savejson('', all_tracts, fullfile('tracts/tracts.json'));

% saving text file with number of fibers per tracts
tract_info = cell(length(fg_classified), 2);

for i = 1:length(fg_classified)
    tract_info{i,1} = fg_classified(i).name;
    tract_info{i,2} = length(fg_classified(i).fibers);
end

T = cell2table(tract_info);
T.Properties.VariableNames = {'Tracts', 'FiberCount'};

writetable(T,'output_fibercounts.txt')

end



