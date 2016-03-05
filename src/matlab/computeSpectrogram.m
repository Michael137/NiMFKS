function [S,F,T] = computeSpectrogram(Y, winLength, hop, Fs, varargin)
    p = inputParser;
    addRequired(p, 'Y');
    addRequired(p, 'winLength');
    addRequired(p, 'hop');
    addRequired(p, 'Fs');
    addParameter(p, 'Spectrogram', 'Regular');
    parse(p, Y, winLength, hop, Fs, varargin{:});
    
    if(strcmp(p.Results.Spectrogram, 'Constant-Q'))
        Q = 50; %Quality Factor
        [S, F, T] = iir_cqt_spectrogram(p.Results.Y,2048*8,p.Results.hop,p.Results.Fs,Q); %TODO: Size of F and T are slightly miscalculated
        fprintf('CQT F: %d\n', length(F))
        fprintf('CQT T: %d\n', length(T))
        fprintf('Y: %d\n', length(p.Results.Y))
        fprintf('Frames: %d\n', ceil((length(p.Results.Y)/(p.Results.hop*Fs/1000))))
        fprintf('Frame Recalc: %d\n', floor((length(p.Results.Y)-p.Results.hop*Fs/1000)/abs((p.Results.hop*Fs/1000-length(p.Results.Y)/(p.Results.hop*Fs*2/1000)))))
        
        padding = zeros(1, size(S, 2));
        S = [S; padding];
    elseif(strcmp(p.Results.Spectrogram, 'Regular'))
        [S,F,T]=spectrogram(p.Results.Y, window(@hann,(p.Results.winLength)), p.Results.hop, 2048*8, p.Results.Fs); %F: normalized frequencies; T: Time instants
%         [S,F,T]=spectrogram(p.Results.Y, window(@hann,(p.Results.winLength)), p.Results.hop, 2048*8-1, p.Results.Fs); %F: normalized frequencies; T: Time instants
        fprintf('Reg F: %d\n', length(F))
        fprintf('Reg T: %d\n', length(T))
        fprintf('Y: %d\n', length(p.Results.Y))
        fprintf('Frames: %d\n', ceil((length(p.Results.Y)/(p.Results.hop*Fs/1000))))
        fprintf('Frame Recalc: %d\n', floor(abs((length(p.Results.Y)-p.Results.hop*Fs/1000))/abs((p.Results.hop*Fs/1000-length(p.Results.Y)/(p.Results.hop*Fs*2/1000)))))
    end
end