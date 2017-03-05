function [ Y ] = prune_corpus( V, W )

    similarities = [];
    corpSimilarities = [];
    dimV = size( V );
    dimW = size( W );
    
    for i = 1:dimV(2)
        tmp = [];
        for j = 1:dimV(2)
            if j == i
                tmp(:, j) = -1;
            else
                tmp(:, j) = calc_frame_similarity( V(:, i), V(:, j)');
            end
        end
        
        similarities(:, i) = tmp;
    end
    
    for j = 1:dimW(2)
        tmp(j) = calc_frame_similarity( V(:, 1), W(:, j)' );
    end
    corpSimilarities(:, 1) = tmp;
    
    firstFrameSim = similarities(:, 1);
    delFrames = [];
    for i = 1:length(similarities(1))
        if firstFrameSim(i) < 20
            V(:, i) = 0;
            delFrames = [delFrames i];
        end
    end
    
    possibleFrames = 1:dimV(2);
    while size( V(V ~= 0 ), 1 ) > 0
        remainingFrames = possibleFrames( ~ismember( possibleFrames, delFrames ) );
        nextFrame = remainingFrames(1);
        if nextFrame ~= size( corpSimilarities, 2 ) + 1
            corpSimilarities(:, (size(corpSimilarities, 2) + 1):nextFrame - 1) = -1*ones(size(corpSimilarities, 1), 1);
        else
            for j = 1:dimW(2)
                tmp(j) = calc_frame_similarity( V(:, 1), W(:, j)' );
            end
            corpSimilarities( :, nextFrame ) = tmp;
        end
        for i = 1:length(similarities(:,nextFrame))
            if similarities(i,nextFrame) < 20
                V(:, i) = 0;
                delFrames = [delFrames i];
            end
        end
    end
    
    Y = corpSimilarities;
end

function [ sim ] = calc_frame_similarity( A, B )
    sim = sum(sum(dist(A,B)));   
end

function [ mahalDist ] = calc_mahalbonis_similarity( A, B )
% Analysis parameters
    anal_windowsize = 100; % ms
    anal_windowhop = anal_windowsize/2; % ms
    Fs_op = 22050; 
    fftsize = 2048;

    anal_windowsize_insamples = floor(anal_windowsize*Fs_op/1000);
    anal_windowhop_insamples = floor(anal_windowhop*Fs_op/1000);
    anal_window = window(@hann,anal_windowsize_insamples);

    featA = createFeatureMatrix(A,anal_window,anal_windowhop_insamples,fftsize,Fs_op);
    featB = createFeatureMatrix(B,anal_window,anal_windowhop_insamples,fftsize,Fs_op);
    

    % the dimension of the random hash
    embeddingDimension = 2;
    % create embedding matrix
    M_embed = randn(embeddingDimension,size(A,1)-2);
    
    % project features
    ECORPUS = M_embed*A(3:end,:);
    ETARGET = M_embed*A(3:end,:);
    
    % find covariance matrix for Mahalanobis distance calculation
    SIGMA = cov([ECORPUS'; ETARGET']);
    sqrtSIGinv = sqrt(inv(SIGMA));
    % compute distances between every corpus frame and target frame
    sim = norm(sqrtSIGinv*(A-B));
end