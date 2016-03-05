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
synth.synthesize('NNMF', 'Euclidean', 20, 'repititionRestricted', true, 'continuityEnhanced', false, 'polyphonyRestricted', false, 'convergenceCriteria', convergence);
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
synth.synthesize('NNMF', 'Euclidean', 100, 'repititionRestricted', true, 'continuityEnhanced', false, 'polyphonyRestricted', false, 'convergenceCriteria', convergence);
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
synth.synthesize('NNMF', 'Euclidean', 20);
subplot(223)
synth.NNMFSynthesis.showActivations(synth);
subplot(224)
synth.NNMFSynthesis.showCost;


fig2plotly()

synth.resynthesize('ISTFT')
figure()
synth.showResynthesis;
fig2plotly()
% soundsc(synth.Resynthesis, Fs);
%% Input parser test
parseResult = inputParser_TEST(100, 40, 'windowLength', 20);
parseResult.fs
%% Creating musical scale using sin waves

Fs=44100;
Ts=1/Fs;
t=[0:Ts:0.5];

%f_i=440*2^i/12

soundMix = [];
win = window(@hann, length(t))';

for freq = 110*2.^([-12:24*8]/24)
    soundMix=[soundMix, win.*sin(2*pi*(freq)*t)];
end

% sound(soundMix, Fs)
audiowrite('SinScale.wav', soundMix, Fs);

