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
        
        function obj = computeSpectrogram(obj, identifier, varargin)
            if(nargin <= 2)
                type = 'Regular';
            else
                type = varargin{1};
            end
            
            if(strcmp(identifier, 'Source'))
                Y = obj.Source;
                [S F T] = computeSpectrogram(Y, obj.WindowLength, obj.Overlap, obj.Fs, 'Spectrogram', type);
                obj.SourceSpectrogram = Spectrogram(S, F, T, type);
            elseif(strcmp(identifier, 'Target'))
                Y = obj.Target;
                [S F T] = computeSpectrogram(Y, obj.WindowLength, obj.Overlap, obj.Fs, 'Spectrogram', type);
                obj.TargetSpectrogram = Spectrogram(S, F, T, type);
            else
                error(strcat('Invalid argument "', identifier, '". Use either "Source" or "Target".'));
            end
        end
        
        function obj = synthesize(obj, synthMethod, costMetric, iterations, varargin)
            parser = inputParser;
            addRequired(parser, 'synthMethod');
            addRequired(parser, 'costMetric');
            addRequired(parser, 'iterations');
            addParameter(parser, 'repititionRestricted', false);
            addParameter(parser, 'continuityEnhanced', false);
            addParameter(parser, 'polyphonyRestricted', false);
            addParameter(parser, 'convergenceCriteria', 0.0005);
            addParameter(parser, 'r', 3);
            addParameter(parser, 'c', 2);
            addParameter(parser, 'p', 3);
            parse(parser, synthMethod, costMetric, iterations, varargin{:});
            
            repititionRestricted = parser.Results.repititionRestricted;
            continuityEnhanced = parser.Results.continuityEnhanced;
            polyphonyRestricted = parser.Results.polyphonyRestricted;
            convergenceCriteria = parser.Results.convergenceCriteria;
            r = parser.Results.r;
            c = parser.Results.c;
            p = parser.Results.p;
            
            if(strcmp(synthMethod, 'NNMF'))
                target=abs(obj.TargetSpectrogram.S);
%                 target(target == 0) = 1e-10;
                
                source=abs(obj.SourceSpectrogram.S);
%                 source(source == 0) = 1e-10;
                
                %H: templates x time
                %recon: reconstruction of target; frequency x time
                %cost: distance measure between target and reconstruction
                if(strcmp(costMetric, 'Fast Euclidean'))
                    [H, cost]=nnmfFn(target, source, iterations, 'repititionRestricted', repititionRestricted, 'continuityEnhanced', continuityEnhanced, ...
                                            'polyphonyRestricted', polyphonyRestricted, 'convergenceCriteria' , convergenceCriteria, ...
                                            'r', r, 'c', c, 'p', p);
                        
                    recon = obj.SourceSpectrogram.S*H;
                elseif(strcmp(costMetric, 'Fast Divergence'))
                    [H, cost]=nnmfFn_Div(target, source, iterations, 'repititionRestricted', repititionRestricted, 'continuityEnhanced', continuityEnhanced, ...
                        'polyphonyRestricted', polyphonyRestricted, 'convergenceCriteria' , convergenceCriteria, ...
                        'r', r, 'c', c, 'p', p);
                    
                    recon = obj.SourceSpectrogram.S*H;
                elseif(strcmp(costMetric, 'Euclidean'))
                    %                     For testing purposes
                    [H, cost]=nnmf_TEST(target, source, iterations, 'repititionRestricted', repititionRestricted, 'continuityEnhanced', continuityEnhanced, ...
                        'polyphonyRestricted', polyphonyRestricted, 'convergenceCriteria' , convergenceCriteria, ...
                        'r', r, 'c', c, 'p', p);
                    
                    recon = obj.SourceSpectrogram.S*H;
                elseif(strcmp(costMetric, 'Divergence'))
                    %                     For testing purposes
                    [H, cost]=nnmf_div_TEST(target, source, iterations, 'repititionRestricted', repititionRestricted, 'continuityEnhanced', continuityEnhanced, ...
                        'polyphonyRestricted', polyphonyRestricted, 'convergenceCriteria' , convergenceCriteria, ...
                        'r', r, 'c', c, 'p', p);
                    
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
%                 audiowrite('C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav', obj.Resynthesis, obj.Fs);
%                 audiowrite('resynthesis.wav', obj.Resynthesis, obj.Fs);
            elseif(strcmp(identifier, 'Template Addition'))
                if(~strcmp(obj.SourceSpectrogram.Type, 'Chroma'))
                    obj.Resynthesis = templateAdditionResynth(obj.Source, obj.NNMFSynthesis.Activations, obj.WindowLength, obj.Overlap);
                else
                    obj.Resynthesis = templateAdditionResynth(obj.Source, obj.NNMFSynthesis.Activations);
                end
%                 obj.Resynthesis(abs(obj.Resynthesis)>5)=mean(obj.Resynthesis);
%                 obj.Resynthesis=obj.Resynthesis/max(abs(obj.Resynthesis));
%                 audiowrite('C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav', obj.Resynthesis/max(abs(obj.Resynthesis)), obj.Fs);
%                 audiowrite('resynthesis.wav', obj.Resynthesis/max(abs(obj.Resynthesis)), obj.Fs);
            end
        end
        
        function showResynthesis(obj)
%             obj.Resynthesis(abs(obj.Resynthesis)>5)=mean(obj.Resynthesis);
%             obj.Resynthesis=obj.Resynthesis/max(abs(obj.Resynthesis));
            plot(obj.Resynthesis);
        end
        
        function showTemplates(obj)
            W=abs(obj.SourceSpectrogram.S);
            F=abs(obj.SourceSpectrogram.F);
            hold on; grid on;
            [~,I]=max(W);
            [~,Ix] = sort(I,'ascend');
            for jj=1:size(W,2)
                specdB=W(:,Ix(jj))/max(max(W));
                handle=plot3(jj*ones(size(W,1),1),F/1000,specdB, ...
                    'Color',power((size(W,2)-jj)/(size(W,2)+1),0.65)*ones(3,1), ...
                    'LineWidth',8*(2+size(W,2)-jj)/(size(W,2)));
            end
            ylabel('Frequency (kHz)');
            xlabel('Template');
            zlabel('Magnitude');
%             axis([-0.5 size(W,2)-0.5 0 F(end)/4000 0 1]);
            view(105,26);
        end
    end
end