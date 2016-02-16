%                             IIR-CQT Example
%          2009  -   Universidad de La Repúplica Oriental del Uuguay 
%            Authors: Pablo Cancela, Ernesto López, Martín Rocamora
%
% This example computes a multi-resolution spectrogram using recursive filters.
%
% The spectrum of the signal frame x is filtered using an IIR filter of one
% zero and one pole. This corresponds to a multiplication in the time domain
% between the signal frame and a window being the frequency response of
% the IIR filter. The zero is located at -1 in the Z-plane to force a time
% window that is zero in its extremes. The location of the pole varies
% for each frequency bin along the real axis in order to obtain different
% time window widths (typically wider for lower frequencies and narrower
% for higher ones), giving the multi-resolution behavior of the transform.
% Thus the filter is an IIR Linear Time Variant. The recursive equation of
% the filter is: y[n]=x[n]+x[n+1]+poles[n]*y[n-1]
% The filter is applied in forward direction followed by reverse filtering
% to obtain zero-phase distortion (and magnitude modified by the square of
% the filter's magnitude response).

clear all
close all

disp('                       IIR-CQT Spectrogram Example');
disp('          2009  -   Universidad de La Repúplica Oriental del Uuguay ');
disp('            Authors: Pablo Cancela, Ernesto López, Martín Rocamora');

nq = 4096;
nfft = 4096;
hop = 256;
Q = 13;



% Load the example excerpt
[y,fs] = audioread('example1.wav');

disp('Calculating STFT Spectrogram.')
tic
[s,f,t,p] = spectrogram(y,hanning(nfft),nfft-hop,nfft,fs); 
toc

disp('Calculating Q Spectrogram based on IIR CQT.')
tic
[s_q, f_q, t_q] = iir_cqt_spectrogram(y,nfft,hop,fs,Q);
toc

%% plots

bias = 0.001;

% Calculo de espectros en dB
stft_dB = 20*log10(abs(s*4/nfft)+bias);
q_stft_dB = 20*log10(abs(s_q)+bias);

max_freq = 10000;

[m,kmax_sfft] = min(abs(f-max_freq));
[m,kmax_q] = min(abs(f_q-max_freq));

figure()
subplot(2,1,1)
imagesc(t,f(1:kmax_sfft),-stft_dB(1:kmax_sfft,:));
colormap('gray');
set(gca,'YDir','normal')
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('STFT Spectrogram (magnitude in dB)') 

subplot(2,1,2)
imagesc(t_q,f_q(1:kmax_q),-q_stft_dB(1:kmax_q,:))
colormap('gray');
set(gca,'YDir','normal')
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Constant Q Spectrogram (magnitude in dB) using the IIR CQT') 
