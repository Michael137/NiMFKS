function varargout = GUI_app(varargin)
% GUI_APP MATLAB code for GUI_app.fig
%      GUI_APP, by itself, creates a new GUI_APP or raises the existing
%      singleton*.
%
%      H = GUI_APP returns the handle to a new GUI_APP or the handle to
%      the existing singleton*.
%
%      GUI_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_APP.M with the given input arguments.
%
%      GUI_APP('Property','Value',...) creates a new GUI_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_app_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_app_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_app

% Last Modified by GUIDE v2.5 16-Mar-2016 23:43:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_app_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_app_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_app is made visible.
function GUI_app_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_app (see VARARGIN)
%Place "playback" symbol onto buttons
[a,map]=imread('C:\Users\User\Dropbox\Programs\MFAMC\MFAMC\assets\playButton.jpg');
[r,c,d]=size(a); 
x=ceil(r/30); 
y=ceil(c/30); 
g=a(1:x:end,1:y:end,:);
g(g==255)=5.5*255;
set(handles.playSource_btn,'CData',g);
set(handles.playTarget_btn,'CData',g);  
set(handles.playSynth_btn,'CData',g);

%Set resynthesis file explorer and restriction parameters to invisible
set([handles.playSynth_btn, handles.synth_txt handles.synth_edit, handles.text21, handles.openTarget_btn, handles.playTarget_btn, handles.text5, handles.playSource_btn, handles.synth_btn, handles.viewParams_btn],'Visible','off')

%Initialize parameters
handles.edit9 = 400; %Window Length
handles.edit10 = 200; %Overlap
handles.sourceLen = 5;
handles.edit11 = 5; %Target Length
handles.checkbox14 = 1; %Full length checkbox
handles.convergenceCriteria = 0.0005;
handles.costMetrics = {'Fast Euclidean', 'Fast Divergence',  'Euclidean',  'Divergence'};
handles.costMetricSelected = 1;
handles.iterations = 26;
handles.repRestrictVal = 0;
handles.repititionRestricted = 0;
handles.polyRestrictVal = 100;
handles.polyphonyRestricted = 0;
handles.contEnhancedVal = 1;
handles.continuityEnhanced = 0;
%Currently not included in settings GUIs
handles.synthMethods = {'ISTFT', 'Template Addition'};
handles.synthMethodSelected = 1;

% Choose default command line output for GUI_app
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_app wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_app_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function tools_developer_timer_menu_Callback(hObject, eventdata, handles)
% hObject    handle to tools_developer_timer_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function tools_developer_wkspace_menu_Callback(hObject, eventdata, handles)
% hObject    handle to tools_developer_wkspace_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_stft_winlen_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_stft_winlen_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  Create and then hide the UI as it is being constructed.

