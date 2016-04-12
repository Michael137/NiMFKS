function SynthesisCtr(action, datastruct)

handles = datastruct;

switch action
    case 'openTarget'
        [filename pathname] = uigetfile({'C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\*.wav;*.mp3;'}, 'File Selector');
%         [filename pathname] = uigetfile({'*.wav;*.mp3;'}, 'File Selector');
        targetpathname= strcat(pathname, filename);
        handles.targetfile = targetpathname;
%         guidata(gcf, handles);
        set(handles.txt_targetfile, 'String', filename);
    case 'openSource'
        handles = datastruct;
        [filename pathname] = uigetfile({'C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\*.wav;*.mp3;'}, 'File Selector');
%         [filename pathname] = uigetfile({'*.wav;*.mp3;'}, 'File Selector');
        sourcepathname= strcat(pathname, filename);
        handles.corpusfile = sourcepathname;
%         guidata(gcf, handles);
        set(handles.txt_corpusfile, 'String', filename);
    case 'Swap Sounds'
        sourceFile = get(handles.text7, 'String');
        targetFile = get(handles.text5, 'String');
        set(handles.text5, 'String', sourceFile);
        set(handles.text7, 'String', targetFile);
    case 'openResynthesis'
        pathname = 'C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav';
%         pathname = 'resynthesis.wav';
        handles.synthesisfile = pathname;
%         guidata(gcf, handles);
    case 'savePlot'
        frame = getframe(handles.axes1);
        image = frame2im(frame);
        [file,path] = uiputfile({'*.png'},'Save As');
        imwrite(image, strcat(path, file));
    case 'exportResynth'
        [file,path] = uiputfile({'*.wav'},'Save Sound As');
        copyfile('C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav', strcat(path, file));
    case 'playTarget'
        [y, Fs] = audioread(handles.targetfile);
        soundsc(y, Fs);
    case 'playSource'
        [y, Fs] = audioread(handles.corpusfile);
        soundsc(y, Fs);
    case 'playResynthesis'
        [y, Fs] = audioread('C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav');
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
        
        if(~get(handles.checkbox14, 'Value'))
            Y=Y(1:min(portionLength*Fs, length(Y)));
        end
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
    case 'rerun'
        synthMethodSelected=get(handles.popupmenu2, 'Value');
        synthMethods=get(handles.popupmenu2, 'String');
        synth = handles.SynthesisObject;
        
        if(strcmp(synthMethods(synthMethodSelected), 'NNMF'))
            
            costMetricSelected=get(handles.popupmenu3, 'Value');
            costMetrics=get(handles.popupmenu3, 'String');
            
            synth.synthesize('NNMF', costMetrics(costMetricSelected), str2num(get(handles.edit13, 'String')), 'repititionRestricted', get(handles.checkbox7, 'Value'), ...
                'continuityEnhanced', get(handles.checkbox9, 'Value'), 'polyphonyRestricted', get(handles.checkbox8, 'Value'), 'convergenceCriteria', str2double(get(handles.edit15, 'String')), ...
                'r', str2double(get(handles.edit19, 'String')), 'c', str2double(get(handles.edit21, 'String')), 'p', str2double(get(handles.edit20, 'String')));
        end
        
        
        handles.SynthesisObject = synth;
        guidata(handles.figure1, handles);
    case 'runAnalysis'
        portionLength = str2num(get(handles.edt_sndlen, 'String'));
        windowLength = str2num(get(handles.edt_winlen, 'String'));
        overlap = str2num(get(handles.edt_overlap, 'String'));
        [Y, Fs] = audioread(handles.corpusfile);
        [Y2, Fs2] = audioread(handles.targetfile);
        
        %Convert to Monophonic sound
        if(size(Y, 2) ~= 1)
            Y = (Y(:,1)+Y(:,2))/2;
        elseif(size(Y2, 2) ~= 1)
            Y2 = (Y2(:,1)+Y2(:,2))/2;
        end
        
        if(~get(handles.chk_corpuslen, 'Value'))
            Y=Y(1:min(portionLength*Fs, length(Y)));
        end
        Y2=Y2(1:min(portionLength*Fs, length(Y2)));
        synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
        
        spectTypeSelected=get(handles.pop_specttype, 'Value');
        spectTypes=get(handles.pop_specttype, 'String');
        synth.computeSpectrogram('Source', spectTypes(spectTypeSelected));
        synth.computeSpectrogram('Target', spectTypes(spectTypeSelected));
        handles.SynthesisObject = synth;
    case 'runSynthesis'
        synthObj = handles.SynthesisObject;
