function templateScrollCb(src, callbackdata, handles)

selectedTemplate = findobj(gca, 'Color', 'b');
if(callbackdata.VerticalScrollCount < 0 && size(selectedTemplate, 1) ~= 0) %Up scroll
    newTemplateIndex = length(handles) - selectedTemplate.XData(1) + 2;
    if(newTemplateIndex > length(handles))
        newTemplateIndex = 2;
    end
    neighbouringTemplate = newTemplateIndex + 1;
elseif(callbackdata.VerticalScrollCount > 0 && size(selectedTemplate, 1) ~= 0) %Down scroll
    newTemplateIndex = length(handles) - selectedTemplate.XData(1);
    if(newTemplateIndex < 1)
        newTemplateIndex = length(handles);
    end
end

if(size(selectedTemplate, 1) == 0)
    set(handles(1), 'Color', 'b');
else
    set(selectedTemplate, 'Color', get(handles(newTemplateIndex), 'Color'));
    set(handles(newTemplateIndex), 'Color', 'b');
end