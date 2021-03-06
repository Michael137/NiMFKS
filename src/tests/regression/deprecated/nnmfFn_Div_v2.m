function [H, cost] = nnmfFn_Div(V, W, L)
%L: Iterations
%V: Matrix to be factorized
%W: Source matrix
cost=0;

K=size(W, 2);
M=size(V, 2);
%Randomly initialized Matrix H: K x M
%Range: [0, 1)
H=random('unif',0, 1, K, M);
% H=rand(K, M);
num = 0;
den = 0;
for l=1:L-1    
    for k = 1:size(H, 1)
        recon = W*H;
        for m = 1:size(H, 2)
            recon(:,m) = W*H(:,m);
            tmp = W(:, k).*V(:, m)./(recon(:, m));
            num = sum(tmp);
            den = sum(W(:, k));
            H(k, m) = H(k, m) * num / den;
        end
    end
    
%     cost(l)=norm(V-W*H, 'fro');
    cost(l)=KLDivCost(V, W*H);
    if(l>1 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/cost(l))<=1e-6)) %TODO: Reconsider exit condition
        break;
    end
%     disp(l)
end

recon=W*H;
disp(strcat('Iterations:', num2str(l)))
% plot(cost)
% disp(recon)
% disp(V)
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

