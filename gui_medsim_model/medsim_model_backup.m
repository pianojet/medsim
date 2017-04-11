function varargout = medsim_model(varargin)
% MEDSIM_TRAIN MATLAB code for medsim_model.fig
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
%      applied to the GUI before medsim_model_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to medsim_model_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help medsim_model

% Last Modified by GUIDE v2.5 24-Feb-2017 12:01:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @medsim_model_OpeningFcn, ...
                   'gui_OutputFcn',  @medsim_model_OutputFcn, ...
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


% --- Executes just before medsim_model is made visible.
function medsim_model_OpeningFcn(hObject, eventdata, handles, varargin)
  % This function has no output args, see OutputFcn.
  % hObject    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % varargin   command line arguments to medsim_model (see VARARGIN)

  % Choose default command line output for medsim_model
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);
  disp('Loading config...')
  appConf = loadConfig('/Users/justin/Documents/MATLAB/medsim/config/app_config.ini');
  setappdata(0, 'appConf', appConf);
  disp(appConf);
  % UIWAIT makes medsim_model wait for user response (see UIRESUME)
  % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = medsim_model_OutputFcn(hObject, eventdata, handles)
  % varargout  cell array for returning output args (see VARARGOUT);
  % hObject    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)

  % Get default command line output from handles structure
  varargout{1} = handles.output;


% --- Executes on button press in btnLoadDataPath.
function btnLoadDataPath_Callback(hObject, eventdata, handles)
  % hObject    handle to btnLoadDataPath (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)

  dataPath = uigetdir('.', 'select an `ini` file');
  %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';

  disp('dataPath:');
  disp(dataPath);

  set(handles.dataPath, 'String', ['DATA PATH:  ',dataPath]);
  conf = resetConfig(dataPath);

  initializeEnvironment(conf, handles);



function initializeEnvironment(conf, handles)
  % audio data & info
  audio_info = audioinfo(conf.audioFile);
  audio_data = audioread(conf.audioFile);
  gnd_data_g = load(conf.truthFile);
  gnd_data = gnd_data_g.g;
  setappdata(0, 'audio_data', audio_data);
  setappdata(0, 'gnd_data', gnd_data);
  setappdata(0, 'audio_info', audio_info);

  disp('Audio Info:');
  disp(audio_info);

  % init playback options
  set(handles.axesTimeStart, 'String', '0');
  set(handles.axesTimeEnd, 'String', audio_info.Duration);
  set(handles.playHeadLoc, 'String', '0');
  playbackOptions.start = str2num(get(handles.axesTimeStart, 'String'));
  playbackOptions.end = str2num(get(handles.axesTimeEnd, 'String'));
  playbackOptions.playHeadLoc = str2num(get(handles.playHeadLoc, 'String'));
  playbackOptions.downSampleFactor = conf.playbackDSFactor;
  playbackOptions.figure = handles.signalFigure;
  playbackOptions.sample_rate = audio_info.SampleRate;
  playbackOptions.samplelimits = [1 audio_info.TotalSamples];
  playbackOptions.title = 'Ground Truth';
  setappdata(0, 'playbackOptions', playbackOptions);

  gndOptions = playbackOptions;
  gndOptions.figure = handles.gndFigure;
  gndOptions.title = 'Classified';
  setappdata(0, 'gndOptions', gndOptions);

  set(handles.signalFigure, 'buttondownfcn', @signalFigure_buttondownfcn);
  setappdata(0, 'clickpos1', 1);
  setappdata(0, 'clickpos2', floor(audio_info.TotalSamples/conf.playbackDSFactor));

  setappdata(0, 'signalClassified', gnd_data);  % may represent small segment of signal
  setappdata(0, 'fullClassified', gnd_data);    % represents entire classified signal

  % refresh list of classes
  classes = unique(gnd_data);
  % continuousClassSignals.(classLabels{currentClass}){} = segments of signals
  classData.continuousClassSignals = struct;
  classData.classSampleCounts = struct;
  classData.limits = struct;
  classData.featuresByClass = {};
  classData.classesAssigned = []; % list of classes that have been populated (should be unique set)
  classData.colors = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.0 0.9 0.9; 0.9 0.0 0.9; 0.0 0.0 0.0];
  classData.classLabels = {};
  classData.undo = []; % list of previously touched classes (so that we can remove "previous" set)
  classData.truth = gnd_data;

  list = {'Class...'};
  for c = 1:length(classes)
    list{(length(list)+1)} = classes(c);
    label = getClassLabel(c);

    classData.featuresByClass{c} = [];
    classData.classLabels{c} = label;

    classData.continuousClassSignals.(label) = {};
    classData.classSampleCounts.(label) = 0;
    classData.limits.(label) = {};

  end
  set(handles.classlist, 'String', list);
  setappdata(0, 'classData', classData);

  % feature list, init available list
  available = conf.availableFeatures;
  set(handles.feature_listbox, 'String', available);

  % feature list, init selected list
  selected = conf.selectedFeatures;
  if ~iscell(selected)
    selected = {selected};
  end
  values = [];
  for i = 1:length(selected)
    v = find(strcmp(available,selected{i}));
    values = [values v];
  end
  set(handles.feature_listbox, 'Value', values);

  train_seconds_table_CreateFcn(handles.train_seconds_table);

  % init playback gui
  refreshPlaybackAxes();












