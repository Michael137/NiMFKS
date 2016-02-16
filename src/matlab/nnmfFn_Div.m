function [Y, cost] = nnmfFn_Div(V, W, L, varargin)
%L: Iterations
%V: Matrix to be factorized
%W: Source matrix
cost=0;

parser = inputParser;
addRequired(parser, 'V')
addRequired(parser, 'W')
addRequired(parser, 'L')
addParameter(parser, 'repititionRestricted', false)
addParameter(parser, 'continuityEnhanced', false)
addParameter(parser, 'polyphonyRestricted', false)
addParameter(parser, 'convergenceCriteria', 0.05)

parse(parser, V, W, L, varargin{:});
repititionRestricted = parser.Results.repititionRestricted;
polyphonyRestricted = parser.Results.polyphonyRestricted;
continuityEnhanced = parser.Results.continuityEnhanced;

r=3; %For repitition restricted activations
c=2; %For continuity enhancing activation matrix
p=2; %For polyphony restriction
fprintf('Convergence Criteria: %d%%\n', 100*parser.Results.convergenceCriteria)

K=size(W, 2);
M=size(V, 2);
%Randomly initialized Matrix H: K x M
%Range: [0, 1)
H=random('unif',0, 1, K, M);
% H=rand(K, M);
% num = 0;
den = sum(W);

for l=1:L-1
    %     for k = 1:size(H, 1)
    %         for m = 1:size(H, 2)
    %             recon = W*H;
    %             n = 1 : size(W, 1);
    %             tmp = W(n, k).*V(n, m)./(recon(n, m));
    %             num = sum(tmp);
    %             den = sum(W(:, k));
    %             H(k, m) = H(k, m) * num / den;
    %         end
    %     end
    
    for k = 1:size(H, 1)
        for m = 1:size(H, 2)
            recon = W*H(:,m);
            num = W(:, k)'*(V(:, m)./(recon));
            H(k, m) = H(k, m) * num / den(k);
            
            if(repititionRestricted)
                if(m>r && (m+r)<=M && H(k,m)==max(H(k,m-r:m+r)))
                    R(k,m)=H(k,m);
                else
                    R(k,m)=H(k,m)*(1-(l+1)/L);
                end
            end
            
            %             if(polyphonyRestricted)
            %                 if(k>p && (k+p)<=K)
            %                     [~, sortIndices] = sort(R(:, m),'descend');
            %                     maximumIndices = sortIndices(1:p);
            %                     if(ismember(k, maximumIndices))
            %                         P(k,m)=R(k,m);
            %                     else
            %                         P(k,m)=R(k,m)*(1-(l+1)/L);
            %                     end
            %                 else
            %                     P(k,m)=R(k,m)*(1-(l+1)/L);
            %                 end
            %             end
            
            if(polyphonyRestricted)
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
            
            if(continuityEnhanced)
                if(l>1 && k > c && m > c && k < K-c && m < M-c)
                    kernelSum = 0;
                    for z = -c:1:c;
                        kernelSum = kernelSum + P(k+z, m+z);
                    end
                    C(k, m) = kernelSum;
                else
                    C(k, m) = P(k, m);
                end
            end
        end
    end
    
    %     cost(l)=norm(V-W*H, 'fro');
    cost(l)=KLDivCost(V, W*H);
    if(l>1 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/max(cost))<=parser.Results.convergenceCriteria)) %TODO: Reconsider exit condition
        break;
    end
    %     disp(l)
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

disp(strcat('Iterations:', num2str(l)))
end

% function [H, cost] = nnmfFn_Div(V, W, L)
% %L: Iterations
% %V: Matrix to be factorized
% %W: Source matrix
% cost=0;
%
% K=size(W, 2);
% M=size(V, 2);
% %Randomly initialized Matrix H: K x M
% %Range: [0, 1)
% H=random('unif',0, 1, K, M);
% % H=rand(K, M);
% num = 0;
% den = 0;
%
% for l=1:L-1
%     for k = 1:size(H, 1)
%         for m = 1:size(H, 2)
%             for n = 1 : size(W, 1)
%                 tmp = W*H;
%                 num = num + (W(n, k) * V(n, m)) / (tmp(n, m));
%             end
%
%             den = sum(W(:, k));
%             H(k, m) = H(k, m) * num / den;
%         end
%     end
%
% %     cost(l)=norm(V-W*H, 'fro');
%     cost(l)=KLDivCost(V, W*H);
%     disp(l)
% end
%
% recon=W*H;
% disp(strcat('Iterations:', num2str(l)))
% % plot(cost)
% % disp(recon)
% % disp(V)
% end

