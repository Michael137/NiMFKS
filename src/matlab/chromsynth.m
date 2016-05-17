function [x,CF,CM] = chromsynth(F,bp,sr)
% [x,CF,CM] = chromsynth(F,bp,sr)
%   Resynthesize a chroma feature vector to audio
%   F is 12 rows x some number of columns, one per beat
%   bp is the period of one beat in sec (or a vector of beat times)
%   sr is the sampling rate of the output waveform
%   x is returned as a 12 semitone-spaced sines modulated by F
%   CF,CM return actual sinusoid matrices passed to synthtrax
%   Actual Shepard tones now implemented! 2007-04-19
% 2006-07-14 dpwe@ee.columbia.edu

if nargin < 2; bp = 0.5; end % 120 bpm
if nargin < 3; sr = 22050; end

[nchr,nbts] = size(F);

% resynth
if length(bp) == 1
  bups = 8; % upsampling factor
  framerate = bups/bp;
  ncols = nbts*bups;
  CMbu = zeros(nchr, ncols);
  for i = 1:bups
    CMbu = CMbu + upsample(F', bups, i-1)';
  end
else
  % vector of beat times - quantize
  framerate = 50; % frames per sec
  nbeats = length(bp);
  lastbeat = bp(nbeats) + (bp(nbeats) - bp(nbeats-1));
  ncols = round(lastbeat * framerate);
  CMbu = zeros(nchr, ncols);
  xF = [zeros(12,1),F];
  for i = 1:ncols
    CMbu(:,i) = xF(:,max(find(i/framerate >= [0,bp])));
  end
end
  
%CFbu = repmat(440*2.^([0:(nchr-1)]'/nchr),1,ncols);
%x = synthtrax(CFbu,CMbu,sr,round(sr/framerate));
octs = 7;
basefrq = 27.5;  % A1; +6 octaves = 3520
CFbu = repmat(basefrq*2.^([0:(nchr-1)]'/nchr),1,ncols);
CF = [];
CM = [];
% what bin is the center freq?
f_ctr = 440;
f_sd = 0.5;
f_bins = basefrq*2.^([0:(nchr*octs - 1)]/nchr);
f_dist = log(f_bins/f_ctr)/log(2)/f_sd;  
% actually just = ([0:(nchr*octs - 1)]/nchr-log2(f_ctr/basefrq))/f_sd
% Gaussian weighting centered of f_ctr, with f_sd
f_wts = exp(-0.5*f_dist.^2);
for oct = 1:octs
  CF = [CF;(2^oct)*CFbu];
  % pick out particular weights
  CM = [CM;diag(f_wts((oct-1)*nchr+[1:nchr]))*CMbu];
end
% Remove sines above nyquist
CFok = (CF(:,1) < sr/2);
CF = CF(CFok,:);
CM = CM(CFok,:);
% Synth the sines
x = synthtrax(CF,CM,sr,round(sr/framerate));

% Playing synth along with audio:
%>> rdc = chromsynth(Dy.F(:,160+[1:300]),Dy.bts(160+[1:300]) - Dy.bts(160),sr);
%>> Dy.bts(161)*sr              
%ans =
%      279104
%>> size(rdc)
%ans =
%           1      498401
%>> ddd = db(279104+[1:498401]);
%>> soundsc([ddd,rdc'/40],sr)   