% --- Executes on button press in assignbutton.
function assignbutton_Callback(hObject, eventdata, handles)
  % hObject    handle to assignbutton (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  disp('assignbutton');

  conf = getappdata(0, 'conf');
  playbackOptions = getappdata(0, 'playbackOptions');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  classData = getappdata(0, 'classData');
  audio_data = getappdata(0, 'audio_data');
  contents = cellstr(get(handles.classlist,'String'));
  c = str2num(contents{get(handles.classlist,'Value')});

  if ~((clickpos1 > 1) && (clickpos2 < (length(audio_data) / playbackOptions.downSampleFactor)) && (length(contents) > 1) && (get(handles.classlist,'Value') > 1))
    disp('useless parameters, returning...');
    return
  end

  label = getClassLabel(c);
  thisSetSize = length(classData.continuousClassSignals.(label));
  thisSegment = getSignalClipNoSilence();

  % push signal to cell array
  classData.continuousClassSignals.(label){thisSetSize+1} = thisSegment;
  classData.classSampleCounts.(label) = classData.classSampleCounts.(label) + length(thisSegment);
  classData.classesAssigned = unique([classData.classesAssigned c]);

  % check in bounds
  if clickpos1 < 1
    clickpos1 = 1;
  end
  if clickpos2 * playbackOptions.downSampleFactor > length(audio_data)
    clickpos2 = floor(length(audio_data) / playbackOptions.downSampleFactor);
  end
  % clickpos1Up = clickpos1 * playbackOptions.downSampleFactor;
  % clickpos2Up = clickpos2 * playbackOptions.downSampleFactor;

  classData.limits.(label){thisSetSize+1} = [clickpos1 clickpos2];
  classData.undo = [c];

  save(conf.classDataFile, '-struct', 'classData');
  % save(conf.extractedForTestFile, '-struct', 'classData.continuousClassSignals');
  % save(conf.metaFile, '-struct', 'classData.classSampleCounts');
  setappdata(0, 'classData', classData);

  disp(sprintf('added signal to class %s', label));
  plotTrainSegments(classData, playbackOptions);
  train_seconds_table_CreateFcn(handles.train_seconds_table);



function refreshPlaybackAxes()
  % options
  playbackOptions = getappdata(0, 'playbackOptions');
  gndOptions = getappdata(0, 'gndOptions');
  classData = getappdata(0, 'classData');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  audio_info = getappdata(0, 'audio_info');

  % audio data
  [audio_data limits] = getSignalClip(getappdata(0, 'audio_data'), playbackOptions.downSampleFactor);
  [playbackOptions.signalClassified limits] = getSignalClip(getappdata(0, 'gnd_data'), playbackOptions.downSampleFactor);
  playbackOptions.samplelimits = limits;
  gndOptions.samplelimits = limits;
  setappdata(0, 'playbackOptions', playbackOptions);
  setappdata(0, 'gndOptions', gndOptions);

  % display audio
  signalClassified = getappdata(0, 'signalClassified');
  fullClassified = getappdata(0, 'fullClassified');

  % if full signal, ensure it's same size as audio_data above
  % keeping the top "playback" area as gnd, and the current gnd as classifier display
  if length(fullClassified) > 0
    gndOptions.signalClassified = getSignalClip(fullClassified, gndOptions.downSampleFactor);
  else
    gndOptions.signalClassified = signalClassified;
  end

  % % if full signal, ensure it's same size as audio_data above
  % if (clickpos1 <= playbackOptions.downSampleFactor) && clickpos2 >= floor(audio_info.TotalSamples/playbackOptions.downSampleFactor)
  %   playbackOptions.signalClassified = getSignalClip(signalClassified, playbackOptions.downSampleFactor);
  % else
  %   playbackOptions.signalClassified = signalClassified;
  % end

  refreshaxes(audio_data, audio_info, playbackOptions);
  refreshaxes(audio_data, audio_info, gndOptions);

  % new player
  newPlayer(audio_data, audio_info, playbackOptions);

  plotTrainSegments(classData, playbackOptions);


function src = stopCallback(src, eventdata)
  % reset playhead
  myStruct = get(src, 'UserData');
  myStruct.playHeadLoc = 1;
  set(myStruct.ax, 'Xdata', [0 0]);
  set(src, 'UserData', myStruct);


function newPlayer(audio_data, audio_info, playbackOptions)
  % requires pre-scaled, pre-snipped audio data (which is why these are params, and not getappdata)
  playbackOptions.playHeadLoc = 1;
  setappdata(0, 'playbackOptions', playbackOptions);
  player = refreshplayback(audio_data, audio_info, playbackOptions);
  set(player, 'StopFcn', @stopCallback);
  setappdata(0, 'player_handle', player);



function [signal_clip limits] = getSignalClip(signal, sampleScale)
  % selected area
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');

  if clickpos1 <= sampleScale
    clickpos1Up = 1;
  else
    clickpos1Up = clickpos1 * sampleScale;
  end

  if clickpos2 * sampleScale > (length(signal) - sampleScale)
    clickpos2Up = length(signal);
  else
    clickpos2Up = clickpos2 * sampleScale;
  end

  signal_clip = signal( clickpos1Up:clickpos2Up , :);
  limits = [clickpos1Up clickpos2Up];


function [signal_clip limits] = getSignalClipNoSilence()
  gnd_data = getappdata(0, 'gnd_data');
  audio_data = getappdata(0, 'audio_data');
  playbackOptions = getappdata(0, 'playbackOptions');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');

  % if clickpos1 < 1
  %   clickpos1 = 1;
  % end

  % if clickpos2 * playbackOptions.downSampleFactor > length(audio_data)
  %   clickpos2 = floor(length(audio_data) / playbackOptions.downSampleFactor);
  % end

  if clickpos1 < 1
    clickpos1Up = 1;
  else
    clickpos1Up = clickpos1 * playbackOptions.downSampleFactor;
  end

  if clickpos2 * playbackOptions.downSampleFactor > (length(audio_data) - playbackOptions.downSampleFactor)
    clickpos2Up = length(audio_data);
  else
    clickpos2Up = clickpos2 * playbackOptions.downSampleFactor;
  end

  gnd_clip = gnd_data( clickpos1Up:clickpos2Up , :);
  signal_clip = audio_data( clickpos1Up:clickpos2Up , :);
  signal_clip = signal_clip(gnd_clip(:) ~= 5);
  limits = [clickpos1Up clickpos2Up];


function signalFigure_buttondownfcn(ax, hit)
  audio_info = getappdata(0, 'audio_info');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  playbackOptions = getappdata(0, 'playbackOptions');

  ax; % figure axes1

  setappdata(0, 'signalClassified', []);


  % playbackOptions.figure;
  % hitDownSampled = round(hit.IntersectionPoint(1))/playbackOptions.downSampleFactor;

  fprintf('pre click positions:\n');
  fprintf('clickpos1:\n');
  disp(getappdata(0, 'clickpos1'));
  fprintf('clickpos2:\n');
  disp(getappdata(0, 'clickpos2'));

  hold on;
  if clickpos1 == 1 || round(hit.IntersectionPoint(1)) < clickpos1
    if round(hit.IntersectionPoint(1)) < clickpos1
      plot([clickpos1 clickpos1], [-1 1], 'w', 'LineWidth', 2);
    end
    clickpos1 = round(hit.IntersectionPoint(1));
    playbackOptions.playHeadLoc = clickpos1;
    plot([clickpos1 clickpos1], [-1 1], 'k', 'LineWidth', 2);
  elseif clickpos2 < floor(audio_info.TotalSamples/playbackOptions.downSampleFactor)
    plot([clickpos1 clickpos1], [-1 1], 'w', 'LineWidth', 2);
    plot([clickpos2 clickpos2], [-1 1], 'w', 'LineWidth', 2);
    clickpos1 = round(hit.IntersectionPoint(1));
    playbackOptions.playHeadLoc = clickpos1;
    clickpos2 = floor(audio_info.TotalSamples/playbackOptions.downSampleFactor);
    plot([clickpos1 clickpos1], [-1 1], 'k', 'LineWidth', 2);
  else
    clickpos2 = round(hit.IntersectionPoint(1));
    plot([clickpos2 clickpos2], [-1 1], 'k', 'LineWidth', 2);
  end
  hold off;
  setappdata(0, 'clickpos1', clickpos1);
  setappdata(0, 'clickpos2', clickpos2);
  setappdata(0, 'playbackOptions', playbackOptions);

  fprintf('set click positions:\n');
  fprintf('clickpos1:\n');
  disp(getappdata(0, 'clickpos1'));
  fprintf('clickpos2:\n');
  disp(getappdata(0, 'clickpos2'));



function refreshAxes_Callback(hObject, eventdata, handles)
  % --- Executes on button press in refreshAxes.
  audio_info = getappdata(0, 'audio_info');
  playbackOptions = getappdata(0, 'playbackOptions');

  % refresh playbackOptions ?????? remove ???????
  playbackOptions.start = str2num(get(handles.axesTimeStart, 'String')) * audio_info.SampleRate;
  playbackOptions.end = str2num(get(handles.axesTimeEnd, 'String')) * audio_info.SampleRate;

  % playbackOptions.playHeadLoc = str2num(get(handles.axesTimeStart, 'String')) * audio_info.SampleRate;
  playbackOptions.playHeadLoc = 1;
  setappdata(0, 'playbackOptions', playbackOptions);
  setappdata(0, 'clickpos1', 1);
  setappdata(0, 'clickpos2', floor(audio_info.TotalSamples/playbackOptions.downSampleFactor));


  % view changes, deprecates this signalClassified
  fullClassified = getappdata(0, 'fullClassified');
  if length(fullClassified) > 0
    clickpos1 = getappdata(0, 'clickpos1');
    clickpos2 = getappdata(0, 'clickpos2');
    if clickpos2*playbackOptions.downSampleFactor > length(fullClassified)
      clickpos2 = floor(length(fullClassified) / playbackOptions.downSampleFactor);
      setappdata(0, 'clickpos2', clickpos2);
    end
    % setappdata(0, 'signalClassified', fullClassified(clickpos1*playbackOptions.downSampleFactor:clickpos2*playbackOptions.downSampleFactor));
    setappdata(0, 'signalClassified', getSignalClip(fullClassified, playbackOptions.downSampleFactor));
  else
    setappdata(0, 'signalClassified', []);
  end

  % refresh axes
  refreshPlaybackAxes();
  % refreshGndAxes(handles.axes6);


function playbutton_Callback(hObject, eventdata, handles)
  % begin playback
  playbackOptions = getappdata(0, 'playbackOptions');
  player = getappdata(0, 'player_handle');
  audio_info = getappdata(0, 'audio_info');
  % t = get(handles.axesTimeStart, 'String')

  % timeStart = str2num(t);
  % sampleStart = timeStart * audio_info.SampleRate;
  % vprint(sprintf('Starting at time %f (sample %f)', timeStart, sampleStart));

  sampleStart = playbackOptions.playHeadLoc*playbackOptions.downSampleFactor;

  myStruct = get(player, 'UserData');
  myStruct.playHeadLoc = playbackOptions.playHeadLoc;
  set(player, 'UserData', myStruct);

  disp('playing...');
  play(player, sampleStart);


function stopbutton_Callback(hObject, eventdata, handles)
  % stop playback
  player = getappdata(0, 'player_handle');
  stop(player);
  myStruct = get(player, 'UserData');
  % myStruct.playHeadLoc = get(handles.playHeadLoc, 'String');
  myStruct.playHeadLoc = 1;
  set(myStruct.ax, 'Xdata', [0 0]);
  set(player, 'UserData', myStruct);


function pausebutton_Callback(hObject, eventdata, handles)
  % pause / resume playback
  action = get(hObject, 'String');
  player = getappdata(0, 'player_handle');
  if strcmp(action, 'Pause')
    pause(player);
    set(hObject, 'String', 'Resume');
  else
    resume(player);
    set(hObject, 'String', 'Pause');
  end



%
% helpers
%



function conf = resetConfig(dataPath)
  conf = getappdata(0, 'appConf');
  dataConf = loadConfig([dataPath, '/', conf.dataConfigFile]);
  pathConf = loadConfig([dataPath, '/', conf.dataPathFile]);

  disp('path of pathConf:');
  disp([dataPath, '/', conf.dataPathFile]);
  disp('pathConf:');
  disp(pathConf);


  % add paths to dataConf: prepend `dataPath` (which is absolute) to paths as defined in config
  fields = fieldnames(pathConf);
  for i = 1:numel(fields)
    dataConf.(fields{i}) = [dataPath, '/', pathConf.(fields{i})];
  end

  % now add all dataConf fields to a central `conf` struct
  fields = fieldnames(dataConf);
  for i = 1:numel(fields)
    conf.(fields{i}) = dataConf.(fields{i});
  end

  % ensure fields that can be lists are consistently cells even with one item
  if isstr(conf.selectedFeatures)
    conf.selectedFeatures = {conf.selectedFeatures};
  end

  setappdata(0, 'conf', conf);





function label = getClassLabel(classNum)
  conf = getappdata(0, 'conf');
  label = sprintf(conf.classLabelStr, classNum);











function axesTimeStart_Callback(hObject, eventdata, handles)
% hObject    handle to axesTimeStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axesTimeStart as text
%        str2double(get(hObject,'String')) returns contents of axesTimeStart as a double


% --- Executes during object creation, after setting all properties.
function axesTimeStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesTimeStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axesTimeEnd_Callback(hObject, eventdata, handles)
% hObject    handle to axesTimeEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axesTimeEnd as text
%        str2double(get(hObject,'String')) returns contents of axesTimeEnd as a double


% --- Executes during object creation, after setting all properties.
function axesTimeEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesTimeEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function playHeadLoc_Callback(hObject, eventdata, handles)
% hObject    handle to playHeadLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playHeadLoc as text
%        str2double(get(hObject,'String')) returns contents of playHeadLoc as a double


% --- Executes during object creation, after setting all properties.
function playHeadLoc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playHeadLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% % --- Executes on button press in playbutton.
% function playbutton_Callback(hObject, eventdata, handles)
% % hObject    handle to playbutton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% % --- Executes on button press in pausebutton.
% function pausebutton_Callback(hObject, eventdata, handles)
% % hObject    handle to pausebutton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% % --- Executes on button press in stopbutton.
% function stopbutton_Callback(hObject, eventdata, handles)
% % hObject    handle to stopbutton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoombutton.
function zoombutton_Callback(hObject, eventdata, handles)
  % hObject    handle to zoombutton (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % playbackOptions = getappdata(0, 'playbackOptions');
  % playbackOptions.
  % gndOptions = getappdata(0, 'gndOptions');
  refreshPlaybackAxes();








% --- Executes on selection change in classlist.
function classlist_Callback(hObject, eventdata, handles)
% hObject    handle to classlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns classlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from classlist


% --- Executes during object creation, after setting all properties.
function classlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to classlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in feature_listbox.
function feature_listbox_Callback(hObject, eventdata, handles)
  % hObject    handle to feature_listbox (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)

  % Hints: contents = cellstr(get(hObject,'String')) returns feature_listbox contents as cell array
  %        contents{get(hObject,'Value')} returns selected item from feature_listbox
  conf = getappdata(0, 'conf');
  contents = cellstr(get(hObject,'String'));
  values = get(hObject,'Value');
  conf.selectedFeatures = contents(values);
  disp('feature list:');
  disp(conf.selectedFeatures);
  setappdata(0, 'feature_list', conf.selectedFeatures');
  setappdata(0, 'conf', conf);


% --- Executes during object creation, after setting all properties.
function feature_listbox_CreateFcn(hObject, eventdata, handles)
  % hObject    handle to feature_listbox (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    empty - handles not created until after all CreateFcns called

  % Hint: listbox controls usually have a white background on Windows.
  %       See ISPC and COMPUTER.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end

  set(hObject,'Max', 4, 'Min', 1);
  % ZCR: zero-crossing
  % STE: short-time-enerty
  options = {'Features...'};
  set(hObject,'String',options);


% --- Executes on button press in analyze_pushbutton.
function analyze_pushbutton_Callback(hObject, eventdata, handles)
  % hObject    handle to analyze_pushbutton (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  conf = getappdata(0, 'conf');
  conf.removeCount = str2num(get(handles.filterbin_edit, 'String'));
  conf.filterBins  = str2num(get(handles.filterbinattempts_edit, 'String'));
  setappdata(0, 'conf', conf);

  classData = getappdata(0, 'classData');
  playbackOptions = getappdata(0, 'playbackOptions');
  audio_info = getappdata(0, 'audio_info');
  audio_data = getappdata(0, 'audio_data');
  gnd_data = getappdata(0, 'gnd_data');


  disp('Beginning analysis...');
  disp('classData:');
  disp(classData);
  % outputHandle = figure();
  % descr = {
  %   'Analyzing selected training source...';
  %   '... still analysing...';

  % };
  % % text(0, 0, descr);
  % tBox = uicontrol('style','text');

  % set(tBox,'Units','characters');
  % set(tBox,'String',descr);
  % set(tBox,'Position',[0, 0, 80, 10]);

  [finalResults, filterStats] = analyze(conf, classData);
  setappdata(0, 'clickpos1', 1);
  setappdata(0, 'clickpos2', floor(audio_info.TotalSamples/playbackOptions.downSampleFactor));
  setappdata(0, 'fullClassified', finalResults.signalClassified);
  refreshPlaybackAxes();
  saveAnalysis(conf, audio_data, gnd_data, finalResults, filterStats, playbackOptions);

  disp('Completed analysis.');


function train_seconds_table_CreateFcn(hObject, eventdata, handles)
  classData = getappdata(0, 'classData');
  audio_info = getappdata(0, 'audio_info');

  colNames = {'Time'};
  rowNames = {};
  tableData = [];
  for c = 1:length(classData.classLabels)
    label = getClassLabel(c);
    rowNames{c} = c;
    theseTotalSamples = sum(classData.classSampleCounts.(label));
    % secondsString = sprintf('%2.2f', theseTotalSamples/audio_info.SampleRate);
    % tableData{c} = secondsString;
    tableData = [tableData; theseTotalSamples/audio_info.SampleRate];
  end
  set(hObject, 'ColumnWidth', 'auto');
  set(hObject, 'ColumnName', colNames);
  set(hObject, 'RowName', rowNames);
  set(hObject, 'Data', tableData);


% --- Executes on button press in clearclass_pushbutton.
function clearclass_pushbutton_Callback(hObject, eventdata, handles)
  conf = getappdata(0, 'conf');
  playbackOptions = getappdata(0, 'playbackOptions');
  classData = getappdata(0, 'classData');
  audio_data = getappdata(0, 'audio_data');
  audio_info = getappdata(0, 'audio_info');

  classData.continuousClassSignals = struct;
  classData.classSampleCounts = struct;
  classData.limits = struct;
  classData.featuresByClass = {};
  classData.classesAssigned = []; % list of classes that have been populated (should be unique set)

  for c = 1:length(classData.classLabels)
    label = classData.classLabels{c};

    classData.featuresByClass{c} = [];
    classData.continuousClassSignals.(label) = {};
    classData.classSampleCounts.(label) = 0;
    classData.limits.(label) = {};

  end

  setappdata(0, 'clickpos1', 1);
  setappdata(0, 'clickpos2', floor(audio_info.TotalSamples/playbackOptions.downSampleFactor));
  setappdata(0, 'classData', classData);
  save(conf.classDataFile, '-struct', 'classData');

  refreshaxes(audio_data, audio_info, playbackOptions);
  plotTrainSegments(classData, playbackOptions);
  train_seconds_table_CreateFcn(handles.train_seconds_table);



% --- Executes on button press in clearprevious_pushbutton.
function clearprevious_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearprevious_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  disp('clearprevious');

  conf = getappdata(0, 'conf');
  playbackOptions = getappdata(0, 'playbackOptions');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  classData = getappdata(0, 'classData');
  audio_data = getappdata(0, 'audio_data');
  audio_info = getappdata(0, 'audio_info');

  if ~(length(classData.undo) > 0)
    disp('no class data, returning...');
    return
  end

  c = classData.undo(end);
  classData.undo(end) = [];

  label = getClassLabel(c);
  thisSetSize = length(classData.continuousClassSignals.(label));
  thisSegmentLength = length(classData.continuousClassSignals.(label){thisSetSize});

  % remove from cell array
  classData.continuousClassSignals.(label)(thisSetSize) = [];
  classData.classSampleCounts.(label) = classData.classSampleCounts.(label) - thisSegmentLength;
  classData.limits.(label)(thisSetSize) = [];

  setappdata(0, 'clickpos1', 1);
  setappdata(0, 'clickpos2', floor(audio_info.TotalSamples/playbackOptions.downSampleFactor));
  setappdata(0, 'classData', classData);
  save(conf.classDataFile, '-struct', 'classData');
  % save(conf.extractedForTestFile, '-struct', 'classData.continuousClassSignals');
  % save(conf.metaFile, '-struct', 'classData.classSampleCounts');

  disp(sprintf('removed signal from class %s', label));

  refreshaxes(audio_data, audio_info, playbackOptions);
  plotTrainSegments(classData, playbackOptions);
  train_seconds_table_CreateFcn(handles.train_seconds_table);


% --- Executes on button press in loadclassdata_pushbutton.
function loadclassdata_pushbutton_Callback(hObject, eventdata, handles)
  % hObject    handle to loadclassdata_pushbutton (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  conf = getappdata(0, 'conf');
  playbackOptions = getappdata(0, 'playbackOptions');
  audio_info = getappdata(0, 'audio_info');
  if ~(exist(conf.classDataFile, 'file') == 2)
    disp('No class data found.');
    return
  end

  classData = load(conf.classDataFile);
  setappdata(0, 'clickpos1', 1);
  setappdata(0, 'clickpos2', floor(audio_info.TotalSamples/playbackOptions.downSampleFactor));
  setappdata(0, 'classData', classData);
  disp(sprintf('Loaded class data from %s', conf.classDataFile));
  plotTrainSegments(classData, playbackOptions);
  train_seconds_table_CreateFcn(handles.train_seconds_table);

% --- Executes on button press in savenew_pushbutton.
function savenew_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savenew_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cachefeature_pushbutton.
function cachefeature_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cachefeature_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
conf = getappdata(0, 'conf');

cacheFile = getFeatureCacheName(conf);

disp();



function filterbin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filterbin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterbin_edit as text
%        str2double(get(hObject,'String')) returns contents of filterbin_edit as a double


% --- Executes during object creation, after setting all properties.
function filterbin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterbin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filterbinattempts_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filterbinattempts_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterbinattempts_edit as text
%        str2double(get(hObject,'String')) returns contents of filterbinattempts_edit as a double


% --- Executes during object creation, after setting all properties.
function filterbinattempts_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterbinattempts_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
