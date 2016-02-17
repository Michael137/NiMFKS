function [S, f, t] = iir_cqt_spectrogram(y,nfft,hop,fs,Q)
% IIR LTV Q SPECTROGRAM Multiresolution constant quality spectrogram
% calculated with a varying IIR filtering of the DFT.
%
% Inputs:
%
%   y: Audio Signal
%   N: Window length in samples
%   L: Hop size in samples
%   fs: Sampling frequency
%   Q: Quality factor, analysis window with in number of cycles (up to a 3dB gain drop)
%
% Outputs:
%
%   S: Each column is the frequency representation of an instant of the
%   audio file using a window length of  N samples, and analyzing Q cycles of each 
%   frequency component. The time between two colums is L samples.
%   f: Frequency vector. Contains the frequency values corresponding to
%   each row of S.
%   t: Time vector. Containns the time values at which each column of S was
%   calculated
%   
% Example: 
%   [s, t, f] = iir_ltv_q_spectrogram(y,4096,256,44100,13)


% transform input data to a column vector 
y = y(:);
ny = length(y);

% number of frames (temporal index)
nframes = ceil(ny/hop);
frameindex = 1 + (0 : nframes - 1) * hop; % samples.

% zero padding at the end to complete the last frame.
y = [y; zeros(nfft-mod(ny,hop),1)];

% matrix to store the q-spectrum
S = zeros(nframes,nfft/2);

% number of points of pre and post padding used to set initial conditions
prepad = 10;
pospad = 100;
% frequency bins grid (linear in this case) - pre and pos padding is added
slope = pi/nfft;
thetas = abs(slope*linspace(-prepad,nfft/2+pospad-1,nfft/2+prepad+pospad));
thetas(prepad+1) = eps; % zero digital frequency
% poles of the IIR LTV Q FFT transform for the parameters above
poles = calculate_poles(thetas,Q,nfft);

% IIR LTV Q FFT transform
for i=1:nframes
    S(i,:) = iir_ltv_q_fft(y(frameindex(i):frameindex(i)+nfft-1)',poles, prepad, pospad);
end

t = (frameindex-1+nfft/2)/fs;
f = (0:1:nfft/2-1)*fs/nfft;
S = S';

end

function q_fft_frame = iir_ltv_q_fft(x, poles, prepad, pospad)
% function q_fft_frame = iir_ltv_q_fft(x, poles, prepad, pospad)
% Computes a multi-resolution fast fourier transform using recursive filters.
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
%
% arguments:
%      x - signal frame ( NFFT = 2^nextpow2(length(x)) )
%  poles - poles to be used for each frequency bin (length NFFT/2)
% prepad - pre-padding # points to set initial conditions of the foward filter
% pospad - post-padding # points to set initial conditions of the reverse filter

% fft of the signal frame
x = x(:);
x_fft = (fft([x(end/2+1:end) ;x(1:end/2) ]));
x_fft = [x_fft(end-prepad+1:end); x_fft(1:end/2+pospad)];

poles = poles(1:length(x)/2);
poles = [poles; flipud(poles)];%[poles(prepad+1:-1:2); poles(1:end);poles(end-1:-1:end-pospad)];
poles = [poles(end-prepad+1:end); poles(1:end/2+pospad)];

q_fft_frame = zeros(length(x_fft),1);
y = zeros(length(x_fft),1);

% foward filtering
x_zero = x_fft(2:end) + x_fft(1:end-1); % zero portion of filter's equation
y(1) = x_fft(1);
for n=2:length(x_fft)
    y(n) = x_zero(n-1) + poles(n) * y(n-1);
end

% reverse filtering
y_zero = y(2:end) + y(1:end-1); % zero portion of filter's equation
q_fft_frame(end) = y(end);
for n=length(x_fft)-1:-1:1
    q_fft_frame(n) = y_zero(n) + poles(n) * q_fft_frame(n+1);
end

% undo the padding
q_fft_frame = q_fft_frame(prepad+1:end-pospad);
poles = poles(prepad+1:end-pospad);
N = length(poles);

% normalization
q_fft_frame = q_fft_frame ./ (2./(1-poles)) / N;

end

function poles = calculate_poles(thetas,Q,NFFT,slope)
% function poles = calculate_poles(thetas,Q,NFFT,slope)
%
% Function that calculates the poles of a IIR-LTV-Q-FFT transform.
% For each digital frequency theta a pole is designed that complies with
% the specified Q factor, for the given number of FFT point.
%
% thetas - digital frequency grid (only half the spectrum - size: NFFT/2 + padding)
%      Q - quality factor
%   NFFT - number of points of the FFT

if nargin < 4; slope = 0.9/3; end;

N = length(thetas);
poles = zeros(N,1);

for i=1:N
   poles(i) = design_pole(thetas(i),Q+slope*thetas(i),NFFT);
end

end

function [p] = design_pole(theta,Q,NFFT,db)
% function p = design_pole(theta,Q,NFFT,db)
%
% Function that designs a pole for the IIR-LTV-Q-FFT transform.
% The Q factor sets the number of cycles of a sinusoid of digital frequency
% theta that must fit into the window. Thus the window is designed so that
% Q cycles fit within its db drop points (normally 3dB). 

if nargin < 4; db = 3; end;

tau = Q * (2*pi^2) / NFFT / theta;

% Hyperbola : (y-max_frac_pi*pi)(y-x) = -softness, that saturates the tau to a maximum value 
softness = 0.005;
max_frac_pi = 0.6;

% The hyperbola solutions are calculated
rr = roots([1,-(tau+max_frac_pi*pi),pi*tau*max_frac_pi-softness]);
% the smallest solution is the desired value
tau_h = min(rr);
tau = tau_h;

% The pole is calculated for the saturated Q
w = 1/10^(db/20);
pol = [2*w-(1+cos(tau)) -(4*w*cos(tau)-2*(1+cos(tau))) 2*w-(1+cos(tau))];
r = roots(pol);
% The pole inside the unit circle is the thesired solution
p = r(abs(r)<1);

end

