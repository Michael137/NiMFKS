function [bool] = ExistsInCache(Hash, handles, cacheType )

    switch cacheType
        case 'Analysis'
            cacheTypeMap = 'AnalysisCacheMap';
        case 'Synthesis'
            cacheTypeMap = 'SynthesisCacheMap';
    end
            
    if( isfield( handles, 'Cache' ) )
        bool = isfield(handles.Cache.(cacheTypeMap), Hash);
    else
        AppCache = matfile('nimfks_cache.mat');
        bool = isfield(AppCache.(cacheTypeMap), Hash);
    end
end