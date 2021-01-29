function surf = grid2surface(G)

% Interpolated from a gridded file to the surface

dims = size(G.grid_data{1});

% interpolate to surface
nsurfpts = 163842; % assumes fsaverage
n_hemi = 2;
surf = nan([nsurfpts, n_hemi, dims(3:end)]);
for i = 1:prod(dims(3:end))
    for q = 1:n_hemi
        surf(G.vi{q}+1,q,i) = ...
            interp2(G.grid_x{q},G.grid_y{q}, ...
            G.grid_data{q}(:,:,i), G.vras{q}(:,1), ...
            G.vras{q}(:,2), 'linear');
    end
end
