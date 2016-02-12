classdef NNMF
    properties
        Activations
        Reconstruction
        Cost
    end
    
    methods
        function obj = NNMF(varargin)
            if nargin > 0
                obj.Activations= varargin{1};
                obj.Reconstruction= varargin{2};
                obj.Cost= varargin{3};                
            else
                error('Wrong number of input arguments');
            end
        end
    end
    
    methods
        function showCost(obj)
            plot(obj.Cost);
            xlabel('Iteration');
            ylabel('Cost');
            title('Cost vs. Iteration');
            grid on
        end
    end
    
    methods
        function showActivations(NNMFObj, SynthObj)
            W = abs(SynthObj.SourceSpectrogram.S);
            T = SynthObj.TargetSpectrogram.T;
            H = NNMFObj.Activations;
            [~,I]=max(W);
            [~,Ix] = sort(I,'ascend');
            imagesc(T,1:size(H,1),max(-20,20*log10(H(Ix,:)./max(H(:))))); %TODO: Reconsider dB level
            cmap = colormap('gray');
            cmap(1,:) = 0*ones(1,3);
            colormap(flipud(cmap))
            colorbar
            axis xy; grid on;
            set(gca,'XTick',[0:0.5:T(end)],'XTickLabel','');
            set(gca, 'Layer', 'top');
            ylabel('Template');
            grid on;
            set(gca,'FontSize',16);
        end
    end
end