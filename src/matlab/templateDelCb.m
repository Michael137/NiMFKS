function templateDelCb(src, callbackdata)

if(strcmp(callbackdata.Key, 'delete'))
    selectedTemplate = findobj(gca, 'Color', 'b');
    selectedTemplate.YData = zeros(1, length(selectedTemplate.YData));
    selectedTemplate.ZData = zeros(1, length(selectedTemplate.ZData));
    handles = guidata(src);
    templates = handles.Sound_corpus.Features.STFT.S;
    selectedIndex = handles.templateIndices(selectedTemplate.XData);
    templates(:, selectedIndex) = 0;
    handles.Sound_corpus.Features.STFT.S = templates;
end