% Author: Dr. Elio Quinton

function [ W, H, deleted ] = SA_B_NMF(V, W, lambda, varargin )
%SENMF Summary of this function goes here
%   Detailed explanation goes here
if nargin > 2
    nmf_params = varargin{1};
    iterations = nmf_params.Iterations;
    lambda = nmf_params.Lambda;
elseif nargin == 2
    iterations = 500;
    lambda = 5;
end

waitbarHandle = waitbar(0, 'Starting sparse NMF synthesis...');

targetDim=size(V);
sourceDim=size(W);
K=sourceDim(2);
M=targetDim(2);
H=random('unif',0, 1, K, M);

deleted = [];
H = 0.01 * ones(size(H));% + (0.01 * rand(size(H)));
cost = get_cost(V, W, H, lambda); % Function get_cost defined at the end of this file.

converged = 0;
convergence_threshold = 50; % Note that this is a threshold on the derivative of the cost, i.e. how much it decays at each iteration. This value might not be ideal for our use case.

myeps = 10e-3; % A bigger eps here helps pruning out unused components
V = V + myeps; % Note that V here is the `target' audio magnitude spectrogram

% num_h_iter = 1;
err = 0.0001;
% max_iter = 1000;
max_iter = iterations;



iter = 0;
omit = 0;

while ~converged && iter < max_iter
    
    waitbar(iter/(iterations-1), waitbarHandle, ['Computing approximation...Iteration: ', num2str(iter), '/', num2str(iterations-1)])
    iter = iter + 1;
    %% sparse NMF decomposition
    if iter > 0
        
        % Update H.
        R = W*H+eps;
        RR = 1./R;
        RRR = RR.^2;
        RRRR = sqrt(R);
        
        pen = lambda./(sqrt(H + eps)); 
        
        H = H .* (((W' * (V .* RRR.* RRRR)) ./ ((W' * (RR .* RRRR) + pen))).^(1/3));
        
        
        %Update W: REMOVE THIS FOR OUR USE CASE
%         nn = sum(sqrt(H'));
%         NN = lambda * repmat(nn,size(V,1),1);
%         NNW = NN.*W;
% 
%         R = W*H+eps;
%         RR = 1./R;
%         RRR = RR.^2;
%         RRRR = sqrt(R);
%         W = W .* ( ((V .* RRR.* RRRR)*H') ./ ( ((RR .* RRRR)*H') + NNW + eps)).^(1/3);
        % Update W: stop deleting here

        
    else
        % Non-sparse first iteration. Not sure it is necessary
        % in our particular use case. We might want to get rid of
        % it later, but it should not harm anyway.
        R = W*H;
        RR = 1./R;
        RRR = RR.^2;
        RRRR = sqrt(R);
        H = H .* (((W' * (V .* RRR.* RRRR)) ./ (W' * (RR .* RRRR) + eps)).^(1/3));
        
        %Update W: REMOVE THIS FOR OUR USE CASE
%         R = W*H + myeps;
%         RR = 1./R;
%         RRR = RR.^2;
%         RRRR = sqrt(R);
%         W = W .* ((((V .* RRR.* RRRR)*H') ./ (((RR .* RRRR)*H') + eps)).^(1/3));
        % Update W: stop deleting here
    end
    
    %% normalise and prune templates if their total activation reaches 0.
    todel = [];
    shifts = [];
    for i = 1:size(W,2)
%        nn =  norm(W(:,i)); % W is not being updated so this is of no use
       nn =  sum(H(i,:)); % Check if norm of rows of H get to zero instead. 
       if nn == 0
           todel = [todel i];
%            disp(['Deleting  ' int2str(length(todel))]); % This is printing a message everytime templates are deleted
       else
            nn =  norm(W(:,i)); % Still normalise against norm of Templates to avoid division by zero.
            W(:,i) = W(:,i) / nn; 
            H(i,:) = H(i,:) * nn;
       end
    end

    if( length(deleted) == 0 )
        deleted = [deleted todel];
    else
        shifts = zeros(1, length(todel));
        for i = 1:length(shifts)
            shifts(i) = length( deleted( deleted >= todel(i) ) );
        end
        deleted = [deleted todel+shifts];
    end
    W(:,todel) = [];
    H(todel,:) = [];
    
    %% get the cost and monitor convergence
    if mod(iter, 5) == 0

        new_cost = get_cost(V, W, H, lambda);
    
        if omit == 0 && cost - new_cost < cost * err & iter > convergence_threshold
           converged = 0; 
      %     
        end
        
        cost = new_cost;
        omit = 0;
        
%         disp([int2str(iter)  '    ' num2str(cost)]); % this prints the cost function at each iteration. Could be commented out (printing is slow in matlab)
    end
    
end

close(waitbarHandle);
end



function cost = get_cost(V, W, H, lambda)
R = W*H+eps;
hcost = sum(sum( (sqrt(V) - sqrt(R).^2 )./sqrt(R) ));
nn = 2 * lambda * sum(sum(sqrt(H)));
cost = hcost + nn;

end

