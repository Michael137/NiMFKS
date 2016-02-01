%Diagonal appears if V=W under large number of iterations without
%cost-break

function [Y, cost] = nnmfFn(V, W, L, repititionRestricted, continuityEnhanced)
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

r=3; %For repitition restricted activations
c=2; %For continuity enhancing activation matrix

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
            
            %TODO: consider running after main loop
            if(repititionRestricted)
                if(m>r && (m+r)<=M && H(k,m)==max(H(k,m-r:m+r)))
                    R(k,m)=H(k,m);
                else
                    R(k,m)=H(k,m)*(1-(l+1)/L);
                end
            end
        end
    end  
    
    cost(l)=norm(V-W*H, 'fro'); %Frobenius norm of a matrix
    if(l>5 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/max(cost))<0.0005)) %TODO: Reconsider exit condition
        break;
    end
end

Y = H;

if(repititionRestricted)
    Y=R;
end

if(continuityEnhanced)
    for k = 1:K
        for m = 1:M
            if(k > c && m > c && k < K-c && m < M-c)
                kernelSum = 0;
                for z = -c:1:c;
                    kernelSum = kernelSum + R(k+z, m+z);
                end
                C(k, m) = kernelSum;
            else
                C(k, m) = R(k, m);
            end
        end
    end
    Y=C;
end

%Optional attribute for potential later use
iterations = l;
disp(strcat('Iterations:', num2str(iterations)))
end

