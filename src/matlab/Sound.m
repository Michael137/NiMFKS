classdef Sound < handle
    properties
        Filename
        Directory
        Sampling_rate
        Bits_per_sample
        Audioplayer
        Time_length
        Signal
        Features
    end
    
    methods
        function obj = Sound(varargin)
            if nargin == 1
                [pathstr, name, ext] = fileparts(varargin{1});
                obj.Filename = strcat(name, ext);
                obj.Directory = pathstr;
            elseif nargin == 2
                obj.Signal = varargin{1};
                obj.Sampling_rate = varargin{2};
            end
            
            obj.init;
        end
        
        function obj = init(obj)
            if ~isempty(obj.Filename)
                [Y, Fs] = audioread([obj.Directory filesep obj.Filename]);
                
                %Convert to Monophonic sound
                if(size(Y, 2) ~= 1)
                    Y = (Y(:,1)+Y(:,2))/2;
                end
                
                obj.Signal = Y;
                obj.Sampling_rate = Fs;
            end
            
            obj.Time_length = length(obj.Signal)/obj.Sampling_rate;
            
            obj.Audioplayer= audioplayer(obj.Signal, obj.Sampling_rate);
            obj.Bits_per_sample = obj.Audioplayer.BitsPerSample;
        end
    end
    
    methods
        function control_audio(obj, action)
            switch action
                case 'play'
                    play(obj.Audioplayer);
                case 'stop'
                    stop(obj.Audioplayer);
                case 'pause'
                    obj.Audioplayer.pause;
                case 'resume'
                    obj.Audioplayer.resume;
            end
        end
        
        function save_audio(obj)
            handles = guidata(gcf);
            [file,path] = uiputfile({'*.wav'},'Save Sound As');
            audiowrite([path filesep file], handles.SynthesisObject.Synthesis, handles.Sound_corpus.Sampling_rate);
        end
        
        function plot_spectrogram(obj, varargin)
            if nargin > 1
                mindB = varargin{1};
            else
                mindB = 80;
            end
            
            S = obj.Features.STFT.S;
            F = obj.Features.STFT.F;
            T = obj.Features.STFT.T;
            
            dB = 20*log10(abs(S)/max(max(abs(S))));
            sonodB = max(-mindB, dB);
            imagesc(T,F./1000,sonodB);
            cmap = colormap('jet');
            cmap(1,:) = 0*ones(1,3);
            colormap((cmap));
            colorbar
            axis xy; grid on;
            axis([0 T(end) 0.01 10]);
            set(gca,'XTick',[0:0.5:T(end)],'XTickLabel','');
            set(gca, 'Layer', 'top');
            ylabel('Frequency (kHz)');
            grid on;
            set(gca,'FontSize',16);
        end
        
        function plot_chromagram()
        end
        
        function plot_templates(obj)
            W=abs(obj.Features.STFT.S);
            F=abs(obj.Features.STFT.F);
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
            view(105,26);
        end
        
        function plot_signal(obj)
            plot([1:length(obj.Signal)]/obj.Sampling_rate, obj.Signal, 'Color', [0, 0, 0]);
        end
        
        function obj = computeFeatures(obj, window, analysis)
            obj.Features.window = window;
            
            if(strcmp(analysis, 'STFT'))
                obj.Features.STFT = computeSTFTFeat(obj.Signal, obj.Sampling_rate, obj.Features.window);
            elseif(strcmp(analysis, 'CQT'))

            elseif(strcmp(analysis, 'Chroma'))
                
            end
        end
    end
end