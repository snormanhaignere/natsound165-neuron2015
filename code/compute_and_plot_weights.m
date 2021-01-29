% Shows how to compute the raw weights using the voxel data and the component response profiles
% Paper plots a measure of significance rather than raw weights
% see plot_weight_significances

repo_directory = fileparts(fileparts(which('plot_weights.m')));

% load voxel responses from all subjects stored as a set of 2D grids
% here, using responses smoothed with a 5mm FWHM kernel
% see plot_voxel_data
load([repo_directory '/data/voxel_responses_5mm.mat'], 'G');

% load response profiles, see plot_response_profiles
load([repo_directory '/data/components.mat'], 'R');

%% Compute the weights by projecting onto component response profiles

W = G;
for hemi = 1:2
    
    % average across repetitions
    G.grid_data{hemi} = nanmean(G.grid_data{hemi}, 5);
    
    % convert to matrix
    % start off as x-pos x ypos x subject x sound
    % conver to sound x (unwrapped: x-pos, ypos, subject)
    D = permute(G.grid_data{hemi}, [4, 1, 2, 3]);
    shape = size(D);
    D = reshape(D, shape(1), prod(shape(2:end)));
    
    % project onto components
    weights = pinv(R) * D;
    
    % shape back to
    % component x x-pos x y-pos x subject
    weights = reshape(weights, [n_components, shape(2:end)]);   
    
    % average across subjects
    weights = nanmean(weights, 4);
    
    % format as x-pos x y-pos x component
    W.grid_data{hemi} = permute(weights, [2, 3, 1]);
    
end

%% Plot weights on grid

hemi = 1;
comp = 1;
figh = figure;
imagesc(W.grid_data{hemi}(:,:,comp));
title(sprintf('Comp %d', comp));

%% Pretty plot by interpolating to surface

% add freesurfer matlab code
addpath([repo_directory '/code/fs'])

% convert to FsAverage format
% vertex x hemi x component
Wsurf = grid2surface(W);

% plot
hemi = 1;
component = 5;
hemis = {'rh', 'lh'};
plot_fsaverage(Wsurf(:,hemi,component), hemis{hemi}, 'parula');