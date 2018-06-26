function [] = main()

if ~isdeployed
    disp('loading paths')
    addpath(genpath('/N/u/brlife/git/encode'))
    addpath(genpath('/N/u/brlife/git/vistasoft'))
    addpath(genpath('/N/u/brlife/git/jsonlab'))
    addpath(genpath('/N/soft/mason/SPM/spm8'))

    addpath(genpath('/N/u/kitchell/Karst/Applications/mba'))
    addpath(genpath('/N/u/brlife/git/wma'))
end

% load my own config.json
config = loadjson('config.json')

% magic directive to load sptensor structure (following is not a comment!)
%#function sptensor

%not the freesurfer input directory, but freesurfer directory locally created that contains aparc+aseg.nii.gz
classification = wma_wrapperDev(config.wbfg,'freesurfer');

if isfield(config,'tracts') && strlength(config.tracts) > 0
   disp(['limiting tracts to ' config.tracts])
   classification = bsc_extractTractsByName(classification,strsplit(config.tracts));
end

disp(['running classification', classification])
fg_classified = bsc_makeFGsFromClassification(classification, config.wbfg);

save('output.mat', 'fg_classified', 'classification');
tracts = fg_classified;

mkdir('tracts');

% Make colors for the tracts
%cm = parula(length(tracts));
%cm = distinguishable_colors(length(tracts));
for it = 1:length(tracts)
   tract.name   = strrep(tracts(it).name, '_', ' ');
   all_tracts(it).name = strrep(tracts(it).name, '_', ' ');
   all_tracts(it).color = tracts(it).colorRgb;
   tract.color = tracts(it).colorRgb;

   %tract.coords = tracts(it).fibers;
   %pick randomly up to 1000 fibers (pick all if there are less than 1000)
   fiber_count = min(1000, numel(tracts(it).fibers));
   tract.coords = tracts(it).fibers(randperm(fiber_count)); 
   
   savejson('', tract, fullfile('tracts',sprintf('%i.json',it)));
   all_tracts(it).filename = sprintf('%i.json',it);
   clear tract
end

savejson('', all_tracts, fullfile('tracts/tracts.json'));

tract_info = cell(length(tracts), 2);
fibercounts = zeros(1, length(tracts));
possible_error = 0;
num_left_tracts = 0;
num_right_tracts = 0;

for i = 1 : length(tracts)
    name = tracts(i).name;
    num_fibers = length(tracts(i).fibers);
    
    fibercounts(i) = num_fibers;
    tract_info{i,1} = name;
    tract_info{i,2} = num_fibers;
    
    if startsWith(name, 'Right ') || endsWith(name, ' R')
        num_right_tracts = num_right_tracts + 1;
    else
        num_left_tracts = num_left_tracts + 1;
    end
    
    if num_fibers < 20
        possible_error = 1;
    end
end

left_tract_xs = cell(1, num_left_tracts);
right_tract_xs = cell(1, num_right_tracts);

left_tract_ys = zeros([1, num_left_tracts]);
right_tract_ys = zeros([1, num_right_tracts]);

left_tract_idx = 1;
right_tract_idx = 1;

for i = 1 : length(tracts)
    name = tracts(i).name;
    num_fibers = length(tracts(i).fibers);
    basename = name;
    
    if startsWith(basename, 'Right ')
        basename = extractAfter(basename, 6);
    end
    if endsWith(basename, ' R')
        basename = extractBefore(basename, length(basename) - 1);
    end
    
    if startsWith(basename, 'Left ')
        basename = extractAfter(basename, 5);
    end
    if endsWith(basename, ' L')
        basename = extractBefore(basename, length(basename) - 1);
    end
    
    if startsWith(name, 'Right ') || endsWith(name, ' R')
        right_tract_xs{right_tract_idx} = basename;
        right_tract_ys(right_tract_idx) = num_fibers;
        right_tract_idx = right_tract_idx + 1;
    else
        left_tract_xs{left_tract_idx} = basename;
        left_tract_ys(left_tract_idx) = num_fibers;
        left_tract_idx = left_tract_idx + 1;
    end
end

T = cell2table(tract_info);
T.Properties.VariableNames = {'Tracts', 'FiberCount'};
writetable(T, 'output_fibercounts.txt');

%number of fibers graph
barplot = struct;
barplot.type = 'plotly';
barplot.name = 'Number of Fibers';

bar1 = struct;
bar1.x = left_tract_xs;
bar1.y = left_tract_ys;
bar1.type = 'bar';
bar1.name = 'Left Tracts';
bar1.marker = struct;
bar1.marker.color = 'rgb(49,130,189)';

bar2 = struct;
bar2.x = right_tract_xs;
bar2.y = right_tract_ys;
bar2.type = 'bar';
bar2.name = 'Right Tracts';
bar2.marker = struct;
bar2.marker.color = 'rgb(204, 204, 204)';

barplot.data = {bar1, bar2};

barlayout = struct;
barlayout.xaxis = struct;
barlayout.xaxis.tickfont = struct;
barlayout.xaxis.tickfont.size = 8;
barlayout.barmode = 'group';
barplot.layout = barlayout;

% fiber count graph
boxplot = struct;
boxplot.type = 'plotly';
boxplot.name = 'Fiber Counts';

box1 = struct;
box1.x = fibercounts;
box1.type = 'box';
box1.name = 'Fibers';

boxplot.data = {box1};

% output product.json
product = {barplot, boxplot};
if possible_error == 1
    message = struct;
    message.type = 'error';
    message.msg = 'ERROR: Some tracts have less than 20 streamlines. Check quality of data!';
    product = {barplot, boxplot, message};
end
savejson('brainlife', product, 'product.json');

end

