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
            end
            
            obj.init;
        end
        
        function obj = init(obj)
            if ~isempty(obj.Filename)
                [Y, Fs] = audioread(obj.Filename);
                obj.Signal = Y;
                obj.Sampling_rate = Fs;
                obj.Time_length = length(Y)/Fs;

                info = audioinfo(obj.Filename);
                obj.Bits_per_sample = info.BitsPerSample;

                obj.Audioplayer= audioplayer(Y, obj.Sampling_rate);
            end
        end
    end
    
    methods
        function control_audio(obj, action)
            switch action
                case 'play'
                    obj.Audioplayer.play;
                case 'stop'
                    obj.Audioplayer.stop;
                case 'pause'
                    obj.Audioplayer.pause;
                case 'resume'
                    obj.Audioplayer.resume;
            end
        end
        
%         function save_audio()
%             [file,path] = uiputfile({'*.wav'},'Save Sound As');
%             audiowrite([path filesep file], obj.Signal, handles.SynthesisObject.Fs);
%         end
        
        function plot_spectrogram()
        end
        
        function plot_chromagram()
        end
        
        function plot_templates()
        end
        
        function plot_signal(obj)
            plot([1:length(obj.Signal)]/obj.Sampling_rate, obj.Signal, 'Color', [0, 0, 0]);
        end
    end
end