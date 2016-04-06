function SynthesisAppCtr(action, datastruct)

handles = datastruct;
[pathstr, ~, ~] = fileparts(pwd);

switch action
    case 'openResynthesis'
%         pathname = 'C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\resynthesis.wav';
        pathname = 'resynthesis.wav';
        set(handles.synth_edit, 'String', pathname);
    case 'playResynthesis'
        [y, Fs] = audioread(get(handles.synth_edit, 'String'));
        soundsc(y, Fs);
    case 'run' %Separate into further modules; controller helper functions file
%         verifyParameters(handles)
%         performCalculations(handles)
        waitbar(0.25, handles.waitbarHandle, 'Reading audio files...')
        portionLength = handles.edit11;
        windowLength = handles.edit9;
        overlap = handles.edit10;
        [Y, Fs] = audioread(get(handles.text7, 'String'));
        [Y2, Fs2] = audioread(get(handles.text5, 'String'));
        
        %Convert to Monophonic sound
        if(size(Y, 2) ~= 1)
            Y = (Y(:,1)+Y(:,2))/2;
        elseif(size(Y2, 2) ~= 1)
            Y2 = (Y2(:,1)+Y2(:,2))/2;
        end
        
        if(~handles.checkbox14)
            Y=Y(1:min(portionLength*Fs, length(Y)));
        end
        Y2=Y2(1:min(portionLength*Fs, length(Y2)));
        
        waitbar(0.5, handles.waitbarHandle, 'Performing audio analysis...')
        synth = Synthesis(Y, Y2, Fs, windowLength, overlap);
        
%         spectTypeSelected=get(handles.popupmenu5, 'Value');
%         spectTypes=get(handles.popupmenu5, 'String');
%         synth.computeSpectrogram('Source', spectTypes(spectTypeSelected));
%         synth.computeSpectrogram('Target', spectTypes(spectTypeSelected));

        synth.computeSpectrogram('Source', 'Regular');
        synth.computeSpectrogram('Target', 'Regular');
        
%         synthMethodSelected=get(handles.popupmenu2, 'Value');
%         synthMethods=get(handles.popupmenu2, 'String');
        
        waitbar(0.75, handles.waitbarHandle, 'Performing synthesis...')
        costMetricSelected=handles.costMetricSelected;
        costMetrics=handles.costMetrics;
        
        synth.synthesize('NNMF', costMetrics(costMetricSelected), handles.iterations, ...
                                'continuityEnhanced', handles.continuityEnhanced, 'polyphonyRestricted', handles.polyphonyRestricted, 'convergenceCriteria', handles.convergenceCriteria, ...
                                    'r', handles.repRestrictVal, 'c', handles.contEnhancedVal, 'p', handles.polyRestrictVal);
        
        waitbar(0.9, handles.waitbarHandle, 'Performing resynthesis...')
%         resynthMethodSelected=get(handles.popupmenu4, 'Value');
%         resynthMethods=get(handles.popupmenu4, 'String');
%         synth.resynthesize(resynthMethods(resynthMethodSelected));

        synth.resynthesize(handles.synthMethods(handles.synthMethodSelected));
        
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
end

% function performCalculations()
% function verifyParameters()