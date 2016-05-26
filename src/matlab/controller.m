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
        handles.Sound_target.control_audio('play');
    case 'stopTarget'
        handles.Sound_target.control_audio('stop');
    case 'playSource'
        handles.Sound_corpus.control_audio('play');
    case 'stopSource'
        handles.Sound_corpus.control_audio('stop');
    case 'playResynthesis'
    case 'runAnalysis'
        spectTypeSelected=get(handles.pop_specttype, 'Value');
        spectTypes=get(handles.pop_specttype, 'String');
        
        win.Length = str2num(get(handles.edt_winlen, 'String'))*44100/1000;
        win.Hop = str2num(get(handles.edt_overlap, 'String'))*44100/1000;
        win.Type = 'Hamming';
        
        handles.Sound_corpus.computeFeatures(win, spectTypes(spectTypeSelected));
        handles.Sound_target.computeFeatures(win, spectTypes(spectTypeSelected));
    case 'runSynthesis'
        costMetricSelected=get(handles.pop_cost, 'Value');
        costMetrics=get(handles.pop_cost, 'String');
        
        nmf_params.Algorithm =  cell2mat(costMetrics(costMetricSelected));
        nmf_params.Iterations = str2num(get(handles.edt_iter, 'String'));
        nmf_params.Convergence_criteria = str2double(get(handles.edt_conv, 'String'));
        nmf_params.Repition_restriction = str2double(get(handles.edt_mod_rep, 'String'));
        nmf_params.Polyphony_restriction = str2double(get(handles.edt_mod_poly, 'String'));
        nmf_params.Continuity_enhancement = str2double(get(handles.edt_mod_cont, 'String'));
        nmf_params.Diagonal_pattern = 'Diagonal';
        nmf_params.Modification_application = false;
        nmf_params.Random_seed = 'shuffle';
        
        resynthMethodSelected=get(handles.pop_synthmethod, 'Value');
        resynthMethods=get(handles.pop_synthmethod, 'String');
        
        synth = CSS(nmf_params, cell2mat(resynthMethods(resynthMethodSelected)));
        synth.nmf(handles.Sound_corpus, handles.Sound_target);
        synth.synthesize(handles.Sound_corpus);
        
        win.Length = str2num(get(handles.edt_winlen, 'String'))*44100/1000;
        win.Hop = str2num(get(handles.edt_overlap, 'String'))*44100/1000;
        win.Type = 'Hamming';
        
        spectTypeSelected=get(handles.pop_specttype, 'Value');
        spectTypes=get(handles.pop_specttype, 'String');
        
        handles.SynthesisObject = synth;
        handles.Sound_synthesis = Sound(synth.Synthesis, handles.Sound_corpus.Sampling_rate);
        handles.Sound_synthesis.computeFeatures(win, spectTypes(spectTypeSelected));
    case 'savePlot'
    case 'exportResynth'
    case 'switchPlot'
        selectedPlot=get(handles.pop_plot, 'Value');
        plotOptions=get(handles.pop_plot, 'String');
        delete(handles.axes2.Children);
        cla(gca,'reset')
        plotRequest = plotOptions(selectedPlot);
        switch(plotRequest{1})
            case 'Synthesis Plot'
                view(gca, 2);
                handles.Sound_synthesis.plot_signal;
                set(handles.tbl_plotdata, 'Data', handles.Sound_synthesis.Signal');
            case 'Cost'
                view(gca, 2);
                handles.SynthesisObject.NNMFSynthesis.showCost;
                set(handles.tbl_plotdata, 'Data', handles.SynthesisObject.NNMFSynthesis.Cost');
            case 'Activations'
                view(gca, 2);
                handles.SynthesisObject.NNMFSynthesis.showActivations(handles.SynthesisObject, get(handles.sld_maxdb, 'Value'));
                set(handles.tbl_plotdata, 'Data', handles.SynthesisObject.NNMFSynthesis.Activations);
            case 'Corpus Spectrogram'
                view(gca, 2);
                handles.Sound_corpus.plot_spectrogram;
                set(handles.tbl_plotdata, 'Data', abs(handles.Sound_corpus.Features.STFT.S));
            case 'Target Spectrogram'
                view(gca, 2);
                handles.Sound_target.plot_spectrogram;
                set(handles.tbl_plotdata, 'Data', abs(handles.Sound_target.Features.STFT.S));
            case 'Synthesis Spectrogram'
                view(gca, 2);
                handles.Sound_synthesis.plot_spectrogram;
                set(handles.tbl_plotdata, 'Data', abs(handles.Sound_synthesis.plot_spectrogram));
            case 'Templates'
                view(gca, 3);
                handles.SynthesisObject.showTemplates;
                set(handles.tbl_plotdata, 'Data', abs(handles.SynthesisObject.SourceSpectrogram.S));
        end
    case 'resynthesize'
    case 'rerun'
end

guidata(handles.figure1, handles);
end