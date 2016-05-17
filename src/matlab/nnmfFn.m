%Diagonal appears if V=W under large number of iterations without
%cost-break

function [Y, cost] = nnmfFn(V, W, L, varargin)
%L: Iterations
%V: Matrix to be factorized
%W: Source matrix
parser = inputParser;
addRequired(parser, 'V')
addRequired(parser, 'W')
addRequired(parser, 'L')
addParameter(parser, 'repititionRestricted', false)
addParameter(parser, 'continuityEnhanced', false)
addParameter(parser, 'polyphonyRestricted', false)
addParameter(parser, 'convergenceCriteria', 0.005)
addParameter(parser, 'r', 3) %For repitition restricted activations
addParameter(parser, 'c', 2) %For continuity enhancing activation matrix
addParameter(parser, 'p', 3) %For polyphony restriction

parse(parser, V, W, L, varargin{:});
repititionRestricted = parser.Results.repititionRestricted;
polyphonyRestricted = parser.Results.polyphonyRestricted;
continuityEnhanced = parser.Results.continuityEnhanced;
disp(continuityEnhanced)
r = parser.Results.r;
c = parser.Results.c;
p = parser.Results.p;

waitbarHandle = waitbar(0, 'Starting NMF synthesis...'); 

cost=0;

targetDim=size(V);
sourceDim=size(W);
K=sourceDim(2);
M=targetDim(2);

%Randomly initialized Matrix H: K x M
%Range: [0, 1)
H=random('unif',0, 1, K, M);
% P=zeros(K,M);
% R=zeros(K,M);
% C=zeros(K,M);

fprintf('Convergence Criteria: %d%%\n', 100*parser.Results.convergenceCriteria)
converged = false;

num=W'*V;
WTW = W'*W;

for l=1:L-1
    waitbar(l/(L-1), waitbarHandle, strcat('Computing approximation...Iteration: ', num2str(l), '/', num2str(L-1)))
    
    den=WTW*H;
    H=H.*(num./den);
    H(isnan(H))=0;
    
    if(repititionRestricted && l==L-1)
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
    
    if(polyphonyRestricted && l==L-1)
      P = zeros(size(H));
      mask = zeros(size(H,1),1);
      waitbar(l/(L-1), waitbarHandle, strcat('Polyphony Restriction...Iteration: ', num2str(l), '/', num2str(L-1)))
      for m = 1:size(H, 2)
        [~, sortedIndices] = sort(H(:, m),'descend');
        mask(sortedIndices(1:p)) = 1;
        mask(sortedIndices(p+1:end)) = (1-(l+1)/L);
        P(:,m)=H(:,m).*mask;
      end
      H = P;
    end
    
    if(continuityEnhanced && l==L-1)
        C = conv2(H, eye(c), 'same'); %Default
        
%                     C = conv2(P, flip(eye(c)), 'same'); %Reverse
        
%                     C = conv2(P, flip(ones(c)), 'same'); %Blurring
        
        %             %Vertical
%                     M = zeros(c, c);
%                     M(:, floor(c/2)) = 1;
%                     C = conv2(P, M, 'same');
        H = C;
    end
    
    cost(l)=norm(V-W*H, 'fro'); %Frobenius norm of a matrix
    if(l > 5 && (cost(l) > cost(l-1) || abs(((cost(l)-cost(l-1)))/max(cost))<parser.Results.convergenceCriteria)) %TODO: Reconsider exit condition
        converged = true;
        break;
    end
    
    %     if(l >= 3 && )
    %         H = C;
    %     end
    %     H = H./max(max(H)); %Normalize activations at each iteration to force matrix to be between 0 and 1
end

Y=H;

% if(repititionRestricted)
%     Y=R;
% end
% 
% if(polyphonyRestricted)
%     Y=P;
% end
% 
% if(continuityEnhanced)
%     Y=C;
% end

%Optional attribute for potential later use
iterations = l;
disp(strcat('Iterations:', num2str(iterations)))

Y = Y./max(max(Y)); %Normalize activations
% if(converged)
%     Y(20*log10(Y/max(max(Y)))<-25)=0;
% end

close(waitbarHandle);
end