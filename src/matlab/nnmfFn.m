%Diagonal appears if V=W under large number of iterations without
%cost-break

function [Y, cost] = nnmfFn(V, W, L, repititionRestricted, continuityEnhanced, polyphonyRestricted)
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
p=2; %For polyphony restriction

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
    
    cost(l)=norm(V-W*H, 'fro'); %Frobenius norm of a matrix
    if(l>5 && (cost(l) >= cost(l-1) || abs(((cost(l)-cost(l-1)))/max(cost))<0.0005)) %TODO: Reconsider exit condition
        break;
    end
end

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
end

