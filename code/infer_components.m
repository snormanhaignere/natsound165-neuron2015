% Shows how to infer components using the non-parametric algorithm

repo_directory = fileparts(fileparts(which('infer_components.m')));
addpath([repo_directory '/code/nonparametric-ICA']);

%% Load data matrix

% this is the sound x voxel x repetition data matrix
% used to compute the decomposition
% see paper for details
load([repo_directory '/data/data_matrix.mat'], 'D');

% average across reps
D = nanmean(D,3);

%% Infer components perform analysis

n_components = 6;
n_random_initializations = 10;
plot_figures = true;
random_seed = 1;
[R, W] = nonparametric_ica(D, n_components, n_random_initializations, plot_figures, random_seed);

%% Compare with those from the paper

neuron = load([repo_directory '/data/components.mat'], 'R', 'stim_names', 'category_labels', 'categories');

% re-order to best match those from the paper
[~, ~, matching_index, ~] = greedy_match(neuron.R, R);
R = R(:,matching_index);
W = W(matching_index, :);

% compare the inferred components with those from the paper
% correlations should be very close to 1
diag(corr(R, neuron.R))