%Add ADSR envelope
%Fix template addition when used with CQT's
%Divergence Restriction: DONE
%Restriction GUI parameters: DONE
%Experiments: save sound files
%Add save feature in GUI: DONE
%Conference paper outline
%Pre-processing templates and manipulating activations based on feature comparison
%Activation sketching
%% Activation Sketching
figure('WindowButtonDownFcn',@wbdcb)
ah = axes;
axis([1 10 1 10])
title('Click and drag')
%% Template Manipulation
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
showTemplates(abs(synth.SourceSpectrogram.S), synth.SourceSpectrogram.F);
% figure()
% showTemplates(abs(synth.TargetSpectrogram.S), synth.TargetSpectrogram.F);
h = findobj(gca,'Type','line');
set(gcf, 'WindowScrollWheelFcn', {@wscb, h});
set(gcf, 'WindowKeyPressFcn', @wkpcb);
%% Testing plot.ly API
imagesc(magic(5))
fig2plotly()
%% Griffin-Lim Algorithm Test
clear all
clc
portionLength = 15;
windowLength=100;
overlap=50;
convergence = 0.00005;
[Y, Fs] = audioread('glock2.wav');
[Y2, Fs2] = audioread('glock2.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2))); 
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
synth.synthesize('NNMF', 'Euclidean', 20, 'repititionRestricted', true, 'continuityEnhanced', false, 'polyphonyRestricted', false, 'convergenceCriteria', convergence);

figure()
% synth.resynthesize('ISTFT'); % Method 1
% synth.resynthesize('Template Addition'); % Method 2
spect = synth.NNMFSynthesis.Reconstruction; % Method 3
[synth.Resynthesis error] = InvertSpectrogram(spect(1:size(spect, 1)-1, :), 1000, 20);
synth.showResynthesis;
soundsc(synth.Resynthesis, Fs/2)
%% Synthesis Experiments
clear all
clc

figure()

load('synth1')

subplot(232)
synthObj.showResynthesis;
subplot(233)
synthObj.SourceSpectrogram.showSpectrogram(80);
subplot(234)
synthObj.TargetSpectrogram.showSpectrogram(80);
subplot(231)
resynthSpectrogram = Spectrogram(synthObj.NNMFSynthesis.Reconstruction, ...
                                        synthObj.TargetSpectrogram.F, synthObj.TargetSpectrogram.T);
resynthSpectrogram.showSpectrogram(80);
subplot(235)
synthObj.NNMFSynthesis.showActivations(synthObj);

figure()

load('synth2')

subplot(232)
synthObj.showResynthesis;
subplot(233)
synthObj.SourceSpectrogram.showSpectrogram(80);
subplot(234)
synthObj.TargetSpectrogram.showSpectrogram(80);
subplot(231)
resynthSpectrogram = Spectrogram(synthObj.NNMFSynthesis.Reconstruction, ...
                                        synthObj.TargetSpectrogram.F, synthObj.TargetSpectrogram.T);
resynthSpectrogram.showSpectrogram(80);
subplot(235)
synthObj.NNMFSynthesis.showActivations(synthObj);

figure()

load('synth3')

subplot(232)
synthObj.showResynthesis;
subplot(233)
synthObj.SourceSpectrogram.showSpectrogram(80);
subplot(234)
synthObj.TargetSpectrogram.showSpectrogram(80);
subplot(231)
resynthSpectrogram = Spectrogram(synthObj.NNMFSynthesis.Reconstruction, ...
                                        synthObj.TargetSpectrogram.F, synthObj.TargetSpectrogram.T);
resynthSpectrogram.showSpectrogram(80);
subplot(235)
synthObj.NNMFSynthesis.showActivations(synthObj);

figure()

load('synth4')

subplot(232)
synthObj.showResynthesis;
subplot(233)
synthObj.SourceSpectrogram.showSpectrogram(80);
subplot(234)
synthObj.TargetSpectrogram.showSpectrogram(80);
subplot(231)
resynthSpectrogram = Spectrogram(synthObj.NNMFSynthesis.Reconstruction, ...
                                        synthObj.TargetSpectrogram.F, synthObj.TargetSpectrogram.T);
resynthSpectrogram.showSpectrogram(80);
subplot(235)
synthObj.NNMFSynthesis.showActivations(synthObj);
%% Resynthesis after set of iterations

%Save normalized and non-normalized activations
%Save resynthesis
%Save resynthesis plots
%Save cost

clear all
clc
portionLength = 5;
windowLength=400;
overlap=200;
convergence = 0;
iterations = 26;
[Y, Fs] = audioread('sinScale.wav');
[Y2, Fs2] = audioread('string_quartet_snippet.wav');
Y2=Y2(1:min(portionLength*Fs, length(Y2)));
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');

target=abs(synth.TargetSpectrogram.S);
target(target == 0) = 1e-10;

source=abs(synth.SourceSpectrogram.S);
source(source == 0) = 1e-10;

[~, cost, Hmat, Hnorm] = nnmf_TEST(target, source, iterations, 'convergenceCriteria', 0);

for l = 1:iterations-1
%     resynthesis(l, :) = templateAdditionResynth(Y, abs(Hmat{l}), 400*Fs/1000, 200*Fs/1000);
    resynthesis(l, :) = istft(synth.SourceSpectrogram.S*Hmat{l}, overlap*Fs/1000, 2048*8, Fs, hann(2048*8, 'periodic'));
end

figure()

for l = 1:iterations-1
    subplot(ceil(sqrt(iterations)), ceil(sqrt(iterations)), l)
    plot(resynthesis(l, :))
end

save('act_iter_test', 'resynthesis', 'Hmat', 'Hnorm', 'cost')
%% Constant-Q Tests
clear all
clc
windowLength=400;
hop=50;
[Y, Fs] = audioread('sinScale.wav');

Q = 50; %Quality Factor
[S, F, T] = iir_cqt_spectrogram_TEST(Y,2048*8,hop*Fs/1000,Fs,Q); %TODO: Size of F and T are slightly miscalculated
% padding = zeros(1, size(S, 2));
% S = [S; padding];
fprintf('CQT F: %d\n', length(F))
fprintf('CQT T: %d\n', length(T))
fprintf('Y: %d\n', length(Y))
fprintf('Frames: %d\n\n', ceil((length(Y)/(hop*Fs/1000))))
cqt_resynth = templateAdditionResynth(Y, zeros(length(T), length(F)), Fs*windowLength/1000, Fs*hop/1000);
disp(size(cqt_resynth))

[S,F,T]=spectrogram(Y, window(@hann,(windowLength*Fs/1000)), Fs*hop/1000, 2048*8, Fs); %F: normalized frequencies; T: Time instants
fprintf('Reg F: %d\n', length(F))
fprintf('Reg T: %d\n', length(T))
fprintf('Y: %d\n', length(Y))
fprintf('Frames: %d\n\n', ceil((length(Y)/(hop*Fs/1000))))
reg_resynth = templateAdditionResynth(Y, zeros(length(T), length(F)), Fs*windowLength/1000, Fs*hop/1000);
disp(size(reg_resynth))
%% Update NNMF Restrictions
clear all
clc
portionLength = 5;
windowLength=400;
overlap=200;
convergence = 0;
[Y, Fs] = audioread('Bees_Buzzing.wav');
[Y2, Fs2] = audioread('Beatles_LetItBe.wav');
% Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2))); 
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
synth.synthesize('NNMF', 'Euclidean', 20, 'repititionRestricted', true, 'continuityEnhanced', true, 'polyphonyRestricted', true, 'convergenceCriteria', convergence);
synth.NNMFSynthesis.showActivations(synth, -120);