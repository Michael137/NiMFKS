function plotChromagram(file, time)

[d,sr] = audioread(file);
d=d(:, 1);
d=d(1:min(length(d), time*sr));
% Calculate the chroma matrix.  Use a long FFT to discriminate
% spectral lines as well as possible (2048 is the default value)
cfftlen=2048;
C = chromagram_IF(d,sr,cfftlen);
% The frame advance is always one quarter of the FFT length.  Thus,
% the columns  of C are at timebase of fftlen/4/sr
tt = [1:size(C,2)]*cfftlen/4/sr;
% % Plot spectrogram using a shorter window
% figure()
% subplot(211)
% sfftlen = 512;
% specgram(d,sfftlen,sr);
% % Always use a 60 dB colormap range
% caxis(max(caxis)+[-60 0])
% % .. and look only at the bottom 4 kHz of spectrum
% axis([0 length(d)/sr 0 4000])
% title('Original Sound')
% % Now the chromagram, also on a dB magnitude scale
% subplot(212)
imagesc(tt,[1:12],20*log10(C+eps));
axis xy
caxis(max(caxis)+[-60 0])
title(strcat(strtok(file, '_'), ' Chromagram'))
colorbar