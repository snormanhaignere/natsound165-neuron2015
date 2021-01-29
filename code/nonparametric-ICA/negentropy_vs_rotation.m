function negentropy_vs_rotation(W,bounds)

% negentropy_vs_rotation(W,bounds)
% 
% Plots summed negentropy for all pairs of rows from the matrix W, as a
% function of their "rotation" for those two rows (by multiplying the
% values in those rows by a [2 x 2] rotation matrix).
% 
% For uncorrelated variables, summed negentropy provides a measure
% of statistical independence. 
% 
% Entropy is estimated using a script from Rudy Moddemeijer.
% See http://www.cs.rug.nl/~rudy/matlab/
% 
% Example:
% W = gamrnd(0.5,1/0.5,[3,10000]);
% negentropy_vs_rotation(W);

% entropy of a gaussian with unit variance
gaussEntropy = log(sqrt(2*pi*exp(1)));  

% rotation angles
resolution = 61;
th = linspace(-pi/4,pi/4,resolution);

% initialize variables
n = size(W,1);
pairs = flipud(combnk(1:n,2));
h_pairs = nan(length(th), size(pairs,1));
pair_labels = cell(1,size(pairs,1));
handles = nan(1,size(pairs,1));

% figure
figure;
set(gca,'FontSize',14);
colors = colormap(['jet(' num2str(size(pairs,1)) ')']);
hold on;
for i = 1:size(pairs,1)
    for j = 1:length(th)
        rotMat = [cos(th(j)), -sin(th(j)); sin(th(j)), cos(th(j))];
        Vrot = rotMat*W(pairs(i,:),:);
        x = gaussEntropy - [entropy(Vrot(1,:)), entropy(Vrot(2,:))];
        h_pairs(j,i) = mean(x);
    end
    pair_labels{i} = [num2str(pairs(i,1)) '-' num2str(pairs(i,2))];
    handles(i) = plot(th/pi,h_pairs(:,i),'LineWidth',2,'Color',colors(i,:));
end

% axis labels
xlabel('Rotation (Pi Radians)');ylabel('Negentropy');

% x-axis range
xlim([-0.25 0.25]);

% y-axis range
if nargin > 1
    ylim(bounds);
end

% legend
legend(handles, pair_labels,'Location','NorthEastOutside');

% y-axis line
yL = ylim;
if ~ishold
    hold on;
    plot([0 0], yL, 'k--', 'LineWidth',2);
    hold off;
else
    plot([0 0], yL, 'k--', 'LineWidth',2);
end

box off;
