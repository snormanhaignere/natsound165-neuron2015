data_directory = '/Users/svnh2/Desktop/projects/naturalsound-analysis/data';
input_MAT_file = [data_directory '/voxel_matrix_165x11065_centered_scans_and_subjects.mat'];
X = load(input_MAT_file);
D_original = X.v_allscans_centered_scans_and_subjects;

%%

load([data_directory '/category_regressors'], 'C');
Z = load([root_directory '/naturalsound-ecog/analysis/category-information/categorization_131_hits.mat']);
C.categorization_consistency = Z.categorization_consistency(ismember(Z.ids,C.ids))';

stim_order = stim_order_from_categories(C);

%% stimulus names and ids

load([root_directory '/naturalsound-ecog/analysis/stim_names.mat'], 'stim_names');
stim_names = strrep(stim_names,'.wav','');
x = regexp(stim_names,'(\d)*','match');
ids = str2double(cat(1,x{:}));
[~, xi] = sort(ids,'ascend');
stim_names = stim_names(xi);
ids = ids(xi);
C.stim_names = stim_names;

%%

ica = load('/Users/svnh2/Desktop/projects/naturalsound-analysis/analyses/ICA_best_solution_reformatted', 'R', 'W', 'component_names');


%%

D = D_original(stim_order, :, :);
R = ica.R(stim_order, :);
W = ica.W;
category_labels = C.category_labels(C.category_assignments(stim_order))';
component_names = ica.component_names';
stim_names = C.stim_names(stim_order);
save([data_directory '/simple_data_matrix_Neuron2015.mat'], 'D', 'R', 'W', 'category_labels', 'component_names', 'stim_names');
save('/Users/svnh2/Desktop/projects/pyrsa/demos/165soundData/simple_data_matrix_Neuron2015.mat', 'D', 'R', 'W', 'category_labels', 'component_names', 'stim_names');

%%

any(any(isnan(nanmean(D))))