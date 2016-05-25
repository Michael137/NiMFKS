classdef CSS < handle
    properties
        NMF_features
        Activations
        Cost
        Synthesis_method
        Synthesis
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
            nmf_alg = obj.NMF_features.Algorithm;
            target_spect = corpus_sound.Features.STFT.S;
            corpus_spect = target_sound.Features.STFT.S;
            
            switch nmf_alg
                case 'Euclidean'
                    if length(fieldnames(obj.NMF_features)) > 1
                        [obj.Activations, obj.Cost] = nmf_euclidean(target_spect, corpus_spect, obj.NMF_features);
                    else
                        [obj.Activations, obj.Cost] = nmf_euclidean(target_spect, corpus_spect);
                    end
                case 'Divergence'
                    if length(fieldnames(obj.NMF_features)) > 1
                        [obj.Activations, obj.Cost] = nmf_divergence(target_spect, corpus_spect, obj.NMF_features);
                    else
                        [obj.Activations, obj.Cost] = nmf_divergence(target_spect, corpus_spect);
                    end
            end
        end
        
        function obj = synthesize(obj, corpus_sound)
            synth_method = obj.Synthesis_method;
            window = corpus_sound.Features.window;
            W = corpus_sound.Features.STFT.S;
            H = obj.Activations;
            
            switch synth_method
                case 'ISTFT'
                    parameters = [];
                    parameters.synHop = window.Hop;
                    parameters.win = window;

                    reconstruction = W*H;
                    padding = size(reconstruction, 1)*2 - window.Length - 2;
                    if padding >= 0
                        parameters.zeroPad = padding;
                    end

                    obj.Synthesis = istft(reconstruction, parameters);
                case 'Template Addition'
                    obj.Synthesis = templateAdditionResynth(W, H, window.Length, window.Hop);
            end
        end
    end
end