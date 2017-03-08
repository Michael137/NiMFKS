function [ Y, pruned ] = prune_corpus( V, W, reduction_coef )

    [~, VCols]= size( V );
    [~, WCols]= size( W );
    
    % Matrix: distances of every target frame to every corpus frame
    % Matrix( i, j ) = Similarity of corpus frame i to target frame j
    TargetToCorpSimMat = -1*ones(WCols, VCols);
    
    % Calculate self-similarity of target (euclidean dist)
    X = sum(V.^2,1);
    DistanceMat = real( sqrt(bsxfun(@plus,X,X')-2*(V'*V)) );
    TargetSelfSimMat = exp(-(1/10) * DistanceMat);
    
    % Calculate the distance between each corpus frame to each target
    % frame
    TargetFramesToDelete = [];
    PossibleNextFrames = 1:VCols;
    
    % j: current target frame to compare to all corpus frames
    j = 1;
    while size( V(V ~= -1 ), 1 ) > 0        
        Dist = V(:,j)-W;
        TargetToCorpSimMat(:,j) = arrayfun(@(n) norm(Dist(:,n)), 1:size(Dist,2))';
       
        for i = 1:VCols
            if TargetSelfSimMat(i,j) > mean( TargetSelfSimMat(:,i))
                V(:, i) = -1;
                TargetFramesToDelete = [TargetFramesToDelete i];
            end
        end
        RemainingFrames = PossibleNextFrames( ~ismember( PossibleNextFrames, TargetFramesToDelete ) );
        if( size( RemainingFrames, 2) > 1 )
            j = RemainingFrames(1);
        else
            j = RemainingFrames;
        end
    end
    
    % Prune all unnecessary corpus frames i.e. lower than a certain cost
    % threshold
    [~, Idxs] = sort(TargetToCorpSimMat(:), 'descend');
    [CorpusFramesToBeDeleted, ~] = ind2sub(size(TargetToCorpSimMat), Idxs(end-floor(reduction_coef*WCols):end));
    
    W( :, CorpusFramesToBeDeleted ) = [];
    Y = W;
    pruned = CorpusFramesToBeDeleted;
end