function controller(action, handles)

switch action
    case 'openTarget'
        [filename pathname] = uigetfile({'*.wav;*.mp3;'}, 'File Selector');
        targetpathname= strcat(pathname, filename);
        handles.Sound_target = Sound(targetpathname);
        set(handles.txt_targetfile, 'String', filename);
        set(handles.txt_targetfile,'TooltipString',filename);       
    case 'openSource'
        [filenames pathname]= uigetfile({'*.wav;*.mp3;'}, 'File Selector', 'MultiSelect','on');
        
        if( iscell( filenames ) )
            for i = 1:length( filenames )
                sourcepathname = strcat(pathname, filenames{i});
                tmp_snd = Sound(sourcepathname);
                if isfield(handles, 'Sound_corpus')
                    handles.Sound_corpus = handles.Sound_corpus.concat( tmp_snd );
                else
                    handles.Sound_corpus = tmp_snd;                
                end
            end
            
            cat_files = strjoin(filenames,'\n');
            set(handles.txt_corpusfile, 'String', cat_files);
            set(handles.txt_corpusfile,'TooltipString', char(cat_files));
        else
            sourcepathname = strcat(pathname, filenames);
            handles.Sound_corpus = Sound(sourcepathname);    
            set(handles.txt_corpusfile, 'String', filenames);
            set(handles.txt_corpusfile,'TooltipString', filenames);
        end
                    
    case 'swapSourceAndTarget'
        tmp = handles.Sound_target;
        handles.Sound_target = handles.Sound_corpus;
        handles.Sound_corpus = tmp;
        
        corpus_displayName = get( handles.txt_corpusfile, 'String' );
        corpus_tooltip = get( handles.txt_corpusfile, 'TooltipString' );
        target_displayName = get( handles.txt_targetfile, 'String' );
        target_tooltip = get( handles.txt_targetfile, 'TooltipString' );
                
        set(handles.txt_targetfile, 'String', corpus_displayName);
        set(handles.txt_targetfile,'TooltipString', corpus_tooltip); 
        set(handles.txt_corpusfile, 'String', target_displayName);
        set(handles.txt_corpusfile,'TooltipString', target_tooltip);
    case 'playTarget'
        handles.Sound_target.control_audio('play');
    case 'stopTarget'
        handles.Sound_target.control_audio('stop');
    case 'playSynthesis'
        handles.Sound_synthesis.control_audio('play');
    case 'stopSynthesis'
        handles.Sound_synthesis.control_audio('stop');
    case 'runAnalysis'
        waitbarHandle = waitbar(0.15, 'Verifying parameters...');
        spectTypeSelected=get(handles.pop_specttype, 'Value');
        spectTypes=get(handles.pop_specttype, 'String');

        winTypeSelected=get(handles.pop_wintype, 'Value');
        winTypes=get(handles.pop_wintype, 'String');

        win.Length = str2num(get(handles.edt_winlen, 'String'))*44100/1000;
        win.Hop = str2num(get(handles.edt_overlap, 'String'))*44100/1000;
        win.Type = cell2mat(winTypes(winTypeSelected));
        
        CacheObj = AnalysisCache(handles.Sound_corpus.Signal, handles.Sound_target.Signal, ...
            winTypeSelected, win.Length, win.Hop);
        handles.CurrentAnalysisCache = CacheObj;
        if( strcmp(get(handles.tool_menu_dev_cacheEnable, 'Checked'), 'on') )
            waitbar(0.33, waitbarHandle,'Checking cache...');

            GenerateHash(CacheObj);
            Cached = ExistsInCache(CacheObj.Hash, handles, 'Analysis');

            if( ~Cached )
                waitbar(0.66, waitbarHandle, 'Analyzing corpus...')
                handles.Sound_corpus.computeFeatures(win, spectTypes(spectTypeSelected));

                waitbar(0.95, waitbarHandle, 'Analyzing target...')
                handles.Sound_target.computeFeatures(win, spectTypes(spectTypeSelected));

                waitbar(0.98, waitbarHandle, 'Saving in cache...')       

                DataToCache = struct( ...
                    'Corpus', handles.Sound_corpus, ...
                    'Target', handles.Sound_target ...
                );
                handles.Cache = SaveInCache( CacheObj, handles, 'Analysis', DataToCache );
            else
                waitbar(0.75, waitbarHandle, 'Hooray, exists in cache! Loading...')
                FromCache = LoadFromCache( CacheObj.Hash, 'Analysis' );
                handles.Sound_corpus = FromCache.Corpus;
                handles.Sound_target = FromCache.Target;
            end
        else
            waitbar(0.66, waitbarHandle, 'Analyzing corpus...')
            handles.Sound_corpus.computeFeatures(win, spectTypes(spectTypeSelected));

            waitbar(0.95, waitbarHandle, 'Analyzing target...')
            handles.Sound_target.computeFeatures(win, spectTypes(spectTypeSelected));
        end
        close(waitbarHandle);
    case 'runSynthesis'
        waitbarHandle = waitbar(0.15, 'Checking cache...');
        costMetricSelected=get(handles.pop_cost, 'Value');
        costMetrics=get(handles.pop_cost, 'String');
        
        actPatternSelected=get(handles.pop_pattern, 'Value');
        actPatterns=get(handles.pop_pattern, 'String');
        
        nmf_params.Algorithm =  cell2mat(costMetrics(costMetricSelected));
        nmf_params.Iterations = str2num(get(handles.edt_iter, 'String'));
        nmf_params.Convergence_criteria = str2double(get(handles.edt_conv, 'String'));
        nmf_params.Repition_restriction = str2double(get(handles.edt_mod_rep, 'String'));
        nmf_params.Polyphony_restriction = str2double(get(handles.edt_mod_poly, 'String'));
        nmf_params.Continuity_enhancement = str2double(get(handles.edt_mod_cont, 'String'));
        nmf_params.Continuity_enhancement_rot = str2double(get(handles.edt_mod_cont_rot, 'String'));
        nmf_params.Diagonal_pattern =  cell2mat(actPatterns(actPatternSelected));
        nmf_params.Modification_application = get(handles.chk_endtime, 'Value');
        nmf_params.Random_seed = str2double(get(handles.edt_rand, 'String'));
        nmf_params.Lambda = str2double(get(handles.edt_sparse_lambda, 'String'));
        
        resynthMethodSelected=get(handles.pop_synthmethod, 'Value');
        resynthMethods=get(handles.pop_synthmethod, 'String');

        pct_prune = ( 100 - str2double(get(handles.edt_prune, 'String')) )/100;
        synth = CSS(nmf_params, cell2mat(resynthMethods(resynthMethodSelected)));
        
        % Cache related operations
