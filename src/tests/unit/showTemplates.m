function [handle] = showTemplates(varargin)
%W: source matrix
%F: frequency vector of source target spectrogram

if(nargin==2)
    W=varargin{1};
    F=varargin{2};
    hold on; grid on;
    [~,I]=max(W);
    [~,Ix] = sort(I,'ascend');
    for jj=1:size(W,2)
        specdB=W(:,Ix(jj))/max(max(W));
        handle=plot3(jj*ones(size(W,1),1),F/1000,specdB, ...
            'Color',power((size(W,2)-jj)/(size(W,2)+1),0.65)*ones(3,1), ...
            'LineWidth',8*(2+size(W,2)-jj)/(size(W,2)));
    end
    ylabel('Frequency (kHz)');
    xlabel('Template');
    zlabel('Magnitude');
    axis([-0.5 size(W,2)-0.5 0 F(end)/4000 0 1]);
    view(105,26);
end
    
end