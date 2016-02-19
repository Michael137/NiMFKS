function wkpcb(src, callbackdata)

selectedTemplate = findobj(gcf, 'Color', 'b');

if(strcmp(callbackdata.Key, 'delete'))
    selectedTemplate.YData = zeros(1, length(selectedTemplate.YData));
    selectedTemplate.ZData = zeros(1, length(selectedTemplate.ZData));
end