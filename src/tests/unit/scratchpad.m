addpath(srcPath)
addpath(assetsPath)
%% Regular Synthesis
clear all
clc
portionLength = 5;
windowLength=100;
overlap=50;
[Y, Fs] = audioread('glock2.wav');
[Y2, Fs2] = audioread('sawtoothbirthday.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2))); 
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
synth.synthesize('NNMF', 'Euclidean', 20, true, false);
synth.NNMFSynthesis.showActivations(synth);
figure()
synth.NNMFSynthesis.showCost;
%% Article Replication Scratchpad
clear all
clc
portionLength = 5;
windowLength=100;
overlap=50;
[Y, Fs] = audioread('sawtoothbirthday.wav');
[Y2, Fs2] = audioread('sawtoothbirthday.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2))); 
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
synth.synthesize('NNMF', 'Euclidean', 100, false, true);
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
[Y, Fs] = audioread('sawtoothbirthday.wav');
[Y2, Fs2] = audioread('sawtoothbirthday.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2)));

%Compute Constant Q Spectrogram
% Start with the basic (linear-freq) spectrogram matxix
[S, F, T] = spectrogram(Y, 512);
spec = abs(S);
spec(spec==0)=1e-5;
D = log(spec);
% We're going to do the mapping in the log-magnitude domain
% so let's shift D so that a value of zero means something.
minD = min(min(D));
D = D - minD;
subplot(311)
imagesc(D); axis xy
colormap('jet');
c = caxis;
% Design the mapping matrix to lose no bins at the top but 5 at the bottom
[M,N] = logfmap(257,6,257);
size(M)
% Our 257 bin FFT expands to 1006 log-F bins
% Perform the mapping:
MD = M*spec;
% MD = M*D;
subplot(312)
imagesc(MD); axis xy
caxis(c);
% Map back to the original axis space, just to check that we can
NMD = N*MD;
subplot(313)
imagesc(NMD); axis xy
colormap('jet');
colorbar
caxis(c)

synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.SourceSpectrogram.S = MD;
synth.TargetSpectrogram.S = MD;
synth.synthesize('NNMF', 'Euclidean', 100, false, false);

synth.SourceSpectrogram.T = T;
synth.TargetSpectrogram.T = T;
figure()
synth.NNMFSynthesis.showActivations(synth);