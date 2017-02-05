function [output, segments] = templateAdditionResynth(X, H, varargin)

if(nargin > 2)
    win = varargin{1};
    windowLength = win.Length;
    overlap = win.Hop;
    winfn = lower(win.Type);
    win = window(winfn, windowLength);
else
    overlap = floor((length(X)/size(H, 2))/2);
    windowLength = floor(2*overlap);
    win = window(@hann,(windowLength));
end

windowhop = windowLength - overlap;
start_samples_in_corpus=[0:size(H,1)-1]*windowhop + 1;
end_samples_in_corpus = start_samples_in_corpus + windowLength - 1;
start_samples_in_synthesis=[0:size(H,2)-1]*windowhop + 1;
end_samples_in_synthesis = start_samples_in_synthesis + windowLength - 1;

waitbarHandle = waitbar(0, 'Starting Template Addition Synthesis...');

output=zeros(windowhop*(size(H,2)-1)+windowLength,1);

for kk=1:size(H, 2)
    waitbar(kk/size(H, 2), waitbarHandle, ['Creating segments...', num2str(kk), '/', num2str(size(H, 2))]);
    extracted=H(:,kk);
    
    for ii=find(extracted>1e-10)'
      if length(X) > end_samples_in_corpus(ii)
        output(start_samples_in_synthesis(kk):end_samples_in_synthesis(kk)) = ...
          output(start_samples_in_synthesis(kk):end_samples_in_synthesis(kk)) + ...
          win.*( ...
          X(start_samples_in_corpus(ii):end_samples_in_corpus(ii))*extracted(ii));
      end
    end
end

output = output';

output = output./max(max(output));
close(waitbarHandle)
end