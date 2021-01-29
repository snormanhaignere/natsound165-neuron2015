function [R, W, negentropy_alliterations, W_alliterations] = ...
    nonparametric_ica(X, K, N_RANDOM_INITS, PLOT_FIGURES, RAND_SEED)

% [R, W, negentropy_alliterations, W_alliterations] = ...
%     nonparametric_ica(X, K, N_RANDOM_INITS, PLOT_FIGURES, RAND_SEED)
% 
% Performs the nonparametric decomposition described in:
% 
% Norman-Haignere SV, Kanwisher NG, McDermott JH (2015). Distinct cortical pathways for music and
% speech revealed by hypothesis-free voxel decomposition. Neuron.
% 
% The algorithm iteratively rotates the top K principal components of the data matrix, X, to
% maximize a measure of non-Gaussianity ('negentropy'). This procedure is closely related to
% standard algorithms for independent component analysis, but unlike standard algorithms does not
% depend on assumptions about the type of non-Gaussian distribution being identified. Because
% negentropy is estimated with a histogram, the algorithm tends to work well with a large number of
% data points (~10,000). The run-time of the algorithm increases substantially as the number of
% components is increased because the optimization is performed via a brute-force search over all
% pairs of components (run-time is thus proportional nchoosek(K,2) where K is the number of
% components).
% 
% Most of the computations are performed by the helper function maximize_negentropy_via_rotation. 
% 
% Entropy is estimated using a script from Rudy Moddemeijer.
% See http://www.cs.rug.nl/~rudy/matlab/
% 
% For additional information see:
% Hyvärinen and Oja, 2000. Independent Component Analysis:
% Algorithms and Applications. http://www.cs.helsinki.fi/u/ahyvarin/papers/NN00new.pdf.
% 
% -- Required Input Arguments --
% 
% X: [M x N] data matrix containing N measurements/data-points and M features. In the Neuron paper,
% N corresponded to the the number of voxels (11,065 across all 10 subjects) and M to the number of
% sounds tested (165).
% 
% K: The number of components to be inferred. Six components were used to model the voxel responses
% measured in the Neuron paper. 
% 
% -- Optional Input Arguments --
% 
% N_RANDOM_INITS: A single run of the algorithm is only gauranteed to find a local optima. But the
% algorithm can be run many times from random starting points (random rotations of the principal
% components), and the best answer across the different random initializations will be returned
% (default: 10).
%
% PLOT_FIGURES: Whether or not to plot figures potentially useful measures of negentropy (default: false).
% 
% RAND_SEED: Seed to initialize the random stream with. Fixing the random seed can be useful so that
% the algorithm always returns the same answer for a given input (default: 1).
% 
% -- Output --
% 
% R: [M x K] response profile matrix containing the response of each of the K components to each of
% the M stimulus features. This matrix was use to investigate the functional properties of the
% components described in the neuron paper.
% 
% W: [K x N] weight matrix containing the weight of each of the K components to each of the N
% measurements/data-points. This matrix contained the voxel weights for the componenst described in
% the Neuron paper, and was used to investigate their anatomical properties.
% 
% -- Example Use with Synthetic Data --
% 
% % dimensionality of data and components
% M = 100; % number of features (e.g. sounds)
% N = 10000; % number of measures (e.g. fMRI voxels)
% K = 3; % number of components
% 
% % create the data matrix
% R_true = rand(M,K); % true response profile
% W_true = gamrnd(1,1,[K,N]); % true weight matrix, sampled from a gamma distribution
% X = R_true*W_true + 0.1*randn(M,N); % the observed, noisy data matrix
% 
% % decomposition analysis
% N_RANDOM_INITS = 10;
% PLOT_FIGURES = 1;
% RAND_SEED = 1;
% [R_inferred, W_inferred] = nonparametric_ica(X, K, N_RANDOM_INITS, PLOT_FIGURES, RAND_SEED);
% 
% % compare the inferred and true response profiles and weight matrices
% corr(R_true,R_inferred)
% corr(W_true',W_inferred')

if nargin < 3
    N_RANDOM_INITS = 10;
end

if nargin < 4
    PLOT_FIGURES = false;
end

if nargin < 5
    RAND_SEED = 1;
end

% matrix dimensions
[M,N] = size(X);

% demean rows of the data matrix
X_zero_mean_rows = nan(size(X));
for i = 1:M
    X_zero_mean_rows(i,:) = X(i,:) - mean(X(i,:));
end

% PCA decomposition
[U,S,V] = svd(X_zero_mean_rows,'econ');
Rpca = U(:,1:K) * S(1:K,1:K);
Wpca = V(:,1:K)';

% rotate PCA component weights to maximize negentropy
[W, W_alliterations, negentropy_alliterations] = maximize_negentropy_via_rotation(Wpca, N_RANDOM_INITS, RAND_SEED, PLOT_FIGURES);

% estimate the response profiles from data matrix and inferred weights
R = X_zero_mean_rows*pinv(W);

% normalize response profiles to have unit RMS
for i = 1:K
    R(:,i) = R(:,i)/sqrt(mean(R(:,i).^2));
end

% re-estimate weights with non-demeaned data
try
    W = pinv(R)*X;
catch
    keyboard
end

% orient so that average weights are positive
R = R .* repmat(sign(mean(W,2))',M,1);
W = W .* repmat(sign(mean(W,2)),1,N);