function templateScrollCb(src, callbackdata, handles)

selectedTemplate = findobj(gca, 'Color', 'b');

if(size(selectedTemplate, 1) == 0)
    set(handles(1), 'Color', 'b');
else
    if(selectedTemplate.XData(1) == 1)
        set(selectedTemplate, 'Color', get(handles(length(handles)-1), 'Color'));
        set(handles(1), 'Color', 'b');
    else
        set(selectedTemplate, 'Color', get(handles(length(handles) - selectedTemplate.XData(1) + 2), 'Color'));
        set(handles(length(handles) - selectedTemplate.XData(1) + 2), 'Color', 'b');
    end
end