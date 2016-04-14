function [Y, cost] = nnmfFn_Div_TEST(V, W, L, varargin)
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

fprintf('Convergence Criteria: %d%%\n', 100*parser.Results.convergenceCriteria)
converged = false;

K=size(W, 2);
M=size(V, 2);
%Randomly initialized Matrix H: K x M
%Range: [0, 1)
H=random('unif',0, 1, K, M);
P=zeros(K, M);
R=zeros(K, M);
C=zeros(K, M);
% H=rand(K, M);
% num = 0;

V = V+1E-6;
W = W+1E-6;
den = sum(W);

for l=1:L-1
    waitbar(l/(L-1), waitbarHandle, strcat('Computing approximation...Iteration: ', num2str(l), '/', num2str(L-1)))
    
%     for k = 1:size(H, 1)
%         for m = 1:size(H, 2)
%             
%             recon = W*H(:,m);
%             num = W(:, k)'*(V(:, m)./(recon));
%             H(k, m) = H(k, m) * num / den(k);
%             H(isnan(H))=0;
%         end
%     end
    
    recon = W*H;
    for mm = 1:size(H,2)
      num = V(:,mm).*(1./recon(:,mm));
      num2 = num'*W./den;
      H(:,mm) = H(:, mm).*num2';
    end
    
    if(repititionRestricted)
    waitbar(l/(L-1), waitbarHandle, strcat('Repitition Restriction...Iteration: ', num2str(l), '/', num2str(L-1)))
        for k = 1:size(H, 1)
            for m = 1:size(H, 2)
                if(m>r && (m+r)<=M && H(k,m)==max(H(k,m-r:m+r)))
                    R(k,m)=H(k,m);
                else
                    R(k,m)=H(k,m)*(1-(l+1)/L);
                end
            end
        end
    end
    
    if(polyphonyRestricted)
    waitbar(l/(L-1), waitbarHandle, strcat('Polyphony Restriction...Iteration: ', num2str(l), '/', num2str(L-1)))
        for k = 1:size(H, 1)
            for m = 1:size(H, 2)
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
    
    if(continuityEnhanced)
    waitbar(l/(L-1), waitbarHandle, strcat('Continuity Enhancement...Iteration: ', num2str(l), '/', num2str(L-1)))
        for k = 1:size(H, 1)
            for m = 1:size(H, 2)
                C = conv2(P, eye(c), 'same');
                recon = W*C(:,m);
                num = W(:, k)'*(V(:, m)./(recon));
                H(k, m) = C(k, m) * num / den(k);
                H(isnan(H))=0;
            end
        end
    elseif(polyphonyRestricted)
        for k = 1:size(H, 1)
            for m = 1:size(H, 2)
                recon = W*P(:,m);
                num = W(:, k)'*(V(:, m)./(recon));
                H(k, m) = P(k, m) * num / den(k);
                H(isnan(H))=0;
            end
        end
    elseif(repititionRestricted)
        for k = 1:size(H, 1)
            for m = 1:size(H, 2)
                recon = W*R(:,m);
                num = W(:, k)'*(V(:, m)./(recon));
                H(k, m) = R(k, m) * num / den(k);
                H(isnan(H))=0;
            end
        end
    end

    %     cost(l)=norm(V-W*H, 'fro');
    cost(l)=KLDivCost(V, W*H);
    if(l>3 && (abs(((cost(l)-cost(l-1)))/max(cost))<=parser.Results.convergenceCriteria)) %TODO: Reconsider exit condition
        converged = true;
        break;
    end

    %     if(l >= 3 && continuityEnhanced)
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

disp(strcat('Iterations:', num2str(l)))

Y = Y./max(max(Y)); %Normalize activations
% if(converged)
%     Y(20*log10(Y/max(max(Y)))<-25)=0;
% end
close(waitbarHandle);
end

