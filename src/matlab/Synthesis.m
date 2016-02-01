classdef Synthesis < handle
    properties
        Source
        Target
        Fs
        WindowLength
        Overlap
        NNMFSynthesis
        Resynthesis
        SourceSpectrogram
        TargetSpectrogram
    end
    
    methods
        function obj = Synthesis(varargin)
            if nargin > 0
                obj.Source = varargin{1};
                obj.Target= varargin{2};
                
                if nargin > 2
                    obj.Fs = varargin{3};
                    obj.WindowLength = floor(varargin{3}*varargin{4}/1000);
                    obj.Overlap = floor(varargin{3}*varargin{5}/1000);
                end
            else
                error('Wrong number of input arguments');
            end
        end
        
        function obj = computeSpectrogram(obj, identifier)
            if(strcmp(identifier, 'Source'))
                Y = obj.Source;
                [S F T] = computeSpectrogram(Y, obj.WindowLength, obj.Overlap, obj.Fs);
                obj.SourceSpectrogram = Spectrogram(S, F, T);
            elseif(strcmp(identifier, 'Target'))
                Y = obj.Target;
                [S F T] = computeSpectrogram(Y, obj.WindowLength, obj.Overlap, obj.Fs);
                obj.TargetSpectrogram = Spectrogram(S, F, T);
            else
                error(strcat('Invalid argument "', identifier, '". Use either "Source" or "Target".'));
            end
        end
        
        function obj = synthesize(obj, synthMethod, costMetric, iterations, repititionRestricted, continuityEnhanced, polyphonyRestricted)
            if(strcmp(synthMethod, 'NNMF'))
                target=abs(obj.TargetSpectrogram.S);
                target(target == 0) = 1e-10;
                
                source=abs(obj.SourceSpectrogram.S);
                source(source == 0) = 1e-10;
                
                %H: templates x time
                %recon: reconstruction of target; frequency x time
                %cost: distance measure between target and reconstruction
                if(strcmp(costMetric, 'Euclidean'))
                    [H, cost]=nnmfFn(target, source, iterations, repititionRestricted, continuityEnhanced, polyphonyRestricted);
                    recon = obj.SourceSpectrogram.S*H;
                elseif(strcmp(costMetric, 'Divergence'))
                    [H, cost]=nnmfFn_Div(target, source, iterations);
                    recon = obj.SourceSpectrogram.S*H;
                end
                
                obj.NNMFSynthesis = NNMF(H, recon, cost);
            else
                error(strcat('Invalid argument "', synthMethod, '". Use either "NNMF" or "CSS".'));
            end
        end
        
        function obj = resynthesize(obj, identifier)
            if(strcmp(identifier, 'ISTFT'))
                obj.Resynthesis = istft(obj.NNMFSynthesis.Reconstruction, obj.Overlap,2048*8,obj.Fs,hann(2048*8, 'periodic'));
                audiowrite('C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav', obj.Resynthesis, obj.Fs);
            elseif(strcmp(identifier, 'Template Addition'))
                obj.Resynthesis = templateAdditionResynth(obj.Source, obj.NNMFSynthesis.Activations, obj.WindowLength, obj.Overlap);
%                 obj.Resynthesis(abs(obj.Resynthesis)>5)=mean(obj.Resynthesis);
                audiowrite('C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav', obj.Resynthesis, obj.Fs);
            end
        end
        
        function showResynthesis(obj)
%             obj.Resynthesis(abs(obj.Resynthesis)>5)=mean(obj.Resynthesis);
            plot(obj.Resynthesis);
        end
    end
end