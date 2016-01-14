%Diagonal appears if V=W under large number of iterations without
%cost-break

function [H, cost] = nnmfFn_Eucl_TEST(V, W, L, diagonal)
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
    if(strcmp(diagonal, 'no_diag'))
        if(l>5 && (cost(l) >= cost(l-1) || abs((abs((cost(l)-cost(l-1))))/max(cost))<=0.05)) %TODO: Reconsider exit condition
            break;
        end
    end
end

%Optional attribute for potential later use
iterations = l;
disp(strcat('Iterations:', num2str(iterations)))
end

