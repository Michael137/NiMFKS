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


% fig2plotly()

synth.resynthesize('ISTFT')
figure()
synth.showResynthesis;
% fig2plotly()
% soundsc(synth.Resynthesis, Fs);
%% Input parser test
parseResult = inputParser_TEST(100, 40, 'windowLength', 20);
parseResult.fs
%% Creating musical scale using sin waves

Fs=44100;
Ts=1/Fs;
t=[0:Ts:0.1];

%f_i=440*2^i/12

soundMix = [];
win = window(@hann, length(t))';

for freq = 110*2.^([-12:24*8]/24)
    soundMix=[soundMix, win.*sin(2*pi*(freq)*t)];
end

%Reverse sound scale
% soundMix = fliplr(soundMix);

% soundsc(soundMix, Fs)
% spectrogram(soundMix)
audiowrite('sinScale_v2.wav', soundMix, Fs);

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

workspaces = {'synth3' ...
    'synth4' ...
    'synth7' ...
    'synth8' ...
    'synth11' ...
    'synth12' ...
    'synth15' ...
    'synth16' ...
    'synth17' ...
    'synth18' ...
    'synth19' ...
    'synth20' ...
    'synth21' ...
    'synth22' ...
    'synth23' ...
    'synth24' ...
    }

for i = 1:length(workspaces)
    figure()
    
    load(workspaces{i})
    if(i>1)
        clear(workspaces{i-1})
    end
    
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
    title(workspaces{i})
    subplot(235)
    synthObj.NNMFSynthesis.showActivations(synthObj, -30);
    subplot(236)
    synthObj.NNMFSynthesis.showCost;
end
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
%% Update NNMF Restrictions (Euclidean)
clear all
clc
portionLength = 2;
windowLength=100;
overlap=50;
convergence = 0;
[Y, Fs] = audioread('glock2.wav');
[Y2, Fs2] = audioread('glock2.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2))); 
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
synth.synthesize('NNMF', 'Euclidean', 10, 'repititionRestricted', true, 'continuityEnhanced', true, 'polyphonyRestricted', true, 'convergenceCriteria', convergence);
synth.NNMFSynthesis.showActivations(synth, -120);
%% Update NNMF Restrictions (Divergence)
clear all
clc
portionLength = 2;
windowLength=100;
overlap=50;
convergence = 0;
[Y, Fs] = audioread('glock2.wav');
[Y2, Fs2] = audioread('glock2.wav');
Y=Y(1:min(portionLength*Fs, length(Y)));
Y2=Y2(1:min(portionLength*Fs, length(Y2))); 
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
synth.synthesize('NNMF', 'Divergence', 10, 'repititionRestricted', true, 'continuityEnhanced', true, 'polyphonyRestricted', true, 'convergenceCriteria', convergence);
synth.NNMFSynthesis.showActivations(synth, -120);
%% CQT Toolbox Tests
clear
clc
fs = 44100;
fmin = 500;
B = 48;
gamma = 0; 
fmax = fs;
x = audioread('glock2.wav');
x = x(:);

x = x(1:2*fs);

xlen = length(x);

Xcq = cqt(x, B, fs, fmin, fmax, 'rasterize', 'none', 'gamma', gamma);
c = Xcq.c;
[y gd] = icqt(Xcq);
SNR = 20*log10(norm(x-y)/norm(x));
disp(['reconstruction error = ' num2str(SNR) ' dB']);

if iscell(c)
   disp(['redundancy = ' num2str( (2*sum(cellfun(@numel,c)) + ...
       length(Xcq.cDC) + length(Xcq.cNyq)) / length(x))]); 
elseif issparse(c)
   disp(['redundancy = ' num2str( (2*nnz(c) + length(Xcq.cDC) + ...
       length(Xcq.cNyq)) / length(x))]);  
else
   disp(['redundancy = ' num2str( (2*size(c,1)*size(c,2) + ...
       length(Xcq.cDC) + length(Xcq.cNyq)) / length(x))]); 
end

% figure; plotnsgtf({Xcq.cDC Xcq.c{1:end} Xcq.cNyq}.',Xcq.shift,fs,fmin,fmax,B,2,60);

[S,F,T] = spectrogram(x, window(@hann, 400*44100/1000), 200*44100/1000, 2048*8, 44100);
spect = Spectrogram(S, F, T);
figure()
spect.showSpectrogram(80);

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

db=20*log10(abs(coeffMat)/max(max(abs(coeffMat))));
figure()
imagesc(db)
axis xy
colormap('jet')
colorbar
title('Glockenspiel Spectrogram')

H = nnmfFn(abs(coeffMat), abs(coeffMat), 35, 'convergenceCriteria', 0);
figure()
imagesc(H)
title('Glockenspiel-Glockenspiel Activations')
axis xy
resynth = templateAdditionResynth(x, H);