% --------------------------------------------------------------------
function settings_stft_overlap_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_stft_overlap_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_stft_length_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_stft_length_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_stft_spect_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_stft_spect_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_synthesis_method_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_synthesis_method_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_synthesis_cost_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_synthesis_cost_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_synthesis_resynthesis_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_synthesis_resynthesis_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_stft_fulllength_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_stft_fulllength_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_stft_length_setsource_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_stft_length_setsource_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_export_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_export_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_synthesis_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_synthesis_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function settings_stft_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_stft_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   f = figure('Visible','off','Position',[500,500, 300, 300], 'Resize', 'off');
   
   %  Construct the components. 
   htext_winlen = uicontrol('Style','text','String','Window Length:',...
           'Position',[75,110,70,35]);
   hwinlength = uicontrol('Style','edit', ...
       'Position',[150,110,35,25], 'tag', 'edit9');
   
   htext_overlap = uicontrol('Style','text','String','Overlap:',...
       'Position',[75,55,70,35]);
   
   hoverlap = uicontrol('Style','edit', ...
       'Position',[150,55,35,25], 'tag', 'edit10');
   
   htext_source_length = uicontrol('Style','text','String','Source Length:',...
       'Position',[75,165,70,35]);
   
   hsourcelength =  uicontrol('Style','edit', ...
       'Position',[150,165,35,25], 'tag', 'source_length_edit', 'Enable', 'off');
   
   htext_target_length = uicontrol('Style','text','String','Target Length:',...
       'Position',[75,220,70,35]);
   
   htargetlength =  uicontrol('Style','edit', ...
       'Position',[150,220,35,25], 'tag', 'edit11');
      
   htext_full_length = uicontrol('Style','text','String','Full Length:',...
       'Position',[75,255,70,35]);
   
   hcheckbox_full_length =  uicontrol('Style','checkbox', ...
       'Position',[150,270,35,25], 'tag', 'checkbox14', 'Value', 1);
   
   hbutton = uicontrol('Style','pushbutton',...
       'String','OK',...
       'Position',[100,10,70,25], 'Callback',{@hbutton_Callback, handles, hObject});
   align([htext_winlen, htext_overlap, htext_source_length, htext_target_length],'Center','None');
   align([hwinlength, hoverlap, hsourcelength, htargetlength],'Center','None');
   
   if(isfield(handles,'edit11'))
       set(findobj(gcf, 'tag', 'edit9'), 'String', handles.edit9);
       set(findobj(gcf, 'tag', 'edit10'), 'String', handles.edit10);
       set(findobj(gcf, 'tag', 'edit11'), 'String', handles.edit11);
       set(findobj(gcf, 'tag', 'checkbox14'), 'Value', handles.checkbox14);
   end
   
   f.MenuBar = 'none';
   f.ToolBar = 'none';
   %Make the UI visible.
   f.Visible = 'on';
   
    function hbutton_Callback(source,eventdata, handles, hObject)
        % Display surf plot of the currently selected data.
        handles.edit9 = str2double(get(findobj(gcf, 'tag', 'edit9'), 'String')); %Window Length
        handles.edit10 = str2double(get(findobj(gcf, 'tag', 'edit10'), 'String')); %Overlap
        handles.sourceLen = str2double(get(findobj(gcf, 'tag', 'source_length_edit'), 'String'));
        handles.edit11 = str2double(get(findobj(gcf, 'tag', 'edit11'), 'String')); %Target Length
        handles.checkbox14 = get(findobj(gcf, 'tag', 'checkbox14'), 'Value'); %Full length checkbox
        
        guidata(hObject, handles);
        close(get(source, 'Parent'))

