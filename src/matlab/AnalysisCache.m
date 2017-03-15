    classdef AnalysisCache < handle
    properties
        Corpus
        Target
        WinType
        Window
        Hop
        Hash
    end
    
    methods
        function obj = AnalysisCache(varargin)
            % [Corpus Target Window Hop]
            if nargin == 5
                obj.Corpus = varargin{1};
                obj.Target = varargin{2};
                obj.Window = varargin{3};
                obj.WinType = varargin{4};
                obj.Hop = varargin{5};
            end
        end
        
        function obj = GenerateHash(obj)
            ArrayToHash = [obj.Corpus; obj.Target; obj.WinType; obj.Window; obj.Hop];
            Opt = struct( 'Method', 'SHA-1' );
            obj.Hash = ['id', char(DataHash(ArrayToHash, Opt))];
        end
    end
end