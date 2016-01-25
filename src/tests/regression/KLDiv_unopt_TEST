function [H, cost] = KLDiv_unopt_TEST(V, W, L, diagonal)
%L: Iterations
%V: Matrix to be factorized
%W: Source matrix
cost=0;
K=size(W, 2);
M=size(V, 2);

%Randomly initialized Matrix H: K x M
%Range: [0, 1)
H=random('unif',0, 1, K, M);

n = 1 : size(W, 1);

for l=1:L-1    
    for k = 1:size(H, 1)
        for m = 1:size(H, 2)
            recon = W*H;
%             recon = full(sparse(W)*sparse(H));
            tmp = W(n, k).*V(n, m)./(recon(n, m));
            num = sum(tmp);
            den = sum(W(:, k));
            H(k, m) = H(k, m) * num / den;
        end
    end
    
    cost(l)=KLDivCost(V, W*H);
    if(strcmp(diagonal, 'no_diag'))
        if(l>5 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/max(cost))<=0.05)) %TODO: Reconsider exit condition
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
% for l=1:L-1    
%     for k = 1:size(H, 1)
%         recon = W*H;
%         for m = 1:size(H, 2)
%             recon(:,m) = W*H(:,m);
%             tmp = W(:, k).*V(:, m)./(recon(:, m));
%             num = sum(tmp);
%             den = sum(W(:, k));
%             H(k, m) = H(k, m) * num / den;
%         end
%     end
%     
% %     cost(l)=norm(V-W*H, 'fro');
%     cost(l)=KLDivCost(V, W*H);
%     if(l>1 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/cost(l))<=1e-6)) %TODO: Reconsider exit condition
%         break;
%     end
% %     disp(l)
% end
% 
% recon=W*H;
% disp(strcat('Iterations:', num2str(l)))
% % plot(cost)
% % disp(recon)
% % disp(V)
% end

% function [H, cost] = nnmfFn_Div_TEST_v2(V, W, L)
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
% recon=zeros(size(H, 1), 1);
% n = 1 : size(W, 1);
% 
% for l=1:L-1    
%     for k = 1:size(H, 1)
%         for m = 1:size(H, 2)
%             for i = 1:size(W, 1)
%                 recon(i, 1) = W(i, :)*H(:, m);
%             end
% %             disp('#####')
% %             disp(recon)
% %             recon2 = W*H;
% %             disp(recon2(m, :))
%             tmp = W(n, k).*V(n, m)./recon;
%             num = sum(tmp);
%             den = sum(W(:, k));
%             H(k, m) = H(k, m) * num / den;
%         end
%     end
%     
% %     cost(l)=norm(V-W*H, 'fro');
%     cost(l)=KLDivCost(V, W*H);
% %     if(l>1 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/cost(l))<=1e-6)) %TODO: Reconsider exit condition
% %         break;
% %     end
% %     disp(l)
% end
% 
% recon=W*H;
% disp(strcat('Iterations:', num2str(l)))
% % plot(cost)
% % disp(recon)
% % disp(V)
% end
