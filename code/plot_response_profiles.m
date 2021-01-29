% Plots the six response profiles shown in Figure 2D

repo_directory = fileparts(fileparts(which('plot_response_profiles.m')));

% choose your component
component = 6;

% Load response profiles, stimulus names, and category labels
load([repo_directory '/data/components.mat'], 'R', 'stim_names', 'category_labels', 'categories');
n_components = size(R,2);
n_stimuli = size(R,1);
assert(n_stimuli == length(stim_names));
assert(n_stimuli == length(category_labels));

% colors used to plot responses to each category
category_colors = [...
    0.0549    0.3294    0.2353
    0.4039    0.7059    0.5686
    0.3529    0.1804    0.5137
    0.6157    0.1569    0.0510
    0.5961    0.3765    0.8157
    0.9059    0.3451    0.4510
    0.9216    0.9216    0.2863
    0.8706    0.4902         0
    0.0431    0.5176    0.7804
    0.0784    0.1686    0.5490
    0.3922    0.3922    0.3922
    ];

% plot
figh = figure;
hold on;
[~, stim_order] = sort(R(:,component), 'descend');
for j = 1:n_stimuli
    category_index = ismember(categories, category_labels(stim_order(j)));
    h = bar(...
        j, 100*R(stim_order(j), component),'FaceColor', category_colors(category_index,:),...
        'LineWidth',1,'EdgeColor','none');
end
set(gca, 'XTick', []);
xlabel('Sounds'); ylabel('Response');
title(sprintf('Comp %d', component));
