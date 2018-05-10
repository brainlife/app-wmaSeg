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
%cm = parula(length(tracts));
cm = distinguishable_colors(length(tracts));
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

fibercounts = zeros(1, length(fg_classified));
possible_error = 0;
for i = 1:length(fg_classified)
    fibercounts(i) = length(fg_classified(i).fibers);
    tract_info{i,1} = fg_classified(i).name;
    tract_info{i,2} = length(fg_classified(i).fibers);
    if length(fg_classified(i).fibers) < 20
        possible_error=1;
    end
end

T = cell2table(tract_info);
T.Properties.VariableNames = {'Tracts', 'FiberCount'};

writetable(T,'output_fibercounts.txt')

boxplot = make_plotly_data(fibercounts, 'Fiber Counts', 'Number of Fibers');
product = {boxplot};
if possible_error == 1
    message = struct;
    message.type = 'error';
    message.msg = 'ERROR: Some tracts have less than 20 streamlines. Check quality of data!';
    product = {boxplot, message};
end
savejson('brainlife', product, 'product.json');

end

%% make plotly plot data
function out = make_plotly_data(values, plotTitle, axisTitle)

out = struct;

out.data = struct;
out.layout = struct;
out.type = 'plotly';

out.data.x = values;
out.data.type = 'box';
out.data.name = axisTitle;
out.data = {out.data};

out.layout.title = plotTitle;

end