classdef Spectrogram < handle
    properties
        S
        F
        T
    end
    
    methods
        function obj = Spectrogram(varargin)
            if nargin > 0
                obj.S= varargin{1};
                obj.F= varargin{2};
                obj.T= varargin{3};                
            else
                error('Wrong number of input arguments');
            end
        end
    end
    methods
        function showSpectrogram(spectObj, mindB)
            S = spectObj.S;
            F = spectObj.F;
            T = spectObj.T;
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
    end
end