%         if( strcmp(get(handles.tool_menu_dev_cacheEnable, 'Checked'), 'on') )
            GenerateHash(handles.CurrentAnalysisCache);
            CacheObj = SynthesisCache( ...
                nmf_params.Iterations, nmf_params.Random_seed, nmf_params.Convergence_criteria, ...
                costMetricSelected, nmf_params.Repition_restriction, nmf_params.Polyphony_restriction, ...
                nmf_params.Continuity_enhancement, actPatternSelected, nmf_params.Continuity_enhancement_rot, ...
                nmf_params.Modification_application, nmf_params.Lambda, pct_prune, handles.CurrentAnalysisCache.Hash );

            GenerateHash(CacheObj);
            Cached = ExistsInCache(CacheObj.Hash, handles, 'Synthesis');
            disp( CacheObj.Hash );
        
            if( ~Cached )       
                waitbar(0.5, waitbarHandle, 'Not found in cache. Running NMF...')
                synth.nmf(handles.Sound_corpus, handles.Sound_target, pct_prune);

                waitbar(0.75, waitbarHandle, 'Saving in cache...')
                DataToCache = struct( ...
                    'Activations', synth.Activations, ...
                    'Cost', synth.Cost ...
                );

                handles.Cache = SaveInCache( CacheObj, handles, 'Synthesis', DataToCache );
            else
                waitbar(0.75, waitbarHandle, 'Hooray, exists in cache! Loading...')
                FromCache = LoadFromCache( CacheObj.Hash, 'Synthesis' );
                synth.Activations = FromCache.Activations;
                synth.Cost = FromCache.Cost;
            end  
%         else
%         	synth.nmf(handles.Sound_corpus, handles.Sound_target);
%         end
        
        synth.synthesize(handles.Sound_corpus);

        winTypeSelected=get(handles.pop_wintype, 'Value');
        winTypes=get(handles.pop_wintype, 'String');

        win.Length = str2num(get(handles.edt_winlen, 'String'))*44100/1000;
        win.Hop = str2num(get(handles.edt_overlap, 'String'))*44100/1000;
        win.Type = cell2mat(winTypes(winTypeSelected));

        spectTypeSelected=get(handles.pop_specttype, 'Value');
        spectTypes=get(handles.pop_specttype, 'String');

        handles.SynthesisObject = synth;
        handles.Sound_synthesis = Sound(synth.Synthesis, handles.Sound_corpus.Sampling_rate);
        handles.Sound_synthesis.computeFeatures(win, spectTypes(spectTypeSelected));
        
        close(waitbarHandle);
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
                handles.SynthesisObject.plot_cost;
                set(handles.tbl_plotdata, 'Data', handles.SynthesisObject.Cost');
            case 'Activations'
                view(gca, 2);
                handles.SynthesisObject.plot_activations(get(handles.sld_maxdb, 'Value'));
                set(handles.tbl_plotdata, 'Data', handles.SynthesisObject.Activations);
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
                set(handles.tbl_plotdata, 'Data', abs(handles.Sound_synthesis.Features.STFT.S));
            case 'Templates'
                view(gca, 3);
                handles.Sound_corpus.plot_templates;
                set(handles.tbl_plotdata, 'Data', abs(handles.Sound_corpus.Features.STFT.S));
        end
    case 'resynthesize'
        synth = handles.SynthesisObject;
        synth.synthesize(handles.Sound_corpus);
        handles.SynthesisObject = synth;
        handles.Sound_synthesis.Audioplayer = audioplayer(handles.SynthesisObject.Synthesis, handles.Sound_corpus.Sampling_rate);
    case 'rerun'
        resynthMethodSelected=get(handles.pop_synthmethod, 'Value');
        resynthMethods=get(handles.pop_synthmethod, 'String');
        nmf_params = handles.SynthesisObject.NMF_features;
        
        pct_prune = ( 100 - str2double(get(handles.edt_prune, 'String')) )/100;
        synth = CSS(nmf_params, cell2mat(resynthMethods(resynthMethodSelected)));
        synth.nmf(handles.Sound_corpus, handles.Sound_target, pct_prune);
        synth.synthesize(handles.Sound_corpus);
        
        handles.SynthesisObject = synth;
end

guidata(handles.figure1, handles);
end