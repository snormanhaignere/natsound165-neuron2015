% Plots the significance maps shown in Fig 2B

repo_directory = fileparts(fileparts(which('plot_weight_significances.m')));

% add matlab freesurfer code
addpath(genpath([repo_directory '/code/fs']));

subj = 'group'; % either 'group' or 's1', 's2', ... 's10'
component = 1;
hemi = 'rh';
n_components = 6;

% read in surface MGZ file, see Freesurfer for formatting details
surface_file = [...
    repo_directory '/data/component-weight-significances/' subj ...
    '/' hemi '.comp' num2str(component) '.mgz'];
weights = MRIread(surface_file);

% plot the weights
plot_fsaverage(weights.vol(:), hemi, 'parula');
