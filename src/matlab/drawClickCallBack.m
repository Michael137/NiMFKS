%Used for the plot drawing function
function drawClickCallBack(src,callbackdata, action)
handles = guidata(src);
src.Pointer = 'circle';
ah = handles.axes1;
xAxisProps = get(ah, 'XAxis');
xLimits = get(xAxisProps, 'Limits')

acts = handles.SynthesisObject.NNMFSynthesis.Activations;
xUnit = xLimits/size(acts, 2);

sliderHandle = handles.slider3;

if(strcmp(action, 'Draw'))
    fillValue = get(sliderHandle, 'Value')
elseif(strcmp(action, 'Erase'))
    fillValue = 0;
end
% currentplot = get(ah, 'Children');
% currentxdata = get(currentplot, 'XData');
% currentydata = get(currentplot, 'YData');

src.WindowButtonMotionFcn = @dragCallBack;
src.WindowButtonUpFcn = @releaseCallBack;

    function dragCallBack(src, callbackdata)
        cp = ah.CurrentPoint;
        cx = cp(1,1)/xUnit(2)
        cy = cp(1,2)
        acts(ceil(cy), ceil(cx)) = fillValue;
        handles.SynthesisObject.NNMFSynthesis.Activations = acts;
        guidata(src, handles);
    end

    function releaseCallBack(src, callbackdata)
        src.Pointer = 'arrow';
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
    end
end