% function [Y, cost] = nnmfFn_Div_TEST(V, W, L, varargin)
% %L: Iterations
% %V: Matrix to be factorized
% %W: Source matrix
% cost=0;
% 
% parser = inputParser;
% addRequired(parser, 'V')
% addRequired(parser, 'W')
% addRequired(parser, 'L')
% addParameter(parser, 'repititionRestricted', false)
% addParameter(parser, 'continuityEnhanced', false)
% addParameter(parser, 'polyphonyRestricted', false)
% addParameter(parser, 'convergenceCriteria', 0.05)
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
% waitbarHandle = waitbar(0, 'Starting NMF synthesis...');
% 
% fprintf('Convergence Criteria: %d%%\n', 100*parser.Results.convergenceCriteria)
% converged = false;
% 
% K=size(W, 2);
% M=size(V, 2);
% %Randomly initialized Matrix H: K x M
% %Range: [0, 1)
% H=random('unif',0, 1, K, M);
% P=zeros(K, M);
% R=zeros(K, M);
% C=zeros(K, M);
% % H=rand(K, M);
% % num = 0;
% den = sum(W);
% 
% for l=1:L-1
%     waitbar(l/(L-1), waitbarHandle, strcat('Computing approximation...Iteration: ', num2str(l), '/', num2str(L-1)))
%     
%     for k = 1:size(H, 1)
%         for m = 1:size(H, 2)
%             
%             recon = W*H(:,m);
%             num = W(:, k)'*(V(:, m)./(recon));
%             H(k, m) = H(k, m) * num / den(k);
%             H(isnan(H))=0;
%         end
%     end
%     
%     if(repititionRestricted)
%     waitbar(l/(L-1), waitbarHandle, strcat('Repitition Restriction...Iteration: ', num2str(l), '/', num2str(L-1)))
%         for k = 1:size(H, 1)
%             for m = 1:size(H, 2)
%                 if(m>r && (m+r)<=M && H(k,m)==max(H(k,m-r:m+r)))
%                     R(k,m)=H(k,m);
%                 else
%                     R(k,m)=H(k,m)*(1-(l+1)/L);
%                 end
%             end
%         end
%     end
%     
%     if(polyphonyRestricted)
%     waitbar(l/(L-1), waitbarHandle, strcat('Polyphony Restriction...Iteration: ', num2str(l), '/', num2str(L-1)))
%         for k = 1:size(H, 1)
%             for m = 1:size(H, 2)
%                 [~, sortedIndices] = sort(R(:, m),'descend');
%                 index = (length(sortedIndices) >= p) * p + ...
%                     (length(sortedIndices) < p) * length(sortedIndices);
%                 maximumIndices = sortedIndices(1:index);
%                 if(ismember(k, maximumIndices))
%                     P(k,m)=R(k,m);
%                 else
%                     P(k,m)=R(k,m)*(1-(l+1)/L);
%                 end
%             end
%         end
%     end
%     
%     if(continuityEnhanced)
%     waitbar(l/(L-1), waitbarHandle, strcat('Continuity Enhancement...Iteration: ', num2str(l), '/', num2str(L-1)))
%         for k = 1:size(H, 1)
%             for m = 1:size(H, 2)
%                 C = conv2(P, eye(c), 'same');
%                 recon = W*C(:,m);
%                 num = W(:, k)'*(V(:, m)./(recon));
%                 H(k, m) = C(k, m) * num / den(k);
%                 H(isnan(H))=0;
%             end
%         end
%     elseif(polyphonyRestricted)
%         for k = 1:size(H, 1)
%             for m = 1:size(H, 2)
%                 recon = W*P(:,m);
%                 num = W(:, k)'*(V(:, m)./(recon));
%                 H(k, m) = P(k, m) * num / den(k);
%                 H(isnan(H))=0;
%             end
%         end
%     elseif(repititionRestricted)
%         for k = 1:size(H, 1)
%             for m = 1:size(H, 2)
%                 recon = W*R(:,m);
%                 num = W(:, k)'*(V(:, m)./(recon));
%                 H(k, m) = R(k, m) * num / den(k);
%                 H(isnan(H))=0;
%             end
%         end
%     end
% 
%     %     cost(l)=norm(V-W*H, 'fro');
%     cost(l)=KLDivCost(V, W*H);
%     if(l>3 && (abs(((cost(l)-cost(l-1)))/max(cost))<=parser.Results.convergenceCriteria)) %TODO: Reconsider exit condition
%         converged = true;
%         break;
%     end
% 
%     %     if(l >= 3 && continuityEnhanced)
%     %         H = C;
%     %     end
%     %     H = H./max(max(H)); %Normalize activations at each iteration to force matrix to be between 0 and 1
% end
% 
% Y=H;
% 
% % if(repititionRestricted)
% %     Y=R;
% % end
% % 
% % if(polyphonyRestricted)
% %     Y=P;
% % end
% % 
% % if(continuityEnhanced)
% %     Y=C;
% % end
% 
% disp(strcat('Iterations:', num2str(l)))
% 
% Y = Y./max(max(Y)); %Normalize activations
% % if(converged)
% %     Y(20*log10(Y/max(max(Y)))<-25)=0;
% % end
% close(waitbarHandle);
% end