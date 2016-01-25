function [H, cost] = KLDiv_opt_TEST(V, W, L, diagonal)
%L: Iterations
%V: Matrix to be factorized
%W: Source matrix
cost=0;
K=size(W, 2);
M=size(V, 2);

%Randomly initialized Matrix H: K x M
%Range: [0, 1)
H=random('unif',0, 1, K, M);
den = sum(W);

for l=1:L-1    
    for k = 1:size(H, 1)
        for m = 1:size(H, 2)
            recon = W*H(:,m);
            num = W(:, k)'*(V(:, m)./(recon));
            H(k, m) = H(k, m) * num / den(k);
        end
    end
    
    cost(l)=KLDivCost(V, W*H);
    if(strcmp(diagonal, 'no_diag'))
        if(l>1 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/max(cost))<=0.05)) %TODO: Reconsider exit condition
            break;
        end
    end
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

