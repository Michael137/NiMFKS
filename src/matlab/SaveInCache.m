function [AppCache] = SaveInCache(cache, handles, cacheType, data)

    NimfksCache = matfile( 'nimfks_cache.mat', 'Writable', true );
    
    switch cacheType
        case 'Analysis'
            cacheTypeMap = 'AnalysisCacheMap';
        case 'Synthesis'
            cacheTypeMap = 'SynthesisCacheMap';
    end

    AppCache = matfile( 'nimfks_cache.mat' );

    hash = cache.Hash;

    CacheMap = AppCache.(cacheTypeMap);
    CacheMap.(hash) = data;
    
    NimfksCache.(cacheTypeMap) = CacheMap;
%     save( 'nimfks_cache.mat', cacheTypeMap );
end