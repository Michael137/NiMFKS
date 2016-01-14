function SynthesisCtr(action, datastruct)

handles = datastruct;

switch action
    case 'openTarget'
        [filename pathname] = uigetfile({'*.wav;*.mp3;'}, 'File Selector');
        sourcepathname= strcat(pathname, filename);
        set(handles.text5, 'String', sourcepathname);
    case 'openSource'
        handles = datastruct;
        [filename pathname] = uigetfile({'*.wav;*.mp3;'}, 'File Selector');
        sourcepathname= strcat(pathname, filename);
        set(handles.text7, 'String', sourcepathname);
    case 'playTarget'
        [y, Fs] = audioread(get(handles.text5, 'String'));
        soundsc(y, Fs);
    case 'playSource'
        [y, Fs] = audioread(get(handles.text7, 'String'));
        soundsc(y, Fs);
    case 'run'
%         verifyParameters(handles)
%         performCalculations(handles)
        portionLength = str2num(get(handles.edit11, 'String'));
        windowLength = str2num(get(handles.edit9, 'String'));
        overlap = str2num(get(handles.edit10, 'String'));
        [Y, Fs] = audioread(get(handles.text7, 'String'));
        [Y2, Fs2] = audioread(get(handles.text5, 'String'));
        Y=Y(1:min(portionLength*Fs, length(Y)));
        Y2=Y2(1:min(portionLength*Fs, length(Y2)));
        synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
        synth.computeSpectrogram('Source');
        synth.computeSpectrogram('Target');
        if(get(handles.checkbox2, 'Value'))
            figure()
            synth.SourceSpectrogram.showSpectrogram(80);
            figure()
            synth.TargetSpectrogram.showSpectrogram(80);
        end
        
        synthMethodSelected=get(handles.popupmenu2, 'Value');
        synthMethods=get(handles.popupmenu2, 'String');
        if(strcmp(synthMethods(synthMethodSelected), 'NNMF'))
            
            costMetricSelected=get(handles.popupmenu3, 'Value');
            costMetrics=get(handles.popupmenu3, 'String');
            synth.synthesize('NNMF', costMetrics(costMetricSelected), str2num(get(handles.edit13, 'String')), get(handles.checkbox7, 'Valu'));
            
            if(get(handles.checkbox1, 'Value'))
                figure()
                synth.NNMFSynthesis.showCost;
            end
            
            if(get(handles.checkbox4, 'Value'))
                figure()
                synth.NNMFSynthesis.showActivations(synth);
            end
        end
end

% function performCalculations()
% function verifyParameters()