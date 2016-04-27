function decibelSliderReleaseCallback(src,callbackdata)

handles = guidata(src);
maxDB = get(handles.slider4, 'Value');
handles.SynthesisObject.NNMFSynthesis.showActivations(handles.SynthesisObject, maxDb);