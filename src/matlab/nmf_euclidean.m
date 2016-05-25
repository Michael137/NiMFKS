function [Y, cost] = nmf_euclidean(V, W, varargin)

if nargin > 2
    nmf_params = varargin{1};
    L = nmf_params.Iterations;
    convergence = nmf_params.Convergence_criteria;
    r = nmf_params.Repition_restriction;
    p = nmf_params.Polyphony_restriction;
    c = nmf_params.Continuity_enhancement;
    pattern = nmf_params.Diagonal_pattern;
    endtime = nmf_params.Modification_application;
elseif nargin == 2
    L = 10;
    convergence = 0;
    r = 3;
    p = 10;
    c = 3;
    pattern = 'Diagonal';
    endtime = false;
end

cost=0;
targetDim=size(V);
sourceDim=size(W);
K=sourceDim(2);
M=targetDim(2);

H=random('unif',0, 1, K, M);

num=W'*V;
WTW = W'*W;

for l=1:L-1
    
    den=WTW*H;
    H=H.*(num./den);
    H(isnan(H))=0;
    
    if((r > 0 && ~endtime) || (r > 0 && endtime && l==L-1))
        for k=1:K
            %Updating H
            for m=1:M
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
        switch pattern
            case 'Diagonal'
                C = conv2(H, eye(c), 'same'); %Default
            case 'Reverse'
                C = conv2(P, flip(eye(c)), 'same'); %Reverse
            case 'Blur'
                C = conv2(P, flip(ones(c)), 'same'); %Blurring
            case 'Vertical'
                M = zeros(c, c); %Vertical
                M(:, floor(c/2)) = 1;
                C = conv2(P, M, 'same');
        end
        H = C;
    end
    
    if ~endtime
        den=WTW*H;
        H=H.*(num./den);
        H(isnan(H))=0;
    end
    
    cost(l)=norm(V-W*H, 'fro'); %Frobenius norm of a matrix
    if(l > 5 && (cost(l) > cost(l-1) || abs(((cost(l)-cost(l-1)))/max(cost))<convergence))
        break;
    end
end

Y=H;
Y = Y./max(max(Y));
end