% --------------------------------------------------------------------
function settings_nnmf_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_nnmf_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = figure('Visible','off','Position',[500,500, 300, 300], 'Resize', 'off');
   
   %  Construct the components. 
   htext_iter = uicontrol('Style','text','String','Iterations:',...
           'Position',[75,165,70,35]);
   hiter = uicontrol('Style','edit', ...
       'Position',[150,165,35,25], 'tag', 'edit13');
   
   htext_conv = uicontrol('Style','text','String','Convergence Criteria:',...
       'Position',[75,110,70,35]);
   hconv = uicontrol('Style','edit', ...
       'Position',[150,110,35,25], 'tag', 'conv_edit');
   
   htext_cost = uicontrol('Style','text','String','Cost Metric:',...
       'Position',[75,55,70,35]);
   hcost = uicontrol('Style','popupmenu', ...
       'Position',[150,55,100,25], 'tag', 'popupmenu3', 'String', {'Fast Euclidean', 'Fast Divergence', 'Euclidean', 'Divergence'}, 'Value', 1);
      
   htext_represtrict = uicontrol('Style','text','String','Repitition Restriction:',...
       'Position',[75,200,75,35]);
   hreprestrict = uicontrol('Style','checkbox', ...
       'Position',[220,200,35,25], 'tag', 'represtrict_checkbox', 'Value', 1);
   hreprestrictVal = uicontrol('Style','edit', ...
       'Position',[180,200,35,25], 'tag', 'represtrict_edit');
   
   htext_polyrestrict = uicontrol('Style','text','String','Polyphony Restriction:',...
       'Position',[75,230,75,35]);
   hpolyrestrict = uicontrol('Style','checkbox', ...
       'Position',[220,230,35,25], 'tag', 'polyrestrict_checkbox', 'Value', 1);
   hpolyrestrictVal = uicontrol('Style','edit', ...
       'Position',[180,230,35,25], 'tag', 'polyrestrict_edit');
   
   htext_contenhanced = uicontrol('Style','text','String','Continuity Enhanced:',...
       'Position',[75,260,75,35]);
   hcontenhanced = uicontrol('Style','checkbox', ...
       'Position',[220,260,35,25], 'tag', 'contenhanced_checkbox', 'Value', 1);
   hcontenhancedVal = uicontrol('Style','edit', ...
       'Position',[180,260,35,25], 'tag', 'contenhanced_edit');
   
   %    hcheckbox_full_length =  uicontrol('Style','checkbox', ...
   %        'Position',[150,270,35,25], 'tag', 'length_checkbox', 'Value', 1);
   
   hbutton = uicontrol('Style','pushbutton',...
       'String','OK',...
       'Position',[100,10,70,25], 'Callback',{@hbutton_nnmf_Callback, handles, hObject});
   align([htext_iter, htext_conv, htext_cost, htext_represtrict, htext_polyrestrict, htext_contenhanced],'Center','None');
   align([hiter, hconv, hcost, hreprestrictVal, hpolyrestrictVal, hcontenhancedVal],'Center','None');
   
   if(isfield(handles,'convergenceCriteria'))
       set(findobj(gcf, 'tag', 'conv_edit'), 'String', handles.convergenceCriteria);
       set(findobj(gcf, 'tag', 'popupmenu3'), 'Value', find(strcmp(handles.costMetrics, cell2mat(handles.costMetrics(handles.costMetricSelected))), 1));
       set(findobj(gcf, 'tag', 'edit13'), 'String', handles.iterations);
       set(findobj(gcf, 'tag', 'represtrict_edit'), 'String', handles.repRestrictVal);
       set(findobj(gcf, 'tag', 'represtrict_checkbox'), 'Value', handles.repititionRestricted);
       set(findobj(gcf, 'tag', 'polyrestrict_edit'), 'String', handles.polyRestrictVal);
       set(findobj(gcf, 'tag', 'polyrestrict_checkbox'), 'Value', handles.polyphonyRestricted);
       set(findobj(gcf, 'tag', 'contenhanced_edit'), 'String', handles.contEnhancedVal);
       set(findobj(gcf, 'tag', 'contenhanced_checkbox'), 'Value', handles.continuityEnhanced);
   end
   
   f.MenuBar = 'none';
   f.ToolBar = 'none';
   %Make the UI visible.
   f.Visible = 'on';
   
    function hbutton_nnmf_Callback(source,eventdata, handles, hObject)
        % Display surf plot of the currently selected data.
        handles.convergenceCriteria = str2double(get(findobj(gcf, 'tag', 'conv_edit'), 'String'));
        handles.costMetrics = get(findobj(gcf, 'tag', 'popupmenu3'), 'String');
        handles.costMetricSelected = get(findobj(gcf, 'tag', 'popupmenu3'), 'Value');
        handles.iterations = str2double(get(findobj(gcf, 'tag', 'edit13'), 'String'));
        handles.repRestrictVal = str2double(get(findobj(gcf, 'tag', 'represtrict_edit'), 'String'));
        handles.repititionRestricted = get(findobj(gcf, 'tag', 'represtrict_checkbox'), 'Value');
        handles.polyRestrictVal = str2double(get(findobj(gcf, 'tag', 'polyrestrict_edit'), 'String'));
        handles.polyphonyRestricted = get(findobj(gcf, 'tag', 'polyrestrict_checkbox'), 'Value');
        handles.contEnhancedVal = str2double(get(findobj(gcf, 'tag', 'contenhanced_edit'), 'String'));
        handles.continuityEnhanced = get(findobj(gcf, 'tag', 'contenhanced_checkbox'), 'Value');
        guidata(hObject, handles);
        close(get(source, 'Parent'))


% --- Executes on button press in openSource_btn.
function openSource_btn_Callback(hObject, eventdata, handles)
% hObject    handle to openSource_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SynthesisCtr('openSource', handles);
set([handles.text21, handles.openTarget_btn, handles.playSource_btn],'Visible','on')

