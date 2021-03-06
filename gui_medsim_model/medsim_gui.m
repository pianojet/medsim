
function varargout = medsim_gui(varargin)
% MEDSIM_TRAIN MATLAB code for medsim_gui.fig
%      MEDSIM_TRAIN, by itself, creates a new MEDSIM_TRAIN or raises the existing
%      singleton*.
%
%      H = MEDSIM_TRAIN returns the handle to a new MEDSIM_TRAIN or the handle to
%      the existing singleton*.
%
%      MEDSIM_TRAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEDSIM_TRAIN.M with the given input arguments.
%
%      MEDSIM_TRAIN('Property','Value',...) creates a new MEDSIM_TRAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before medsim_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to medsim_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help medsim_gui

% Last Modified by GUIDE v2.5 29-May-2017 18:26:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @medsim_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @medsim_gui_OutputFcn, ...
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


% --- Executes just before medsim_gui is made visible.
function medsim_gui_OpeningFcn(hObject, eventdata, handles, varargin)
  % This function has no output args, see OutputFcn.
  % hObject    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % varargin   command line arguments to medsim_gui (see VARARGIN)

  % Choose default command line output for medsim_gui
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);

  initializeConfig('/Users/justin/Documents/MATLAB/medsim/config/spk_app_config.ini');
  initializeData(handles);
  setappdata(0, 'usrInit', []);
  setappdata(0, 'audio_info', defaultAudioInfo());
  setappdata(0, 'audio_aux', []);
  modelStats_refresh(handles.modelStats);

  % UIWAIT makes medsim_gui wait for user response (see UIRESUME)
  % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = medsim_gui_OutputFcn(hObject, eventdata, handles)
  % varargout  cell array for returning output args (see VARARGOUT);
  % hObject    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)

  % Get default command line output from handles structure
  varargout{1} = handles.output;


function initializeData(handles)
  conf = getappdata(0, 'conf');

  classData.classFocus = 0;
  classData.unsavedClasses = [];
  classData.continuousClassSignals = struct;
  classData.classSampleCounts = struct;
  classData.featuresByClass = struct;
  classData.centers = struct;
  % = containers.Map;
  % classData.centers('30') = [];
  conf.audioFile = '';
  setappdata(0, 'conf', conf);
  setappdata(0, 'classData', classData);
  set(handles.text_unsaved_classes, 'String', '');
  set(handles.text_seconds_display, 'String', '0.0');
  set(handles.edit_label, 'String', 'N/A');
  initializePlayback(handles);


