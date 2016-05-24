function feature_struct = computeSTFTFeat(x, fs, win)
    wintype = win.Type;
    winlen = win.Length;
    hop = win.Hop;
    
    analysis_window = createWindow(winlen, hop, wintype);
    
    [feature_struct.S, feature_struct.F, feature_struct.T]=spectrogram(x, analysis_window, hop, winlen, fs);
end

function win = createWindow(winlen, hop, wintype)
    switch wintype
        case 'Hann'
            win = window(@hann, winlen);
        case 'Sine'
            win = window(@sin, winlen);
        case 'Tukey'
            win = tukeywin(winlen, 0.75);
        case 'Hamming'
            win = window(@hamming, winlen);
    end
end