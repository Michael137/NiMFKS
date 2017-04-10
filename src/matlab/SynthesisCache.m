classdef SynthesisCache < handle
    properties
        Iterations
        Seed
        Convergence
        CostMetric
        RepRestrict
        PolyRestrict
        ContRestrict
        DiagPattern
        Rotation
        Endtime
        Lambda
        Prune
        Hash
        AnalysisHash
    end
    
    methods
        function obj = SynthesisCache(varargin)
            if nargin == 13
                obj.Iterations = varargin{1};
                obj.Seed = varargin{2};
                obj.Convergence = varargin{3};
                obj.CostMetric = varargin{4};
                obj.RepRestrict = varargin{5};
                obj.PolyRestrict = varargin{6};
                obj.ContRestrict = varargin{7};
                obj.DiagPattern = varargin{8};
                obj.Rotation = varargin{9};
                obj.Endtime = varargin{10};
                obj.Lambda = varargin{11};
                obj.Prune = varargin{12};
                obj.AnalysisHash = varargin{13};
            end
        end  
        
        function obj = GenerateHash(obj)
            ArrayToHash = [obj.Iterations; obj.Seed; obj.Convergence; obj.CostMetric; ...
                           obj.RepRestrict; obj.PolyRestrict; obj.ContRestrict; ...
                           obj.DiagPattern; obj.Rotation; obj.Endtime; obj.Lambda; obj.Prune ];
                       
            ArrayToHash = [ ArrayToHash; (1*obj.AnalysisHash)'];
            Opt = struct( 'Method', 'SHA-1' );
            obj.Hash = ['id', char(DataHash(ArrayToHash, Opt))];
        end
    end
end