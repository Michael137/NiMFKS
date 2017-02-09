function [Y, cost] = nmf_divergence(V, W, varargin)

if nargin > 2
    nmf_params = varargin{1};
    L = nmf_params.Iterations;
    convergence = nmf_params.Convergence_criteria;
    r = nmf_params.Repition_restriction;
    p = nmf_params.Polyphony_restriction;
    c = nmf_params.Continuity_enhancement;
    rot = nmf_params.Continuity_enhancement_rot;
    pattern = nmf_params.Diagonal_pattern;
    endtime = nmf_params.Modification_application;
    rng(nmf_params.Random_seed);
elseif nargin == 2
    L = 10;
    convergence = 0;
    r = -1;
    p = -1;
    c = -1;
    pattern = 'Diagonal';
    endtime = false;
    rng('shuffle');
end

waitbarHandle = waitbar(0, 'Starting NMF synthesis...');

cost=0;
K=size(W, 2);
M=size(V, 2);

H=random('unif',0, 1, K, M);

% % Sparse NMF for finding activations
% [~, H] = SA_B_NMF(V,W,H,5);
% % Size (i.e. rows) gets squashed
% H( size( H, 1 ) + 1:K, : ) = 0;

P=zeros(K, M);
R=zeros(K, M);
C=zeros(K, M);

V = V+1E-6;
W = W+1E-6;
den = sum(W);

for l=1:L-1
    waitbar(l/(L-1), waitbarHandle, ['Computing approximation...Iteration: ', num2str(l), '/', num2str(L-1)])
    
    recon = W*H;
    for mm = 1:size(H,2)
      num = V(:,mm).*(1./recon(:,mm));
      num2 = num'*W./den;
      H(:,mm) = H(:, mm).*num2';
    end
    
    if((r > 0 && ~endtime) || (r > 0 && endtime && l==L-1))
        waitbar(l/(L-1), waitbarHandle, ['Repition Restriction...Iteration: ', num2str(l), '/', num2str(L-1)])
        for k = 1:size(H, 1)
            for m = 1:size(H, 2)
                if(m>r && (m+r)<=M && H(k,m)==max(H(k,m-r:m+r)))
                    R(k,m)=H(k,m);
                else
                    R(k,m)=H(k,m)*(1-(l+1)/L);
                end
            end
        end
        
        H = R;
    end
    
    if((p > 0 && ~endtime) || (p > 0 && endtime && l==L-1))
        waitbar(l/(L-1), waitbarHandle, ['Polyphony Restriction...Iteration: ', num2str(l), '/', num2str(L-1)])
      P = zeros(size(H));
      mask = zeros(size(H,1),1);
      for m = 1:size(H, 2)
        [~, sortedIndices] = sort(H(:, m),'descend');
        mask(sortedIndices(1:p)) = 1;
        mask(sortedIndices(p+1:end)) = (1-(l+1)/L);
        P(:,m)=H(:,m).*mask;
      end
      H = P;
    end
    
    if((c > 0 && ~endtime) || (c > 0 && endtime && l==L-1))
        waitbar(l/(L-1), waitbarHandle, ['Continuity Enhancement...Iteration: ', num2str(l), '/', num2str(L-1)])
        switch pattern
            case 'Diagonal'
                C = conv2(H, eye(c), 'same'); %Default
            case 'Reverse'
                C = conv2(H, flip(eye(c)), 'same'); %Reverse
            case 'Blur'
                C = conv2(H, flip(ones(c)), 'same'); %Blurring
            case 'Vertical'
                M = zeros(c, c); %Vertical
                M(:, floor(c/2)) = 1;
                C = conv2(P, M, 'same');
        end
        
        H = C;
    end
    
    if ~endtime
        recon = W*H;
        for mm = 1:size(H,2)
            num = V(:,mm).*(1./recon(:,mm));
            num2 = num'*W./den;
            H(:,mm) = H(:, mm).*num2';
        end
    end
    
    cost(l)=KLDivCost(V, W*H);
    if(l>3 && (abs(((cost(l)-cost(l-1)))/max(cost))<=convergence))
        break;
    end
end

fprintf('Iterations: %i/%i\n', l, L);
fprintf('Convergence Criteria: %i\n', convergence*100);
fprintf('Repitition: %i\n', r);
fprintf('Polyphony: %i\n', p);
fprintf('Continuity: %i\n', c);

Y=H;
Y = Y./max(max(Y)); %Normalize activations

close(waitbarHandle);
end