%         synthMethodSelected=get(handles.pop_synthmethod, 'Value');
%         synthMethods=get(handles.pop_synthmethod, 'String');
        
%         if(strcmp(synthMethods(synthMethodSelected), 'NNMF'))
            
            costMetricSelected=get(handles.pop_cost, 'Value');
            costMetrics=get(handles.pop_cost, 'String');
            
            synthObj.synthesize('NNMF', costMetrics(costMetricSelected), str2num(get(handles.edt_iter, 'String')), 'repititionRestricted', get(handles.chk_mod_rep, 'Value'), ...
                                'continuityEnhanced', get(handles.chk_mod_cont, 'Value'), 'polyphonyRestricted', get(handles.chk_mod_poly, 'Value'), 'convergenceCriteria', str2double(get(handles.edt_conv, 'String')), ...
                                    'r', str2double(get(handles.edt_mod_rep, 'String')), 'c', str2double(get(handles.edt_mod_cont, 'String')), 'p', str2double(get(handles.edt_mod_poly, 'String')));
%         end
        
        resynthMethodSelected=get(handles.pop_synthmethod, 'Value');
        resynthMethods=get(handles.pop_synthmethod, 'String');
        synthObj.resynthesize(resynthMethods(resynthMethodSelected));
        
        handles.SynthesisObject = synthObj;
    case 'selectPlot'
        selectedPlot=get(handles.pop_plot, 'Value');
        plotOptions=get(handles.pop_plot, 'String');
        delete(handles.axes2.Children);
        plotRequest = plotOptions(selectedPlot);
%         view(0, 90);
        switch(plotRequest{1})
            case 'Resynthesis'
%                 set(handles.figure1, 'CurrentAxes', handles.ResynthesisPlot);
                handles.SynthesisObject.showResynthesis;
                set(handles.tbl_plotdata, 'Data', handles.SynthesisObject.Resynthesis');
%                 fig2plotly()
            case 'Cost'
%                 set(handles.figure1, 'CurrentAxes', handles.CostPlot);
                handles.SynthesisObject.NNMFSynthesis.showCost;
                set(handles.tbl_plotdata, 'Data', handles.SynthesisObject.NNMFSynthesis.Cost');
%                 fig2plotly()
            case 'Activations'
%                 set(handles.figure1, 'CurrentAxes', handles.ActivationsPlot);
                handles.SynthesisObject.NNMFSynthesis.showActivations(handles.SynthesisObject, get(handles.sld_maxdb, 'Value'));
                set(handles.tbl_plotdata, 'Data', handles.SynthesisObject.NNMFSynthesis.Activations);
%                 fig2plotly()
            case 'Source Spectrogram'
%                 set(handles.figure1, 'CurrentAxes', handles.ActivationsPlot);
                handles.SynthesisObject.SourceSpectrogram.showSpectrogram(80);
                set(handles.tbl_plotdata, 'Data', abs(handles.SynthesisObject.SourceSpectrogram.S));
%                 fig2plotly()
            case 'Target Spectrogram'
                handles.SynthesisObject.TargetSpectrogram.showSpectrogram(80);
                set(handles.tbl_plotdata, 'Data', abs(handles.SynthesisObject.TargetSpectrogram.S));
            case 'Synthesis Spectrogram'
                resynthSpectrogram = Spectrogram(handles.SynthesisObject.NNMFSynthesis.Reconstruction, ...
                                        handles.SynthesisObject.TargetSpectrogram.F, handles.SynthesisObject.TargetSpectrogram.T);
                resynthSpectrogram.showSpectrogram(80);
                set(handles.tbl_plotdata, 'Data', abs(resynthSpectrogram.S));
            case 'Source Templates'
                handles.SynthesisObject.showTemplates;
                set(handles.tbl_plotdata, 'Data', abs(handles.SynthesisObject.SourceSpectrogram.S));
%                 fig2plotly()
        end
end

guidata(handles.figure1, handles);
% function performCalculations()
% function verifyParameters()