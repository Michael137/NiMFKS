classdef CSS < handle
    properties
        nmf_features
        activations
        cost
        synthesis_method
    end
    
    methods
        function obj = Sound(varargin)
            if nargin == 1
            end
            
            obj.init;
        end
        
        function obj = init(obj)
        end
    end
    
    methods
        function obj = nmf(obj, sound)
            
        end
        
        function obj = synthesize(obj, sound)
            
        end
    end
end