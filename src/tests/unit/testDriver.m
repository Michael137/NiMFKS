clear all
clc
portionLength = 1;
windowLength=100;
overlap=50;
[Y, Fs] = audioread('sawtoothbirthday.wav');
[Y2, Fs2] = audioread('glock2.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2)));
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
% synth.SourceSpectrogram.showSpectrogram(80);
% synth.TargetSpectrogram.showSpectrogram(80);
% synth.synthesize('NNMF', 'Divergence', 10); %TODO: Divergence computational time too large
synth.synthesize('NNMF', 'Divergence', 100);
% synth.NNMFSynthesis.showCost;
synth.NNMFSynthesis.showActivations(synth);
% synth.resynthesize('ISTFT');
% synth.resynthesize('Template Addition');
% synth.showResynthesis;