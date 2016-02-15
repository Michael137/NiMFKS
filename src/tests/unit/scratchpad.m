% addpath(srcPath)
% addpath(assetsPath)
addpath(totalPath)
%% Regular Synthesis
clear all
clc
portionLength = 1;
windowLength=100;
overlap=50;
convergence = 0.0005;
[Y, Fs] = audioread('glock2.wav');
[Y2, Fs2] = audioread('sawtoothbirthday.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2))); 
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
synth.synthesize('NNMF', 'Euclidean', 20, true, false, false, convergence);
synth.NNMFSynthesis.showActivations(synth);
figure()
synth.NNMFSynthesis.showCost;
%% Article Replication Scratchpad
clear all
clc
portionLength = 5;
windowLength=100;
overlap=50;
convergence = 0.0005;
[Y, Fs] = audioread('glock2.wav');
[Y2, Fs2] = audioread('sawtoothbirthday.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2))); 
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
synth.synthesize('NNMF', 'Euclidean', 100, false, false, false, convergence);
synth.NNMFSynthesis.showActivations(synth);
figure()
synth.resynthesize('ISTFT');
synth.showResynthesis;
% K = 10;
% M = 10;
% H = ones(K, M);
% c = 2;
% kernelSum = 0;
% 
% for k = 1:K
%     for m = 1:M
%         if(k > c && m > c && k < K-c && m < M-c)
%                     kernelSum = 0;
%                     for z = -c:1:c;
%                         kernelSum = kernelSum + H(k+z, m+z);
%                     end
%                     C(k, m) = kernelSum;
%         else
%             C(k, m) = H(k, m);
%         end
%     end
% end
% imagesc(H)
% figure()
% imagesc(C)
%% Constant Q Spectrograms
clear all
clc
portionLength = 5;
windowLength=100;
overlap=50;
convergence = 0.000005;
[Y, Fs] = audioread('sawtoothbirthday.wav');
[Y2, Fs2] = audioread('sawtoothbirthday.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2)));

Q = 50;
[s_q, f_q, t_q] = iir_cqt_spectrogram(Y,2048*8,windowLength*Fs/2000,Fs,Q);
[s_q2, f_q2, t_q2] = iir_cqt_spectrogram(Y,2048*8,windowLength*Fs/2000,Fs,Q);
padding = zeros(1, size(s_q, 2));
padding2 = zeros(1, size(s_q2, 2));
s_q = [s_q; padding];
s_q2 = [s_q2; padding2];

synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source')
synth.computeSpectrogram('Target')
synth.SourceSpectrogram = Spectrogram(s_q, f_q, t_q);
synth.TargetSpectrogram = Spectrogram(s_q2, f_q2, t_q2);
subplot(221)
synth.SourceSpectrogram.showSpectrogram(80);
subplot(222)
synth.TargetSpectrogram.showSpectrogram(80);
synth.synthesize('NNMF', 'Euclidean', 20, true, false, false, convergence);
subplot(223)
synth.NNMFSynthesis.showActivations(synth);
subplot(224)
synth.NNMFSynthesis.showCost;

synth.resynthesize('ISTFT')
figure()
synth.showResynthesis;
soundsc(synth.Resynthesis, Fs);
%% Input parser test
parseResult = inputParser_TEST(100, 40, 'windowLength', 20);
parseResult.fs