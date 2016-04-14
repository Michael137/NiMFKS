function [output, segments] = templateAdditionResynth(X, H, varargin)

if(nargin > 2)
    windowLength = varargin{1};
    overlap = varargin{2};
else
    overlap = floor((length(X)/size(H, 2))/2);
    windowLength = floor(2*overlap);
end

windowhop = windowLength - overlap;
start_samples_in_corpus=[0:size(H,1)-1]*windowhop + 1;
end_samples_in_corpus = start_samples_in_corpus + windowLength - 1;
start_samples_in_synthesis=[0:size(H,2)-1]*windowhop + 1;
end_samples_in_synthesis = start_samples_in_corpus + windowLength - 1;

waitbarHandle = waitbar(0, 'Starting Template Addition Synthesis...');

% segments=zeros(windowLength,size(H, 2));
output=zeros(windowhop*(size(H,2)-1)+windowLength,1);
win = window(@hann,(windowLength));
for kk=1:size(H, 2)
%     waitbar(kk/size(H, 2), waitbarHandle, ['Creating segments...', num2str(kk), '/', num2str(size(H, 2))]);
    extracted=H(:,kk);
    
    for ii=find(extracted>1e-10)'
      if length(X) > end_samples_in_corpus(ii)
        output(start_samples_in_synthesis(kk):end_samples_in_synthesis(kk)) = ...
          output(start_samples_in_synthesis(kk):end_samples_in_synthesis(kk)) + ...
          win.*( ...
          X(start_samples_in_corpus(ii):end_samples_in_corpus(ii))*extracted(ii));
%         segments(:,kk) = segments(:,kk) + win.*( ...
%           X(start_samples_in_corpus(ii):end_samples_in_corpus(ii))*extracted(ii));
      end
    end
end

% waitbar(0, waitbarHandle, strcat('Generating output...', num2str(kk), '/', num2str(size(H, 2))))
% output=zeros(windowhop*(size(H,2)-1)+windowLength,1);
% for jj=1:size(H,2)
%     waitbar(jj/length(output), waitbarHandle, strcat('Generating output...', num2str(jj), '/', num2str(size(H,2))))
%     output(start_samples_in_synthesis(jj):end_samples_in_synthesis(jj)) = ...
%       output(start_samples_in_synthesis(jj):end_samples_in_synthesis(jj)) + segments(:,jj);
% end

% output=zeros(1, 6615);
% output(1:4410)=segments(1, :);
% output(1+overlap-1:windowLength+overlap-1)=output(1+overlap-1:windowLength+overlap-1)+segments(1, :);
output = output';
close(waitbarHandle)
end
%
% function [output, segments] = templateAdditionResynth(X, H, varargin)
% 
% if(nargin > 2)
%     windowLength = varargin{1};
%     overlap = varargin{2};
% else
%     overlap = floor((length(X)/size(H, 2))/2);
%     windowLength = floor(2*overlap);
% end
% 
% waitbarHandle = waitbar(0, 'Starting Template Addition Synthesis...')
% 
% segments=zeros(size(H, 2), windowLength);
% win = window(@hann,(windowLength));
% % win = window(@sin,(windowLength));
% % win = tukeywin(windowLength, 0.75);
% 
% % m=1;
% for k=1:size(H, 2)
%     waitbar(k/size(H, 2), waitbarHandle, strcat('Creating segments...', num2str(k), '/', num2str(size(H, 2))))
% %     windowed = win.*X(m:m+windowLength-1);
%     extracted=H(:,k);
%     
%     extracted(extracted<1e-20)=0;
%     for i=1:length(extracted)-2
%         if(extracted(i,1)~=0)
%             location=i*floor(length(X)/size(H, 1));
% %             disp(strcat('k:', num2str(k)))
% %             disp(strcat('i:', num2str(i)))
% 
%             segments(k, :)=(segments(k, :)'+ win.*(X(location:location+windowLength-1)*extracted(i))); %TODO: Pointwise multiply X by smooth window e.g. van Hann
% %             segments(k, :)=segments(k, :)'+ X(location:location+windowLength-1)*extracted(i);
% 
%         end
%     end
% %     m=m+overlap;  
% end
% 
% waitbar(0, waitbarHandle, strcat('Generating output...', num2str(k), '/', num2str(size(H, 2))))
% i=1;
% output=zeros(1, overlap*(size(segments,1)+1));
% for j=1:overlap:length(output)-windowLength
%     waitbar(j/length(output), waitbarHandle, strcat('Generating output...', num2str(j), '/', num2str(length(output)-windowLength)))
%     output(j:j+windowLength-1)=output(j:j+windowLength-1)+segments(i, :);
%     i=i+1;
% end
% 
% % disp(size(output))
% % output=zeros(1, 6615);
% % output(1:4410)=segments(1, :);
% % output(1+overlap-1:windowLength+overlap-1)=output(1+overlap-1:windowLength+overlap-1)+segments(1, :);
% close(waitbarHandle)
% end
