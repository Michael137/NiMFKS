%Diagonal appears if V=W under large number of iterations without
%cost-break

function [H, cost] = nnmfFn(V, W, L)
%L: Iterations
%V: Matrix to be factorized
%W: Source matrix

cost=0;

targetDim=size(V);
sourceDim=size(W);
K=sourceDim(2);
M=targetDim(2);

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
    if(l>1 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/cost(l))<=1e-6)) %TODO: Reconsider exit condition
        break;
    end
end

%Optional attribute for potential later use
iterations = l;
disp(strcat('Iterations:', num2str(iterations)))
end