% --- Executes on button press in openTarget_btn.
function openTarget_btn_Callback(hObject, eventdata, handles)
% hObject    handle to openTarget_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SynthesisCtr('openTarget', handles);
set([handles.playTarget_btn, handles.text5, handles.synth_btn], 'Visible', 'on')


% --- Executes on button press in synth_btn.
function synth_btn_Callback(hObject, eventdata, handles)
% hObject    handle to synth_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitbarHandle = waitbar(0, 'Starting Synthesis...'); 
handles.waitbarHandle = waitbarHandle;
guidata(hObject, handles);
SynthesisAppCtr('run', handles);
close(waitbarHandle)
set([handles.synth_txt, handles.synth_edit, handles.playSynth_btn, handles.viewParams_btn],'Visible','on')
SynthesisAppCtr('openResynthesis', handles);

% --- Executes on button press in playTarget_btn.
function playTarget_btn_Callback(hObject, eventdata, handles)
% hObject    handle to playTarget_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SynthesisCtr('playTarget', handles);

% --- Executes on button press in playSource_btn.
function playSource_btn_Callback(hObject, eventdata, handles)
% hObject    handle to playSource_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SynthesisCtr('playSource', handles);

% --- Executes on button press in playSynth_btn.
function playSynth_btn_Callback(hObject, eventdata, handles)
% hObject    handle to playSynth_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SynthesisAppCtr('playResynthesis', handles);

% --- Executes on button press in viewParams_btn.
function viewParams_btn_Callback(hObject, eventdata, handles)
% hObject    handle to viewParams_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = figure('Visible','off','Position',[500,500, 300, 300], 'Resize', 'off');
   
    %  Construct the components.
    htext_iter = uicontrol('Style','text','String','Iterations:',...
        'Position',[40,250,70,35]);
    htext_conv = uicontrol('Style','text','String','Convergence Criteria (%):',...
        'Position',[40,210,70,35]);
    htext_cost = uicontrol('Style','text','String','Cost Metric:',...
        'Position',[40,170,70,35]);
    htext_winlen = uicontrol('Style','text','String','Window Length (ms):',...
        'Position',[40,130,70,35]);
    htext_hop = uicontrol('Style','text','String','Overlap (ms):',...
        'Position',[40,90,70,35]);
    htext_sourcelen = uicontrol('Style','text','String','Source Length (s):',...
        'Position',[40,50,70,35]);
    htext_targetlen = uicontrol('Style','text','String','Target Length (s):',...
        'Position',[40,10,70,35]);
    align([htext_iter, htext_conv, htext_cost, htext_winlen, htext_hop, htext_sourcelen, htext_targetlen],'Center','None');
    
    htext_iterVal = uicontrol('Style','text','String',handles.iterations,...
        'Position',[150,250,70,35]);
    htext_convVal = uicontrol('Style','text','String',100*handles.convergenceCriteria,...
        'Position',[150,210,70,35]);
    htext_costVal = uicontrol('Style','text','String',handles.costMetrics(handles.costMetricSelected),...
        'Position',[150,170,70,35]);
    htext_winlenVal = uicontrol('Style','text','String',handles.edit9,...
        'Position',[150,130,70,35]);
    htext_hopVal = uicontrol('Style','text','String',handles.edit10,...
        'Position',[150,90,70,35]);
    htext_sourcelenVal = uicontrol('Style','text','String',handles.sourceLen,...
        'Position',[150,50,70,35]);
    htext_targetlenVal = uicontrol('Style','text','String',handles.edit11,...
        'Position',[150,10,70,35]);
    align([htext_iterVal, htext_convVal, htext_costVal, htext_winlenVal, htext_hopVal, htext_sourcelenVal, htext_targetlenVal],'Center','None');
    
    f.MenuBar = 'none';
    f.ToolBar = 'none';
    %Make the UI visible.
    f.Visible = 'on';


% --------------------------------------------------------------------
function tools_plots_menu_Callback(hObject, eventdata, handles)
% hObject    handle to tools_plots_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_app_plots(handles)
