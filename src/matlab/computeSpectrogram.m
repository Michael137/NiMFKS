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
        [S, F, T] = iir_cqt_spectrogram(p.Results.Y,2048*8,p.Results.hop,p.Results.Fs,Q);
        padding = zeros(1, size(S, 2));
        S = [S; padding];
    elseif(strcmp(p.Results.Spectrogram, 'Regular'))
        [S,F,T]=spectrogram(p.Results.Y, window(@hann,(p.Results.winLength)), p.Results.hop, 2048*8, p.Results.Fs); %F: normalized frequencies; T: Time instants
    end
end