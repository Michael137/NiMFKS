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
            target_spect = abs(target_sound.Features.STFT.S);
            corpus_spect = abs(corpus_sound.Features.STFT.S);
            
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
            W = abs(corpus_sound.Features.STFT.S);
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
                    obj.Synthesis = templateAdditionResynth(corpus_sound.Signal, H, window.Length, window.Hop);
            end
        end
        
        function plot_activations(obj, varargin)
            if(nargin > 1)
                maxDb = varargin{1};
            else
                maxDb = -45;
            end
            
            H = obj.Activations;
            
            HdB = 20*log10(H./max(max(H)));
            HdB = HdB - maxDb;
            HdB(HdB < 0) = 0;
            imagesc(HdB);
            cmap = colormap('gray');
            cmap(1,:) = 0*ones(1,3);
            colormap(flipud(cmap))
            colorbar
            axis xy; grid on;
            set(gca, 'Layer', 'top');
            ylabel('Template');
            xlabel('Time');
            grid on;
            set(gca,'FontSize',16);
        end
        
        function plot_cost(obj)
            plot(obj.Cost);
            xlabel('Iteration');
            ylabel('Cost');
            title('Cost vs. Iteration');
            grid on
        end
    end
end