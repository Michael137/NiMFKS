function [S,F,T] = computeSpectrogram(Y, winLength, hop, Fs)    
    [S,F,T]=spectrogram(Y, window(@hann,(winLength)), hop, 2048*8, Fs); %F: normalized frequencies; T: Time instants
%     if(plotSonogram)
%         numTemplates=length(T);
%         mindB = 80;
%         sonodB = 20*log10(abs(S)/max(max(abs(S))));
%         plotsonogram_func(mindB, sonodB, T, F, Fs, portion);
% %         print(gcf,'-dpng',[targetFile '.png']);
%     end
end