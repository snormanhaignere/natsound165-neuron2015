% Plots maps showing the voxel responses to each sound

repo_directory = fileparts(fileparts(which('plot_voxel_data.m')));

% load voxel responses from all subjects stored as a set of 2D grids
% shows responses smoothed with a 3mm FWHM kernel
load([repo_directory '/data/all_voxel_responses_3mm.mat'], 'G');

% plot map for one subject, sound, repetition and hemisphere
subj = 1;
sound = 1;
rep = 1;
hemi = 1; % 1 = rh, 2 = lh
figure;
X = G.grid_data{hemi}(:,:,subj, sound, rep);
imagesc(X, quantile(X(:), [0.025 0.975]));
title(strrep(stim_names(sound), '_', ' '));

%% Create a prettier plot by interpolating to surface

% matlab freesurfer code
addpath([repo_directory '/code/fs']);

% just data from one subject and repetition to avoid
% creating a huge matrix
X = G;
for hemi = 1:2
    X.grid_data{hemi} = squeeze(X.grid_data{hemi}(:,:,subj,:,rep));
end

% interpolate to surface
S = grid2surface(X);

% pretty plot on surface
hemis = {'rh', 'lh'};
plot_fsaverage(S(:,hemi,sound), hemis{hemi}, 'parula');