% --- Executes on button press in pushbutton_new.
function pushbutton_new_Callback(hObject, eventdata, handles)
  % hObject    handle to pushbutton_new (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  classData = getappdata(0, 'classData');
  playbackOptions = getappdata(0, 'playbackOptions');
  playbackOptions.signalClassified = [];
  if classData.classFocus == 0
    initializeData(handles);
    classData = getappdata(0, 'classData');
  end
  setappdata(0, 'playbackOptions', playbackOptions);
  loadAudio(handles);



function modelStats_refresh(modelStats)
  conf = getappdata(0, 'conf');
  audio_info = getappdata(0, 'audio_info');
  tableData = [];
  appClassList = [];

  for classNumber = 1:100
    filename = getClassFileName(classNumber);
    if exist(filename) == 2
      classFileData = load(filename);
      label = sprintf(conf.classLabelStr, classNumber);
      displaySeconds = sprintf('%2.2f', (classFileData.classSampleCounts.(label) / audio_info.SampleRate));
      colData = [classNumber {displaySeconds}];
      tableData = [tableData; colData];
      appClassList = [appClassList classNumber];
      % tableData{size(tableData,1)+1, 1} = classNumber;
      % tableData{size(tableData,1)+1, 2} = displaySeconds;
    end
  end
  columnNames = {'Label', 'Seconds'};
  rowNames = {};


  %set(hObject, 'ColumnEditable', {0, 0});
  setappdata(0, 'appClassList', appClassList);
  set(modelStats, 'ColumnWidth', {60});
  set(modelStats, 'ColumnName', columnNames);
  set(modelStats, 'RowName', rowNames);
  set(modelStats, 'Data', tableData);



% % --- Executes during object creation, after setting all properties.
function modelStats_CreateFcn(hObject, eventdata, handles)
%   % hObject    handle to modelStats (see GCBO)
%   % eventdata  reserved - to be defined in a future version of MATLAB
%   % handles    empty - handles not created until after all CreateFcns called
%   % rowNames = {'scan_wintime', 'scan_hoptime', 'topPosteriorThreshold', 'feature_maxfreq', 'mappingType', 'numClusters', 'Classified?', 'Success %'}
%   modelStats_refresh(hObject);


% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
  % hObject    handle to pushbutton_add (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  disp(sprintf('\npushbutton_add_Callback'));

  conf = getappdata(0, 'conf');
  playbackOptions = getappdata(0, 'playbackOptions');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  classData = getappdata(0, 'classData');
  audio_data = getappdata(0, 'audio_data');
  audio_info = getappdata(0, 'audio_info')
  sampleRate = audio_info.SampleRate;

  disp(sprintf('clickpos1: %d, clickpos2: %d', clickpos1, clickpos2));

  % disp('initial classData:');
  % disp(classData);


  if ~((clickpos1 > 1) && (clickpos2 < (length(audio_data) / playbackOptions.downSampleFactor)))
    disp('unusable clickpositions, returning...');
    return
  end

  if classData.classFocus == 0
    disp('missing label for class!');
    return
  end

  clip = getSignalClip(audio_data);
  classNumber = classData.classFocus;
  label = sprintf(conf.classLabelStr, classNumber);
  sigCount = length(classData.continuousClassSignals.(label));
  classData.continuousClassSignals.(label){sigCount+1} = clip;
  classData.classSampleCounts.(label) = classData.classSampleCounts.(label) + length(clip);

  classData.unsavedClasses = sort(unique([classData.unsavedClasses classNumber]));
  unsavedStr = sprintf('%d,', classData.unsavedClasses);
  set(handles.text_unsaved_classes, 'String', unsavedStr(1:end-1));

  % disp('setting classData:');
  % disp(classData);

  setappdata(0, 'classData', classData);
  displaySeconds = sprintf('%2.2f', (classData.classSampleCounts.(label) / audio_info.SampleRate));
  set(handles.text_seconds_display, 'String', displaySeconds);
  disp(sprintf('added signal to class'));
  % modelStats_refresh(handles.modelStats);
  % plotTrainSegments(modelData, playbackOptions);


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
  % hObject    handle to pushbutton_save (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  classData = getappdata(0, 'classData');
  conf = getappdata(0, 'conf');

  classFile = getClassFileName();
  label = sprintf(conf.classLabelStr, classData.classFocus);

  thisClassData = struct;
  thisClassData.continuousClassSignals.(label) = classData.continuousClassSignals.(label);
  thisClassData.classSampleCounts.(label) = classData.classSampleCounts.(label);
  thisClassData.featuresByClass.(label) = classData.featuresByClass.(label);


  save(classFile, '-struct', 'thisClassData');
  modelStats_refresh(handles.modelStats);
  fprintf('%s saved.\n', classFile);
  classData.unsavedClasses(classData.unsavedClasses==classData.classFocus) = [];
  unsavedStr = sprintf('%d,', classData.unsavedClasses);
  set(handles.text_unsaved_classes, 'String', unsavedStr(1:end-1));
  setappdata(0, 'classData', classData);
  disp('classData:');
  disp(classData);



function edit_label_Callback(hObject, eventdata, handles)
  % hObject    handle to edit_label (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)

  % Hints: get(hObject,'String') returns contents of edit_label as text
  %        str2double(get(hObject,'String')) returns contents of edit_label as a double
  classData = getappdata(0, 'classData');
  appClassList = getappdata(0, 'appClassList'); % should be populated with valid class numbers by now
  audio_info = getappdata(0, 'audio_info');
  conf = getappdata(0, 'conf');
  %set(handles.dataPath, 'String', '');


  classNumber = str2num(get(hObject,'String'));
  classData.classFocus = classNumber;
  label = sprintf(conf.classLabelStr, classNumber);

  % skip loading classData if selected class is changed and unsaved locally (dirty)
  if ~any(classData.unsavedClasses==classNumber)

    %
    if any(appClassList==classNumber)
      filename = getClassFileName(classNumber);
      loadedClassData = load(filename);
      classData.continuousClassSignals.(label) = loadedClassData.continuousClassSignals.(label);
      classData.classSampleCounts.(label) = loadedClassData.classSampleCounts.(label);
      classData.featuresByClass.(label) = loadedClassData.featuresByClass.(label);

      fprintf('Loaded `Label`.\n', classNumber);
    else
      % initializeData(handles);
      % set(handles.edit_label, 'String', classNumber);
      % set(handles.text_seconds_display, 'String', '0.0');
      classData.continuousClassSignals.(label) = {};
      classData.classSampleCounts.(label) = 0;
      classData.featuresByClass.(label) = [];
      fprintf('New `Label` reset.\n', classNumber);
    end

  end
  setappdata(0, 'classData', classData);
  disp('classData initialized:');
  disp(classData);
  % modelData.label = eventdata.NewData;

  % catch Exception
  %   disp('Possible error with input given.');
  % end

  %modelStats_refresh(handles.modelStats);
  displaySeconds = sprintf('%2.2f', (classData.classSampleCounts.(label) / audio_info.SampleRate));
  set(handles.text_seconds_display, 'String', displaySeconds);


  % if classData.classSampleCounts.(label) > 0
  %   audioData = [];
  %   for i = 1:length(classData.continuousClassSignals.(label))
  %     audioData = [audioData; classData.continuousClassSignals.(label){i}];
  %   end
  %   conf.audioFile = '';
  %   setappdata(0, 'conf', conf);
  %   setappdata(0, 'audioData', audioData);
  % else
  %   conf.audioFile = '';
  %   setappdata(0, 'conf', conf);
  %   setappdata(0, 'audioData', [0;0]);

  % end

  % initializePlayback(handles);
  % disp(eventdata);

% --- Executes during object creation, after setting all properties.
function edit_label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_load_gnd_Callback(hObject, eventdata, handles)
  disp(sprintf('\npushbutton_load_gnd_Callback()'));
  playbackOptions = getappdata(0, 'playbackOptions');
  [filename, pathname] = uigetfile('*.mat', 'select a gnd truth file (.MAT file)');
  %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';
  fullpath = [pathname, filename];
  disp('fullpath:');
  disp(fullpath);

  if ~isempty(find(fullpath==0))
    return
  end
  gnd = load(fullpath);
  colors = defaultPalette();
  playbackOptions.signalClassified = gnd.g;
  playbackOptions.colors = colors.classifiedDefault;
  setappdata(0, 'playbackOptions', playbackOptions);
  setappdata(0, 'signalClassified', gnd.g);
  refreshPlaybackAxes();


% --- Executes on button press in pushbutton_inspect_class.
function pushbutton_inspect_class_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_inspect_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  disp(sprintf('\npushbutton_inspect_class_Callback()'));
  playbackOptions = getappdata(0, 'playbackOptions');
  classData = getappdata(0, 'classData');
  audio_info = getappdata(0, 'audio_info');
  audio_data = getappdata(0, 'audio_data');
  conf = getappdata(0, 'conf');

  classNumber = classData.classFocus;
  label = sprintf(conf.classLabelStr, classNumber);

  % set audio as class audio
  class_audio = [];
  segments = classData.continuousClassSignals.(label);
  for l = 1:length(segments)
    thisSegment = segments{l};
    class_audio = [class_audio; thisSegment];
  end

  % if isempty(playbackOptions)
  %   initializePlayback(handles);
  % end

  % nullify ground truth
  playbackOptions.signalClassified = [];
  conf.audioFile = '';
  setappdata(0, 'conf', conf);
  setappdata(0, 'signalClassified', []);
  setappdata(0, 'audio_info', defaultAudioInfo());
  setappdata(0, 'audio_data', []);
  setappdata(0, 'audio_aux', class_audio);
  initializePlayback(handles);




