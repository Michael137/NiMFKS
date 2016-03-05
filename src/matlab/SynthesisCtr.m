function SynthesisCtr(action, datastruct)

handles = datastruct;

switch action
    case 'openTarget'
        [filename pathname] = uigetfile({'C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\*.wav;*.mp3;'}, 'File Selector');
        sourcepathname= strcat(pathname, filename);
        set(handles.text5, 'String', sourcepathname);
    case 'openSource'
        handles = datastruct;
        [filename pathname] = uigetfile({'C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\*.wav;*.mp3;'}, 'File Selector');
        sourcepathname= strcat(pathname, filename);
        set(handles.text7, 'String', sourcepathname);
    case 'openResynthesis'
        pathname = 'C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav';
        set(handles.text8, 'String', pathname);
    case 'savePlot'
        frame = getframe(handles.axes1);
        image = frame2im(frame);
        [file,path] = uiputfile({'*.png'},'Save As');
        imwrite(image, strcat(path, file));
    case 'exportResynth'
        [file,path] = uiputfile({'*.wav'},'Save Sound As');
        copyfile('C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav', strcat(path, file));
    case 'playTarget'
        [y, Fs] = audioread(get(handles.text5, 'String'));
        soundsc(y, Fs);
    case 'playSource'
        [y, Fs] = audioread(get(handles.text7, 'String'));
        soundsc(y, Fs);
    case 'playResynthesis'
        [y, Fs] = audioread(get(handles.text8, 'String'));
        soundsc(y, Fs);
    case 'configPlotlist'
%         plotMap = containers.Map({'Cost', 'Resynthesis', 'Activations'}, [get(handles.checkbox1, 'Value'), get(handles.checkbox4, 'Value'), get(handles.checkbox5, 'Value')]);
        plotList = {};
        if(get(handles.checkbox1, 'Value'))
            plotList = [plotList; 'Cost'];
        end
        
        if(get(handles.checkbox3, 'Value'))
            plotList = [plotList; 'Source Templates'];
        end
        
        if(get(handles.checkbox5, 'Value'))
            plotList = [plotList; 'Resynthesis'; 'Synthesis Spectrogram'];
        end
        
        if(get(handles.checkbox4, 'Value'))
            plotList = [plotList; 'Activations'];
        end
        
        if(get(handles.checkbox2, 'Value'))
            plotList = [plotList; 'Source Spectrogram'; 'Target Spectrogram'];
        end
        
        listboxContent = cellstr(get(handles.listbox1, 'String'));
        set(handles.listbox1, 'String', [plotList; listboxContent]);
    case 'switchPlot'
        contents = cellstr(get(handles.listbox1,'String'));
        delete(handles.axes1.Children);
%         view(0, 90);
        switch(contents{get(handles.listbox1,'Value')})
            case 'Resynthesis'
