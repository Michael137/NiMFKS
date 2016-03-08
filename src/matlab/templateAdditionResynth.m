function [output, segments] = templateAdditionResynth(X, H, windowLength, overlap)

segments=zeros(size(H, 2), windowLength);
% m=1;
for k=1:size(H, 2)
%     windowed = win.*X(m:m+windowLength-1);
    extracted=H(:,k);
    
    extracted(extracted<1e-20)=0;
    for i=1:length(extracted)-2
        if(extracted(i,1)~=0)
            location=i*floor(length(X)/size(H, 1));
%             disp(strcat('k:', num2str(k)))
%             disp(strcat('i:', num2str(i)))
            win = window(@hann,(windowLength));
            %Tukey (75%), Sin window
            segments(k, :)=(segments(k, :)'+ win.*(X(location:location+windowLength-1)*extracted(i))); %TODO: Pointwise multiply X by smooth window e.g. van Hann
%             segments(k, :)=segments(k, :)'+ X(location:location+windowLength-1)*extracted(i);
        end
    end
%     m=m+overlap;  
end

i=1;
output=zeros(1, overlap*(size(segments,1)+1));
for j=1:overlap:length(output)-windowLength
    output(j:j+windowLength-1)=output(j:j+windowLength-1)+segments(i, :);
    i=i+1;
end

% output=zeros(1, 6615);
% output(1:4410)=segments(1, :);
% output(1+overlap-1:windowLength+overlap-1)=output(1+overlap-1:windowLength+overlap-1)+segments(1, :);

end