%Used for the plot drawing function
function wbdcb(src,callbackdata)
src.Pointer = 'circle';
ah = gca;
cp = ah.CurrentPoint
xinit = cp(1,1);
yinit = cp(1,2);
sp = scatter(xinit,yinit,'filled');
src.WindowButtonMotionFcn = @wbmcb;
src.WindowButtonUpFcn = @wbucb;

    function wbmcb(src, callbackdata)
        cp = ah.CurrentPoint;
        xdat = [xinit,cp(1,1)];
        ydat = [yinit,cp(1,2)];
        sp.XData = xdat;
        sp.YData = ydat;
        drawnow
        hold on
    end

    function wbucb(src, callbackdata)
        src.Pointer = 'arrow';
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
    end
end