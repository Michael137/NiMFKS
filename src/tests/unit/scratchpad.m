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
[Y, Fs] = audioread('RaceCar_Engine_resampled.wav');
[Y2, Fs2] = audioread('Bees_Buzzing_resampled.wav');
% Y=Y(1:min(portionLength*Fs, length(Y)));
% Y2=Y2(1:min(portionLength*Fs, length(Y2))); 
synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
synth.computeSpectrogram('Source');
synth.computeSpectrogram('Target');
synth.SourceSpectrogram.showSpectrogram(80);
figure()
synth.TargetSpectrogram.showSpectrogram(80);
% synth.synthesize('NNMF', 'Euclidean', 20, 'repititionRestricted', true, 'continuityEnhanced', false, 'polyphonyRestricted', false, 'convergenceCriteria', convergence);
% synth.NNMFSynthesis.showActivations(synth);
% figure()
% synth.NNMFSynthesis.showCost;
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
windowLength=100;
overlap=50;
convergence = 0.000005;
[Y, Fs] = audioread('sawtoothbirthday.wav');
[Y2, Fs2] = audioread('sawtoothbirthday.wav');

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
win = win(@hann, length(t))';

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

workspaces = {
    'ChainsawOsbourne (Fast Restriction Comparison)' ...
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

[S,F,T]=spectrogram(Y, win(@hann,(windowLength*Fs/1000)), Fs*hop/1000, 2048*8, Fs); %F: normalized frequencies; T: Time instants
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

[S,F,T] = spectrogram(x, win(@hann, 400*44100/1000), 200*44100/1000, 2048*8, 44100);
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
%% Chromagram Tests

% Read an audio waveform
[d,sr] = audioread('glock2.wav');
d=d(:, 1);
% d=d(1:8*sr);

[d2,sr] = audioread('glock2.wav');
d2=d2(:, 1);
d2=d2(1:8*sr);

% Calculate the chroma matrix.  Use a long FFT to discriminate
% spectral lines as well as possible (2048 is the default value)
cfftlen=2048;
C = chromagram_IF(d,sr,cfftlen);
C2 = chromagram_IF(d2,sr,cfftlen);
% The frame advance is always one quarter of the FFT length.  Thus,
% the columns  of C are at timebase of fftlen/4/sr
tt = [1:size(C,2)]*cfftlen/4/sr;
tt2 = [1:size(C2,2)]*cfftlen/4/sr;
% Plot spectrogram using a shorter window
% subplot(311)
% sfftlen = 512;
% specgram(d,sfftlen,sr);
% % Always use a 60 dB colormap range
% caxis(max(caxis)+[-60 0])
% % .. and look only at the bottom 4 kHz of spectrum
% axis([0 length(d)/sr 0 4000])
% title('Original Sound')
% % Now the chromagram, also on a dB magnitude scale
% subplot(312)
figure()
imagesc(tt,[1:12],20*log10(C+eps));
axis xy
caxis(max(caxis)+[-60 0])
title('Source Chromagram')

figure()
imagesc(tt2,[1:12],20*log10(C2+eps));
axis xy
caxis(max(caxis)+[-60 0])
title('Target Chromagram')

% % chromsynth takes a chroma matrix as the first argument, the
% % *period* (in seconds) corresponding to each time frame, and
% % the sampling rate for the waveform to be generated.
% x = chromsynth(C,cfftlen/4/sr,sr);
% % Plot this alongside the others to see how it differs
% subplot(313)
% specgram(x,sfftlen,sr);
% caxis(max(caxis)+[-60 0])
% axis([0 length(d)/sr 0 4000])
% title('Shepard tone synthesis')
% % Of course, the main point is to listen to the resynthesis:
% % soundsc(x,sr);

% figure()
% db=20*log10(abs(C)/max(max(abs(C))));
% imagesc(db)
% axis xy
% colormap('jet')
% colorbar
% title('Glockenspiel Chromagram')

% C(C==0)=1E-6;
C = resample(C', 1, 2)';
C2 = resample(C2', 1, 2)';
% H = nnmfFn(abs(C'), abs(C'), 36, 'convergenceCriteria', 0);
H = nnmfFn(abs(C), abs(C2), 15, 'convergenceCriteria', 0);
figure()
db_H = 20*log10(H./max(max(H)));
imagesc(max(-30, db_H));
title('Activations')
axis xy; colormap(flipud(colormap('gray')));colorbar;
resynth = templateAdditionResynth(d, H);

figure()
subplot(211)
plot(resynth)
subplot(212)
plot(d)

% soundsc(resynth, sr/2);

%TODO: resample rows of C
%% Constructing source sounds for experiments
[y, fs] = audioread('drum.wav');
y = y(:,1);
% y2 = interp(y, 2);
% y3 = interp(y, 3);
% y4 = interp(y, 4);
% y5 = interp(y, 5);
% y6 = interp(y, 6);

y2 = resample(y, fs*0.25, fs);
y3 = resample(y, fs*0.5, fs);
y4 = resample(y, fs*0.75, fs);
y5 = resample(y, fs*1.25, fs);
y6 = resample(y, fs*1.5, fs);
y7 = resample(y, fs*1.75, fs);
y8 = resample(y, fs*2, fs);
y9 = resample(y, fs*2.25, fs);
y10 = resample(y, fs*2.5, fs);
y11 = resample(y, fs*2.75, fs);
y12 = resample(y, fs*3, fs);

output = [y; y2; y3; y4; y5; y6; y7; y8; y9; y10; y11; y12];
output = flip(output);

plot(output)
figure()
[S, F, T] = spectrogram(output);
imagesc(20*log10(abs(S)/max(max(abs(S)))))
axis xy
colormap('jet')
colorbar
audiowrite('drum_set.wav', output, fs);

%Rubberband
%% Chromagram Analysis
% plotChromagram('Whales_Singing_resampled.wav', 15)
% plotChromagram('Wind_Blowing_resampled.wav', 50)
% plotChromagram('RaceCar_Engine_resampled.wav', 20)
% plotChromagram('Chainsaw_Sawing_resampled.wav', 15)
% plotChromagram('Bees_Buzzing_resampled.wav', 15)
% plotChromagram('Beatles_LetItBe_resampled.wav', 15)
% plotChromagram('sinScale_v2.wav', 15)
% plotChromagram('sinScale.wav', 60)
% plotChromagram('speech_female.wav', 15)
% plotChromagram('Black Sabbath - Iron Man Instrumental.wav', 15)
% plotChromagram('wild_cherry_play_that_funky_music.mp3', 15)
% plotChromagram('Sawtoothbirthday.wav', 15)
plotChromagram('SinSpiel_frestrict_temp.wav', 15)
plotChromagram('SinSpiel_restrict_temp.wav', 15)
plotChromagram('glock2.wav', 15)
%% Phase Vocoder Tests
[d,sr]=audioread('drum.wav'); 
y = d(:,1);
output = y;

for n = [0.1:0.1:1.5]
    e = pvoc(y, n);
    [num, den] = rat(n);
    f = resample(e,num,den);
    output = [output; y(1:length(f))+f];
end

output = flip(output);

[S, F, T] = spectrogram(output);
figure()
imagesc(20*log10(abs(S)/max(max(abs(S)))))
axis xy
colormap('jet')
colorbar

% soundsc(output,sr)

audiowrite('drum_vocoded.wav', output, sr)
%% Synthesis Spectrogram Preview Script
[y, fs] = audioread('WindOpera_frestrict_istft.wav');
[y2, fs2] = audioread('WindOpera_frestrict_temp.wav');
[S, F, T] = computeSpectrogram(y, 100*fs/1000, 50*fs/1000, fs);
[S2, F2, T2] = computeSpectrogram(y2, 100*fs2/1000, 50*fs2/1000, fs2);
Spectrogram(S, F, T).showSpectrogram(80)
figure()
Spectrogram(S2, F2, T2).showSpectrogram(80)
%% Activations Preview Script
load('wind_opera_temp_eucl12_3253')
synthObj.NNMFSynthesis.showActivations(synthObj, -120)
%% Cost Preview Script
load('wind_opera_temp_eucl12_3253')
synthObj.showCost
%% Streamlined Driver
corpus_sound = Sound('glock2.wav');
target_sound = Sound('glock2.wav');

win.Length = 200*44100/1000;
win.Hop = 100*44100/1000;
win.Type = 'Hamming';

corpus_sound.computeFeatures(win, 'STFT');
target_sound.computeFeatures(win, 'STFT');

nmf_params.Algorithm = 'Euclidean';
nmf_params.Iterations = 35;
nmf_params.Convergence_criteria = 0;
nmf_params.Repition_restriction = 1;
nmf_params.Polyphony_restriction = 1;
nmf_params.Continuity_enhancement = 1;
nmf_params.Diagonal_pattern = 'Diagonal';
nmf_params.Modification_application = true;
nmf_params.Random_seed = 'shuffle';

synth = CSS(nmf_params, 'Template Addition');
synth.nmf(corpus_sound, target_sound);
%% Sparse NMF
corpus_sound = Sound('glock2.wav');
target_sound = Sound('glock2.wav');

win.Length = 200*44100/1000;
win.Hop = 100*44100/1000;
win.Type = 'Hamming';

corpus_sound.computeFeatures(win, 'STFT');
target_sound.computeFeatures(win, 'STFT');

nmf_params.Algorithm = 'Sparse NMF';
nmf_params.Iterations = 35;
nmf_params.Convergence_criteria = 0;
nmf_params.Repition_restriction = 1;
nmf_params.Polyphony_restriction = 1;
nmf_params.Continuity_enhancement = 1;
nmf_params.Diagonal_pattern = 'Diagonal';
nmf_params.Modification_application = true;
nmf_params.Random_seed = 'shuffle';
nmf_params.Lambda = 100;

synth = CSS(nmf_params, 'Template Addition');
synth.nmf(corpus_sound, target_sound);
%% Sparse NMF
corpus_sound = Sound('Chainsaw_Sawing_snippet_resampled.wav');
target_sound = Sound('Chainsaw_Sawing_snippet_resampled.wav');

win.Length = 100*44100/1000;
win.Hop = 50*44100/1000;
win.Type = 'Hamming';

corpus_sound.computeFeatures(win, 'STFT');
target_sound.computeFeatures(win, 'STFT');

nmf_params.Algorithm = 'Sparse NMF';
nmf_params.Iterations = 150;
nmf_params.Convergence_criteria = 0;
nmf_params.Repition_restriction = 1;
nmf_params.Polyphony_restriction = 1;
nmf_params.Continuity_enhancement = 1;
nmf_params.Diagonal_pattern = 'Diagonal';
nmf_params.Modification_application = true;
nmf_params.Random_seed = 'shuffle';
nmf_params.Lambda = 5;

synth = CSS(nmf_params, 'ISTFT');
synth.nmf(corpus_sound, target_sound);
%% Beta Divergence NMF
V = random('unif',0, 100, 4, 4);
W = random('unif',0, 100, 4, 4);
L=5;
cost=0;
K=size(W, 2);
M=size(V, 2);
beta = 1;
H=random('unif',0, 1, K, M);

V = V+1E-6;
W = W+1E-6;
 
for l=1:L-1    
    recon = W*H;
    num = H.*(W'*(((recon).^(beta-2)).*V));
    den = W'*((recon).^(beta-1));
    H = num./den;    
end
%% Pruning Corpus
V = random('unif',0, 100, 4, 4);
W = random('unif',0, 100, 4, 20);
Y = prune_corpus(V, W );