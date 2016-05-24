classdef CSS < handle
    properties
        NMF_features
        Activations
        Cost
        Synthesis_method
    end
    
    methods
        function obj = CSS(varargin)
            if nargin == 2
                obj.NMF_features = varargin{1};
                obj.Synthesis_method = varargin{2};
            end
        end
    end
    
    methods
        function obj = nmf(obj, corpus_sound, target_sound)
                [H, cost]=nmfFn(obj.NMF_Features, corpus_sound.Features.STFT, target_sound.Features.STFT);
        end
        
        function obj = synthesize(obj, sound)
            
        end
    end
end