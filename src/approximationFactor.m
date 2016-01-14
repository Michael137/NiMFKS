%Used in iterative update rule for activations when minimizing the
%Kullback-Leibler Divergence
function [y] = approximationFactor(row, column, W, V, H)

num = 0;
den = 0;
% disp(row)

% for n = 1 : size(W, 1)
%     recon = W*H;
%     num = num + (W(n, row) * V(n, column)) / (recon(n, column));
% end

recon = W*H;
n = 1 : size(W, 1);
tmp = W(n, row).*V(n, column)./(recon(n, column));
num = sum(tmp);

% for n = 1 : size(W,1)
%     den = den + W(n, row);
% end

den = sum(W(:, row));

y = num / den;

end