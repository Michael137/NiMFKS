function [S,F,T] = computeSpectrogram(Y, winLength, hop, Fs, varargin)
    p = inputParser;
    addRequired(p, 'Y');
    addRequired(p, 'winLength');
    addRequired(p, 'hop');
    addRequired(p, 'Fs');
    addParameter(p, 'Spectrogram', 'Regular');
    parse(p, Y, winLength, hop, Fs, varargin{:});
    
    if(strcmp(p.Results.Spectrogram, 'Constant-Q'))
        %         Q = 50; %Quality Factor
        %         [S, F, T] = iir_cqt_spectrogram(p.Results.Y,2048*8,p.Results.hop,p.Results.Fs,Q); %TODO: Size of F and T are slightly miscalculated
        %         fprintf('CQT F: %d\n', length(F))
        %         fprintf('CQT T: %d\n', length(T))
        %         fprintf('Y: %d\n', length(p.Results.Y))
        %         fprintf('Frames: %d\n', ceil((length(p.Results.Y)/(p.Results.hop*Fs/1000))))
        %         fprintf('Frame Recalc: %d\n', floor((length(p.Results.Y)-p.Results.hop*Fs/1000)/abs((p.Results.hop*Fs/1000-length(p.Results.Y)/(p.Results.hop*Fs*2/1000)))))
        %
        %         padding = zeros(1, size(S, 2));
        %         S = [S; padding];
        fs = p.Results.Fs;
        fmin = 500;
        B = 48;
        gamma = 0;
        fmax = p.Results.Fs;
        x = p.Results.Y;
        x = x(:);
        
%         x = x(1:2*fs);
        
        xlen = length(x);
        
        Xcq = cqt(x, B, fs, fmin, fmax, 'rasterize', 'none', 'gamma', gamma);
        c = Xcq.c;
        [y gd] = icqt(Xcq);
        SNR = 20*log10(norm(x-y)/norm(x));
        disp(['reconstruction error = ' num2str(SNR) ' dB']);
        disp(['redundancy = ' num2str( (2*sum(cellfun(@numel,c)) + ...
            length(Xcq.cDC) + length(Xcq.cNyq)) / length(x))]);
        
        % figure; plotnsgtf({Xcq.cDC Xcq.c{1:end} Xcq.cNyq}.',Xcq.shift,fs,fmin,fmax,B,2,60);
        
        coeffs = Xcq.c;
        for i = 1:length(coeffs)
            lengths(i) = length(coeffs{i});
        end
        maxLen = max(lengths);
        
        for i = 1:length(coeffs)
            coeffs{i} = resample(coeffs{i}, maxLen, length(coeffs{i}));
        end
        
        coeffMat = zeros(length(coeffs), maxLen);
        for i = 1:length(coeffs)
            coeffMat(i, :) = coeffs{i}(:);
        end
        
%         S=20*log10(abs(coeffMat)/max(max(abs(coeffMat))));
        S=coeffMat;
        T=size(S, 2);
        F=size(S, 1);
    elseif(strcmp(p.Results.Spectrogram, 'Regular'))
        [S,F,T]=spectrogram(p.Results.Y, window(@hann,(p.Results.winLength)), p.Results.hop, 2048*8, p.Results.Fs); %F: normalized frequencies; T: Time instants
        %         [S,F,T]=spectrogram(p.Results.Y, window(@hann,(p.Results.winLength)), p.Results.hop, 2048*8-1, p.Results.Fs); %F: normalized frequencies; T: Time instants
        fprintf('Reg F: %d\n', length(F))
        fprintf('Reg T: %d\n', length(T))
        fprintf('Y: %d\n', length(p.Results.Y))
        fprintf('Frames: %d\n', ceil((length(p.Results.Y)/(p.Results.hop*Fs/1000))))
        fprintf('Frame Recalc: %d\n', floor(abs((length(p.Results.Y)-p.Results.hop*Fs/1000))/abs((p.Results.hop*Fs/1000-length(p.Results.Y)/(p.Results.hop*Fs*2/1000)))))
    elseif(strcmp(p.Results.Spectrogram, 'Chroma'))
        % Calculate the chroma matrix.  Use a long FFT to discriminate
        % spectral lines as well as possible (2048 is the default value)
        cfftlen=2048;
        C = chromagram_IF(p.Results.Y,p.Results.Fs,cfftlen);
        % The frame advance is always one quarter of the FFT length.  Thus,
        % the columns  of C are at timebase of fftlen/4/sr
        C = resample(C', 1, 2)';
        tt = [1:size(C,2)]*cfftlen/4/p.Results.Fs;
        sfftlen = 512;
        S=(C+eps);
        F=[1:12];
        T=tt;
    end
end