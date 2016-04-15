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
    end
    
    if(polyphonyRestricted && l==L-1)
        for k=1:K
            %Updating H
            for m=1:M
                [~, sortedIndices] = sort(R(:, m),'descend');
                index = (length(sortedIndices) >= p) * p + ...
                    (length(sortedIndices) < p) * length(sortedIndices);
                maximumIndices = sortedIndices(1:index);
                if(ismember(k, maximumIndices))
                    P(k,m)=R(k,m);
                else
                    P(k,m)=R(k,m)*(1-(l+1)/L);
                end
            end
        end
    end

    cost(l)=norm(V-W*H, 'fro'); %Frobenius norm of a matrix
    if(l > 5 && (cost(l) > cost(l-1) || abs(((cost(l)-cost(l-1)))/max(cost))<parser.Results.convergenceCriteria)) %TODO: Reconsider exit condition
        converged = true;
        break;
    end
    
    if(continuityEnhanced && l==L-1)
        if(l>1)
            C = conv2(P, eye(c), 'same'); %Default

%             C = conv2(P, flip(eye(c)), 'same'); %Reverse
            
%             C = conv2(P, flip(ones(c)), 'same'); %Blurring

%             %Vertical
%             M = zeros(c, c);
%             M(:, floor(c/2)) = 1;
%             C = conv2(P, M, 'same');
        end
    end
    
    %     if(l >= 3 && )
    %         H = C;
    %     end
    %     H = H./max(max(H)); %Normalize activations at each iteration to force matrix to be between 0 and 1
end

Y=H;

if(repititionRestricted)
    Y=R;
end

if(polyphonyRestricted)
    Y=P;
end

if(continuityEnhanced)
    Y=C;
end

%Optional attribute for potential later use
iterations = l;
disp(strcat('Iterations:', num2str(iterations)))

Y = Y./max(max(Y)); %Normalize activations
% if(converged)
%     Y(20*log10(Y/max(max(Y)))<-25)=0;
% end

close(waitbarHandle);
end

% %Version 1:
% %Diagonal appears if V=W under large number of iterations without
% %cost-break
% 
% function [Y, cost] = nnmfFn(V, W, L, varargin)
% %L: Iterations
% %V: Matrix to be factorized
% %W: Source matrix
% parser = inputParser;
% addRequired(parser, 'V')
% addRequired(parser, 'W')
% addRequired(parser, 'L')
% addParameter(parser, 'repititionRestricted', false)
% addParameter(parser, 'continuityEnhanced', false)
% addParameter(parser, 'polyphonyRestricted', false)
% addParameter(parser, 'convergenceCriteria', 0.005)
% addParameter(parser, 'r', 3) %For repitition restricted activations
% addParameter(parser, 'c', 2) %For continuity enhancing activation matrix
% addParameter(parser, 'p', 3) %For polyphony restriction
% 
% parse(parser, V, W, L, varargin{:});
% repititionRestricted = parser.Results.repititionRestricted;
% polyphonyRestricted = parser.Results.polyphonyRestricted;
% continuityEnhanced = parser.Results.continuityEnhanced;
% r = parser.Results.r;
% c = parser.Results.c;
% p = parser.Results.p;
% 
% cost=0;
% 
% targetDim=size(V);
% sourceDim=size(W);
% K=sourceDim(2);
% M=targetDim(2);
% 
% %Randomly initialized Matrix H: K x M
% %Range: [0, 1)
% H=random('unif',0, 1, K, M);
% 
% fprintf('Convergence Criteria: %d%%\n', 100*parser.Results.convergenceCriteria)
% converged = false;
% 
% for l=1:L-1
%     num=W'*V;
%     den=W'*W*H;
%     
%     for k=1:K
%         %Updating H
%         for m=1:M
%             H(k, m)=H(k, m)*num(k, m)/den(k, m);
%             if(isnan(H(k,m)))
%                 H(k,m)=0;
%             end
%             
%             if(repititionRestricted)
%                 if(m>r && (m+r)<=M && H(k,m)==max(H(k,m-r:m+r)))
%                     R(k,m)=H(k,m);
%                 else
%                     R(k,m)=H(k,m)*(1-(l+1)/L);
%                 end
%             end
%             
%             if(polyphonyRestricted)
%                 [~, sortedIndices] = sort(R(:, m),'descend');
%                 index = (length(sortedIndices) >= p) * p + ...
%                             (length(sortedIndices) < p) * length(sortedIndices);
%                         maximumIndices = sortedIndices(1:index);
%                 if(ismember(k, maximumIndices))
%                     P(k,m)=R(k,m);
%                 else
%                     P(k,m)=R(k,m)*(1-(l+1)/L);
%                 end
%             end
% 
%             if(continuityEnhanced)
%                 if(l>1 && k > c && m > c && k < K-c && m < M-c)
%                     kernelSum = 0;
%                     for z = -c:1:c;
%                         kernelSum = kernelSum + P(k+z, m+z);
%                     end
%                     C(k, m) = kernelSum;
%                 else
%                     C(k, m) = P(k, m);
%                 end
%             end
%         end
%     end  
%     
%     cost(l)=norm(V-W*H, 'fro'); %Frobenius norm of a matrix
%     if(l>5 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/max(cost))<parser.Results.convergenceCriteria)) %TODO: Reconsider exit condition
%         converged = true;
%         break;
%     end
% 
% %     H = H./max(max(H)); %Normalize activations at each iteration to force matrix to be between 0 and 1
% end
% 
% Y=H;
% 
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
% 
% %Optional attribute for potential later use
% iterations = l;
% disp(strcat('Iterations:', num2str(iterations)))
% 
% % Y = Y./max(max(Y)); %Normalize activations
% % if(converged)
% %     Y(20*log10(Y/max(max(Y)))<-25)=0;
% % end
% end

