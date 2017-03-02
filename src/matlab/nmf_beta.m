function [ Y, cost ] = nmf_beta( V, W, varargin )

if nargin > 2
    nmf_params = varargin{1};
    iterations = nmf_params.Iterations;
    lambda = nmf_params.Lambda;
    beta = nmf_params.Beta % 1: KL Divergence; 2: Euclidean
end

cost=0;
K=size(W, 2);
M=size(V, 2);

H=random('unif',0, 1, K, M);

V = V+1E-6;
W = W+1E-6;

for l=1:L-1    
    recon = W*H;
    num = H.*(W'*(((recon).^(beta-2)).*V));
    den = W'*((recon).^(beta-1));
    H = num./den;    
end

fprintf('Iterations: %i/%i\n', l, L);
fprintf('Convergence Criteria: %i\n', convergence*100);
fprintf('Repitition: %i\n', r);
fprintf('Polyphony: %i\n', p);
fprintf('Continuity: %i\n', c);

Y=H;
Y = Y./max(max(Y)); %Normalize activations

end
