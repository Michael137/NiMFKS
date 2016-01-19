%Kullback-Leibler Divergence

% Findings:
% 1. Diagonal structures are visible if cost-break clause is removed and a
% relatively low amount of iterations is allowed e.g. 50 for the current
% setup
% 
% 2. Computes slowly for large number matrices
clear all
clc

V=random('unif',1, 50, 100, 100);
% W=random('unif',1, 50, 7, 7);
W=V;
cost=0;
L=100;

K=size(W, 2);
M=size(V, 2);
%Randomly initialized Matrix H: K x M
%Range: [0, 1)
H=random('unif',0, 1, K, M);
% H=rand(K, M);

for l=1:L-1    
    for k = 1:size(H, 1)
        for m = 1:size(H, 2)
            H(k, m) = H(k, m)*approximationFactor(k, m, W, V, H);
        end
    end
    
%     cost(l)=norm(V-W*H, 'fro');

cost(l) = KLDivCost(V, W*H);

% if(l>1 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/cost(l))<=0.5))
%     break;
% end

end

recon=W*H;
disp(strcat('Iterations:', num2str(l)))
plot(cost)
disp(recon)
disp(V)
figure()
imagesc(H)

%% Euclidean

% Findings:
% 1. Takes more iterations to converge and thus diagonal structure becomes
% visible only after higher number of iterations
% 
% 2. Computes orders of magnitude faster than the divergence minimization
% method

V=random('unif',1, 50, 7, 7);
% W=random('unif',1, 50, 7, 7);
W=V;

cost=0;
recon=0;

targetDim=size(V);
sourceDim=size(W);
K=sourceDim(2);
M=targetDim(2);
L=5000;

%Randomly initialized Matrix H: K x M
%Range: [0, 1)
H=random('unif',0, 1, K, M);

for l=1:L-1
    num=W'*V;
    den=W'*W*H;
    
    for k=1:K
        %Updating H
        for m=1:M
            H(k, m)=H(k, m)*num(k, m)/den(k, m);
            if(isnan(H(k,m)))
                H(k,m)=0;
            end
        end
    end  
    
    cost(l)=norm(V-W*H, 'fro'); %Frobenius norm of a matrix
%     if(l>1)
%     abs(((cost(l)-cost(l-1)))/cost(l));
%     end
    if(l>1 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/cost(l))<=10e-3))
        break;
    end
end

recon=W*H;
disp(strcat('Iterations:', num2str(l)))
plot(cost)
disp(recon)
disp(V)
figure()
imagesc(H)