%                 set(handles.figure1, 'CurrentAxes', handles.ResynthesisPlot);
                handles.SynthesisObject.showResynthesis;
                set(handles.uitable3, 'Data', handles.SynthesisObject.Resynthesis');
%                 fig2plotly()
            case 'Cost'
%                 set(handles.figure1, 'CurrentAxes', handles.CostPlot);
                handles.SynthesisObject.NNMFSynthesis.showCost;
                set(handles.uitable3, 'Data', handles.SynthesisObject.NNMFSynthesis.Cost');
%                 fig2plotly()
            case 'Activations'
%                 set(handles.figure1, 'CurrentAxes', handles.ActivationsPlot);
                handles.SynthesisObject.NNMFSynthesis.showActivations(handles.SynthesisObject, get(handles.slider4, 'Value'));
                set(handles.uitable3, 'Data', handles.SynthesisObject.NNMFSynthesis.Activations);
%                 fig2plotly()
            case 'Source Spectrogram'
%                 set(handles.figure1, 'CurrentAxes', handles.ActivationsPlot);
                handles.SynthesisObject.SourceSpectrogram.showSpectrogram(80);
                set(handles.uitable3, 'Data', abs(handles.SynthesisObject.SourceSpectrogram.S));
%                 fig2plotly()
            case 'Target Spectrogram'
                handles.SynthesisObject.TargetSpectrogram.showSpectrogram(80);
                set(handles.uitable3, 'Data', abs(handles.SynthesisObject.TargetSpectrogram.S));
            case 'Synthesis Spectrogram'
                resynthSpectrogram = Spectrogram(handles.SynthesisObject.NNMFSynthesis.Reconstruction, ...
                                        handles.SynthesisObject.TargetSpectrogram.F, handles.SynthesisObject.TargetSpectrogram.T);
                resynthSpectrogram.showSpectrogram(80);
                set(handles.uitable3, 'Data', abs(resynthSpectrogram.S));
            case 'Source Templates'
                handles.SynthesisObject.showTemplates;
                set(handles.uitable3, 'Data', abs(handles.SynthesisObject.SourceSpectrogram.S));
%                 fig2plotly()
        end
    case 'run' %Separate into further modules; controller helper functions file
%         verifyParameters(handles)
%         performCalculations(handles)
        waitbar(0.25, handles.waitbarHandle, 'Reading audio files...')
        portionLength = str2num(get(handles.edit11, 'String'));
        windowLength = str2num(get(handles.edit9, 'String'));
        overlap = str2num(get(handles.edit10, 'String'));
        [Y, Fs] = audioread(get(handles.text7, 'String'));
        [Y2, Fs2] = audioread(get(handles.text5, 'String'));
        
        %Convert to Monophonic sound
        if(size(Y, 2) ~= 1)
            Y = (Y(:,1)+Y(:,2))/2;
        elseif(size(Y2, 2) ~= 1)
            Y2 = (Y2(:,1)+Y2(:,2))/2;
        end
        
%         Y=Y(1:min(portionLength*Fs, length(Y)));
        Y2=Y2(1:min(portionLength*Fs, length(Y2)));
        
        waitbar(0.5, handles.waitbarHandle, 'Performing audio analysis...')
        synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
        
        spectTypeSelected=get(handles.popupmenu5, 'Value');
        spectTypes=get(handles.popupmenu5, 'String');
        synth.computeSpectrogram('Source', spectTypes(spectTypeSelected));
        synth.computeSpectrogram('Target', spectTypes(spectTypeSelected));
        
        synthMethodSelected=get(handles.popupmenu2, 'Value');
        synthMethods=get(handles.popupmenu2, 'String');
        
        waitbar(0.75, handles.waitbarHandle, 'Performing synthesis...')
        if(strcmp(synthMethods(synthMethodSelected), 'NNMF'))
            
            costMetricSelected=get(handles.popupmenu3, 'Value');
            costMetrics=get(handles.popupmenu3, 'String');
            
            synth.synthesize('NNMF', costMetrics(costMetricSelected), str2num(get(handles.edit13, 'String')), 'repititionRestricted', get(handles.checkbox7, 'Value'), ...
                                'continuityEnhanced', get(handles.checkbox9, 'Value'), 'polyphonyRestricted', get(handles.checkbox8, 'Value'), 'convergenceCriteria', str2double(get(handles.edit15, 'String')), ...
                                    'r', str2double(get(handles.edit19, 'String')), 'c', str2double(get(handles.edit21, 'String')), 'p', str2double(get(handles.edit20, 'String')));
        end
        
        waitbar(0.9, handles.waitbarHandle, 'Performing resynthesis...')
        resynthMethodSelected=get(handles.popupmenu4, 'Value');
        resynthMethods=get(handles.popupmenu4, 'String');
        synth.resynthesize(resynthMethods(resynthMethodSelected));
        
        handles.SynthesisObject = synth;
        guidata(handles.figure1, handles);
    case 'Resynthesize'
        synth = handles.SynthesisObject;
        H = synth.NNMFSynthesis.Activations;
        C = synth.NNMFSynthesis.Cost;
        resynthMethodSelected=get(handles.popupmenu4, 'Value');
        resynthMethods=get(handles.popupmenu4, 'String');
        recon = synth.SourceSpectrogram.S*H;
        synth.NNMFSynthesis = NNMF(H, recon, C);
        synth.resynthesize(resynthMethods(resynthMethodSelected));
end

% function performCalculations()
% function verifyParameters()