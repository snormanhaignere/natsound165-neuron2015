% Plots the largest continguous cluster in each hemisphere for each
% component

repo_directory = fileparts(fileparts(which('plot_weight_significances.m')));

% add matlab freesurfer code
addpath(genpath([repo_directory '/code/fs']));

component = 6;
hemi = 'rh';
label_file = [...
    repo_directory '/data/component-clusters-top10' ...
    '/' hemi '.comp' num2str(component) '.label'];
label = read_label_SNH(label_file);
surf = nan(163842, 1);
surf(label.vnums + 1) = 1;
plot_fsaverage(surf, hemi, 'parula', [0, 1]);