function [r_match, Y_match, matching_index, r_original] = greedy_match(X, Y)

% match Y to X using greedy algorithm

r_original = corr(Y, X);

matching_index = nan(1, size(X,2));

available = 1:size(Y,2);

[~,xi] = sort(r_original(:), 'descend');

for i = 1:length(xi)
    
    [b,a] = ind2sub(size(r_original), xi(i));
    
    if any(available==b) && isnan(matching_index(a))
        matching_index(a) = b;
        available = available(available~=b);
    end
    
    if isempty(available)
        break;
    end
    
end

Y_match = nan(size(Y,1), size(X,2));
for i = 1:size(X,2)
    if ~isnan(matching_index(i))
        Y_match(:,i) = Y(:,matching_index(i));
    end
end

r_match = corr(Y_match, X);