function rotMat = random_rotation_matrix(N)
% function rotMat = random_rotation_matrix(n)
% 
% Returns a random N x N rotation matrix.

pairs = flipud(combnk(1:N,2));
n_pairs = size(pairs,1);
th = rand([1 n_pairs])*2*pi;
order = randperm(n_pairs);
rotMat = eye(N);
for i = 1:n_pairs
    x = eye(N);
    pair = pairs(order(i),:);
    x(pair,pair) = [cos(th(i)), -sin(th(i)); sin(th(i)), cos(th(i))];
    rotMat = x*rotMat;
end