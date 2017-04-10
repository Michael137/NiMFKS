function [FromCache] = LoadFromCache(Hash, cacheType)
    
    switch cacheType
        case 'Analysis'
            cacheTypeMap = 'AnalysisCacheMap';
        case 'Synthesis'
            cacheTypeMap = 'SynthesisCacheMap';
    end    

    AppCache = matfile('nimfks_cache.mat');
    Map = AppCache.(cacheTypeMap);
    FromCache = Map.(Hash);
end