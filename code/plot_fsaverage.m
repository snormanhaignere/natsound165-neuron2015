function [color_data, patch_handle, light_handle] = ...
    plot_fsaverage(surface_values, hemi, color_map_to_plot, color_range, figh, varargin)

% function [color_data, patch_handle, light_handle] = plot_fsaverage_1D_overlay(surface_values, hemi, color_map_to_plot, color_range, figh, varargin)
% 
% Plots a surface overlay on the fsaverage template brain using the matlab function patch. 
% 
% -- Inputs --  
% 
% surface_values: vector of values, one per vertex, to plot, NaN values are not plotted
% 
% hemi: whether the left or right hemisphere is being plotted
% 
% color_map_to_plot (optional): the name of the colormap to use (default is 'parula' if not specified), can
% also be a N x 3 matrix of values to interpolate within the color range.
% 
% color_range (optional): range of values to plot, [lower_bound, upperbound] (if not specified the central 95 of the distribution of values is plotted)
% 
% figh (optional): matlab handle of the figure to plot the surface in, if unspecified a new figure
% handle is created (i.e. figh = figure)
% 
% -- Outputs --
% 
% color_data: N x 3 matrix specifying the RGB color of each vertex
% 
% patch_handle: handle to the patch object created
% 
% light_handle: handle to the light object created
% 
% -- Example: Plots significance map for music component discovered by ICA --  
% 
% hemi = 'rh';
% surf = MRIread(['/mindhive/nklab/u/svnh/fmri-analysis/test_data/' hemi '.ICA_pmap_music.mgz']);
% surface_values = surf.vol;
% colormapname = 'parula';
% plot_fsaverage_1D_overlay(surface_values, hemi, colormapname);
% 
% Modified by Sam NH on 9/3/2015
% 
% Generalized slightly on 01/26/2020

repo_directory = fileparts(fileparts(which('plot_fsaverage.m')));

% change this to match your freesurfer home directory
fsaverage_directory = [repo_directory '/data/fsaverage'];

% default colormap is parula
if nargin < 3 || isempty(color_map_to_plot)
    color_map_to_plot = 'parula';
end

% by default plots the central 95% of the distribution
if nargin < 4 || isempty(color_range)
    [Nx,x] = hist(surface_values(~isnan(surface_values)),100);
    Cx = cumsum(Nx/sum(Nx));
    [~,xi] = unique(Cx);
    x = x(xi);
    Cx = Cx(xi);
    color_range = interp1(Cx,x,[0.025 0.975]);
end

% read vertices and faces
nvertices = 163842; 
[vertices, faces] = freesurfer_read_surf([fsaverage_directory '/surf/' hemi '.inflated'], false);

% set default color data based on gyral/sulcal divisions
curv = read_curv([fsaverage_directory '/surf/' hemi '.curv']);
color_data = 0.5*ones(nvertices,3);
color_data(curv>0,:) = 0.3;

% read in a colormap
if ischar(color_map_to_plot)
    h = figure;
    cmap = colormap(color_map_to_plot);
    close(h);
else
    cmap = color_map_to_plot;
end

% interpolate surface values to colormap
surface_values_bounded = surface_values;
surface_values_bounded(surface_values_bounded < color_range(1)) = color_range(1);
surface_values_bounded(surface_values_bounded > color_range(2)) = color_range(2);
x = linspace(color_range(1),color_range(2),size(cmap,1))';
try
for i = 1:3
    color_data(~isnan(surface_values_bounded),i) = interp1(x, cmap(:,i), surface_values_bounded(~isnan(surface_values_bounded))','pchip');
end
catch
keyboard
end

% return after calculating color data without plotting
if optInputs(varargin,'noplot')
    return;
end

% create figure of specified size
if nargin < 5 || isempty(figh)
    figh = figure;
    pos = get(figh,'Position');
    set(figh, 'Position', [pos(1:2), 800 800]);
    clf(figh);
else
    clf(figh);
end

% create the patch object
patch_handle = patch('vertices', vertices, 'Faces', faces, 'FaceVertexCData', color_data,'FaceLighting','gouraud','SpecularStrength',0,'DiffuseStrength',0.7);
shading interp;

% adjust viewing angle 
switch hemi
    case {'rh'}
%         view([115 10])
        camup([0 0.5 1]);
        camva(4.532)
        campos([1.3604e+03 1.0309e+03 363.9286]);
        camtarget([0 15 -10]);
        xlim(2.2*40*[-1 1]); ylim(2.2*65*[-1 1]); zlim(2.2*55*[-1 1]);
        light_handle = camlight('right','infinite');
        set(light_handle, 'Position', [0.33 0.33 0.33]);

    case {'lh'}
%         view([-105 0]);
        camup([0 0.5 1]);
        % camzoom(2.2);
        camtarget([-10 10 -5]);
        %         campos([-1449.9 631.312 363.929]);
        campos([-1449.9*1 631.312*1.3 363.929*1]);
        camva(4);
        % campos([1.3604e3 1.0309e3 0.3639e3])
        xlim(2.2*40*[-1 1]); ylim(2.2*65*[-1 1]); zlim(2.2*55*[-1 1]);
        light_handle = camlight('left','infinite');
        set(light_handle, 'Position', [-1, 1, 0.33]);
        
    otherwise
        error('hemi should be "rh" or "lh", not %s',hemi);
end

% colorbar
colormap(color_map_to_plot);
colorbar_handle = colorbar('Location','South');
colorbar_labels_str = cell(1,5);
colorbar_labels_num = linspace(color_range(1),color_range(2),5);
for i = 1:5
    num_sig_digits = round(log10(colorbar_labels_num(i)));
    if num_sig_digits > 3 || num_sig_digits < -3
        colorbar_labels_str{i} = sprintf('%.2e',colorbar_labels_num(i));
    else
        colorbar_labels_str{i} = sprintf('%.2f',colorbar_labels_num(i));
    end
end
ca = caxis;
set(colorbar_handle, 'XTick', linspace(ca(1),ca(2),5), 'XTickLabel', colorbar_labels_str,'FontSize',20,'Position',[0.1469 0.05 0.7438 0.0312]);
