function [ Y, PrunedFrames ] = prune_corpus( target, corpus, reduction_coef )

    if reduction_coef == 1
        Y = corpus;
        PrunedFrames = [];
        return;
    end
    [targetRows, targetCols]= size( target );
    [corpusRows, corpusCols]= size( corpus );
    
    % Matrix: distances of every target frame to every other target frame
    % i.e. Self-similarity matrix
    TargetSelfSimMat = zeros(targetCols);
    
    % Matrix: distances of every target frame to every corpus frame
    % Matrix( i, j ) = Similarity of corpus frame i to target frame j
%     TargetToCorpSimMat = -1*ones(WCols, targetCols);
    
    % Calculate self-similarity of target (euclidean dist)
    X2 = sum(target.^2,1);
    TargetSelfSimMat = bsxfun(@plus,X2,X2')-2*(target'*target);
%     TargetSelfSimMat = exp(-(1/10) * DistanceMat);
    
    % Calculate the distance between each corpus frame to first target
    % frame
    KeepCorpusFrames = [];
    RemainingTargetFrames = 1:targetCols;
    RemainingCorpusFrames = 1:corpusCols;
    
    while ~isempty(RemainingTargetFrames)
        Dist = repmat(target(:,RemainingTargetFrames(1)),1, ...
            length(RemainingCorpusFrames)) - corpus(:,RemainingCorpusFrames);
        Distances = sum(Dist.^2,1);
        % compute mean distances
        meanDistance = mean(Distances);
        
        % find those corpus frames closer than reduction_coef of mean
        idxcorpuskeep = Distances < reduction_coef*meanDistance;
        KeepCorpusFrames = [KeepCorpusFrames RemainingCorpusFrames(idxcorpuskeep)];
        
        % find those target frames within twice that to next frame
        distancetonext = TargetSelfSimMat(RemainingTargetFrames(1)+1,RemainingTargetFrames(1));
        idxtarget = TargetSelfSimMat(RemainingTargetFrames,RemainingTargetFrames(1)) ...
            < 2*distancetonext;
        
        % shrink corpus
        RemainingCorpusFrames = RemainingCorpusFrames(~idxcorpuskeep);
        
        % shrink target frames index
        RemainingTargetFrames = RemainingTargetFrames(~idxtarget);
    end
    
corpus = corpus( :, sort( KeepCorpusFrames ) );
Y = corpus;
PrunedFrames = setdiff( 1:corpusCols, KeepCorpusFrames );

fprintf( 'Pruned %d frames...\n', size( PrunedFrames ) );

end