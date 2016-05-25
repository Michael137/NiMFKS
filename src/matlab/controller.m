function controller(action, handles)

switch action
    case 'openTarget'
        [filename pathname] = uigetfile({'*.wav;*.mp3;'}, 'File Selector');
        targetpathname= strcat(pathname, filename);
        handles.Sound_target = Sound(targetpathname);
        set(handles.txt_targetfile, 'String', filename);
    case 'openSource'
        [filename pathname] = uigetfile({'*.wav;*.mp3;'}, 'File Selector');
        sourcepathname= strcat(pathname, filename);
        handles.Sound_corpus = Sound(sourcepathname);
        set(handles.txt_corpusfile, 'String', filename);
    case 'playTarget'
        handles.Sound_target.control_audio('Play');
    case 'playSource'
        handles.Sound_corpus.control_audio('Play');
    case 'playResynthesis'
    case 'runAnalysis'
    case 'runSynthesis'
    case 'savePlot'
    case 'exportResynth'
    case 'switchPlot'
    case 'resynthesize'
    case 'rerun'
end

end