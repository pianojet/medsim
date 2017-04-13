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

% Last Modified by GUIDE v2.5 11-Apr-2017 21:04:26

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
  disp('Loading config...')
  appConfig = loadConfig('/Users/justin/Documents/MATLAB/medsim/config/app_config.ini');
  disp(appConfig);
  conf = resetConfig(appConfig);
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


% --- Executes on button press in btnLoadDataPath.
% function btnLoadDataPath_Callback(hObject, eventdata, handles)
%   % hObject    handle to btnLoadDataPath (see GCBO)
%   % eventdata  reserved - to be defined in a future version of MATLAB
%   % handles    structure with handles and user data (see GUIDATA)

%   dataPath = uigetdir('.', 'select an `ini` file');
%   %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';

%   disp('dataPath:');
%   disp(dataPath);

%   set(handles.dataPath, 'String', ['DATA PATH:  ',dataPath]);
%   confPath =
%   conf = resetConfig(dataPath);

%   initializePlayback(conf, handles);



function initializeData(handles)
  conf = getappdata(0, 'conf');

  % track model data
  modelData.name = '';
  modelData.bins = 30;
  modelData.features = 'melfcc';
  modelData.audioClips = {};
  modelData.audioFeatures = {}; % keeping association with clips in case we want to impl removal
  modelData.centers = containers.Map;
  modelData.centers('30') = [];
  modelData.seconds = 0.0;
  modelData.limits = {};
  setappdata(0, 'modelData', modelData);


function initializePlayback(handles)
  conf = getappdata(0, 'conf');
  if ~isfield(conf, 'audioFile')
    conf.audioFile = get(handles.dataPath, 'String');
  end

  % audio data & info
  audio_info = audioinfo(conf.audioFile);
  audio_data = audioread(conf.audioFile);
  % gnd_data_g = load(conf.truthFile);
  % gnd_data = gnd_data_g.g;
  setappdata(0, 'audio_data', audio_data);
  % setappdata(0, 'gnd_data', gnd_data);
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
  playbackOptions.title = 'Audio';
  setappdata(0, 'playbackOptions', playbackOptions);

  % gndOptions = playbackOptions;
  % gndOptions.figure = handles.gndFigure;
  % gndOptions.title = 'Classified';
  % setappdata(0, 'gndOptions', gndOptions);

  set(handles.signalFigure, 'buttondownfcn', @signalFigure_buttondownfcn);
  setappdata(0, 'clickpos1', 1);
  setappdata(0, 'clickpos2', ceil(audio_info.TotalSamples/conf.playbackDSFactor));

  % setappdata(0, 'signalClassified', gnd_data);  % may represent small segment of signal
  % setappdata(0, 'fullClassified', gnd_data);    % represents entire classified signal


  % refresh list of classes
  % classes = unique(gnd_data);
  % continuousClassSignals.(classLabels{currentClass}){} = segments of signals
  % classData.continuousClassSignals = struct;
  % classData.classSampleCounts = struct;
  % classData.limits = struct;
  % classData.featuresByClass = {};
  % classData.classesAssigned = []; % list of classes that have been populated (should be unique set)
  % classData.colors = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.0 0.9 0.9; 0.9 0.0 0.9; 0.0 0.0 0.0];
  % classData.classLabels = {};
  % classData.undo = []; % list of previously touched classes (so that we can remove "previous" set)
  % classData.truth = gnd_data;

  % list = {'Class...'};
  % for c = 1:length(classes)
  %   list{(length(list)+1)} = classes(c);
  %   label = getClassLabel(c);

  %   classData.featuresByClass{c} = [];
  %   classData.classLabels{c} = label;

  %   classData.continuousClassSignals.(label) = {};
  %   classData.classSampleCounts.(label) = 0;
  %   classData.limits.(label) = {};

  % end
  % set(handles.classlist, 'String', list);
  % setappdata(0, 'classData', classData);

  % feature list, init available list
  % available = conf.availableFeatures;
  % set(handles.feature_listbox, 'String', available);

  % feature list, init selected list
  % selected = conf.selectedFeatures;
  % if ~iscell(selected)
  %   selected = {selected};
  % end
  % values = [];
  % for i = 1:length(selected)
  %   v = find(strcmp(available,selected{i}));
  %   values = [values v];
  % end
  % set(handles.feature_listbox, 'Value', values);

  % train_seconds_table_CreateFcn(handles.train_seconds_table);

  % init playback gui
  refreshPlaybackAxes();





function refreshPlaybackAxes()
  % options
  playbackOptions = getappdata(0, 'playbackOptions');
  % gndOptions = getappdata(0, 'gndOptions');
  modelData = getappdata(0, 'modelData');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  audio_info = getappdata(0, 'audio_info');

  % audio data
  [audio_data limits] = getSignalClip(getappdata(0, 'audio_data'));
  % [playbackOptions.signalClassified limits] = getSignalClip(getappdata(0, 'gnd_data'), playbackOptions.downSampleFactor);
  playbackOptions.samplelimits = limits;
  % gndOptions.samplelimits = limits;
  setappdata(0, 'playbackOptions', playbackOptions);
  % setappdata(0, 'gndOptions', gndOptions);

  % % display audio
  % signalClassified = getappdata(0, 'signalClassified');
  % fullClassified = getappdata(0, 'fullClassified');

  % % if full signal, ensure it's same size as audio_data above
  % % keeping the top "playback" area as gnd, and the current gnd as classifier display
  % if length(fullClassified) > 0
  %   gndOptions.signalClassified = getSignalClip(fullClassified, gndOptions.downSampleFactor);
  % else
  %   gndOptions.signalClassified = signalClassified;
  % end

  % % if full signal, ensure it's same size as audio_data above
  % if (clickpos1 <= playbackOptions.downSampleFactor) && clickpos2 >= floor(audio_info.TotalSamples/playbackOptions.downSampleFactor)
  %   playbackOptions.signalClassified = getSignalClip(signalClassified, playbackOptions.downSampleFactor);
  % else
  %   playbackOptions.signalClassified = signalClassified;
  % end

  refreshaxes(audio_data, audio_info, playbackOptions);
  % refreshaxes(audio_data, audio_info, gndOptions);

  % new player
  newPlayer(audio_data, audio_info, playbackOptions);

  plotTrainSegments(modelData, playbackOptions);


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


function [clickpos1Up clickpos2Up] = upScaledClickpos(signal)
  % `signal` can be undefined

  playbackOptions = getappdata(0, 'playbackOptions');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');

  if clickpos1 <= playbackOptions.downSampleFactor
    clickpos1Up = 1;
  else
    clickpos1Up = ((clickpos1 * playbackOptions.downSampleFactor) - playbackOptions.downSampleFactor) + 1;
  end

  if ((exist('signal','var') && ~isempty(signal)) && clickpos2 * playbackOptions.downSampleFactor > (length(signal) - playbackOptions.downSampleFactor))
    clickpos2Up = length(signal);
  else
    clickpos2Up = clickpos2 * playbackOptions.downSampleFactor;
  end


function [signal_clip limits] = getSignalClip(signal)
  % selected area
  [clickpos1Up clickpos2Up] = upScaledClickpos(signal);
  signal_clip = signal( clickpos1Up:clickpos2Up , :);
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


  % % view changes, deprecates this signalClassified
  % fullClassified = getappdata(0, 'fullClassified');
  % if length(fullClassified) > 0
  %   clickpos1 = getappdata(0, 'clickpos1');
  %   clickpos2 = getappdata(0, 'clickpos2');
  %   if clickpos2*playbackOptions.downSampleFactor > length(fullClassified)
  %     clickpos2 = floor(length(fullClassified) / playbackOptions.downSampleFactor);
  %     setappdata(0, 'clickpos2', clickpos2);
  %   end
  %   % setappdata(0, 'signalClassified', fullClassified(clickpos1*playbackOptions.downSampleFactor:clickpos2*playbackOptions.downSampleFactor));
  %   setappdata(0, 'signalClassified', getSignalClip(fullClassified));
  % else
  %   setappdata(0, 'signalClassified', []);
  % end

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



function conf = resetConfig(appConfig)
  % conf = getappdata(0, 'appConf');
  dataConf = loadConfig([appConfig.rootPath, '/', appConfig.dataConfigFile]);
  pathConf = loadConfig([appConfig.rootPath, '/', appConfig.dataPathFile]);

  % add paths to dataConf: prepend `rootPath` (which is absolute) to paths as defined in config
  fields = fieldnames(pathConf);
  for i = 1:numel(fields)
    dataConf.(fields{i}) = [appConfig.rootPath, '/', pathConf.(fields{i})];
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




% --- Executes on button press in pushbutton_new.
function pushbutton_new_Callback(hObject, eventdata, handles)
  % hObject    handle to pushbutton_new (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  [filename, pathname] = uigetfile('*.wav', 'select an WAV file');
  %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';

  disp('[filename, pathname]:');
  disp([filename, pathname]);

  set(handles.dataPath, 'String', [pathname, filename]);
  % % conf = resetConfig();
  % conf.audioFile = [pathname, filename];

  initializeData(handles);
  initializePlayback(handles);


% --- Executes when entered data in editable cell(s) in modelStats.
function modelStats_CellEditCallback(hObject, eventdata, handles)
  % hObject    handle to modelStats (see GCBO)
  % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
  %	Indices: row and column indices of the cell(s) edited
  %	PreviousData: previous data for the cell(s) edited
  %	EditData: string(s) entered by the user
  %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
  %	Error: error string when failed to convert EditData to appropriate value for Data
  % handles    structure with handles and user data (see GUIDATA)

  modelData = getappdata(0, 'modelData');
  row = eventdata.Indices(1)

  try
    switch row
      case 1
        fprintf('`Name` changed to %s', eventdata.NewData);
        modelData.name = eventdata.NewData;
      case 2
        fprintf('`Bins` changed to %s', eventdata.NewData);
        modelData.bins = str2num(eventdata.NewData);
      case 3
        fprintf('Changing `Feature` is current unsupported.');
        modelData.feature = 'melfcc';
    end

  catch Exception
    disp('Possible error with input given.');
  end

  disp(eventdata);


function modelStats_refresh(modelStats)
  % colNames = {'Time'};
  % rowNames = {};
  % tableData = [];
  % for c = 1:length(classData.classLabels)
  %   label = getClassLabel(c);
  %   rowNames{c} = c;
  %   theseTotalSamples = sum(classData.classSampleCounts.(label));
  %   % secondsString = sprintf('%2.2f', theseTotalSamples/audio_info.SampleRate);
  %   % tableData{c} = secondsString;
  %   tableData = [tableData; theseTotalSamples/audio_info.SampleRate];
  % end
  % set(hObject, 'ColumnWidth', 'auto');
  % set(hObject, 'ColumnName', colNames);
  % set(hObject, 'RowName', rowNames);
  % set(hObject, 'Data', tableData);

  modelData = getappdata(0, 'modelData');
  displaySeconds = sprintf('%2.2f', modelData.seconds);
  data = {modelData.name; '30'; 'melfcc'; displaySeconds};
  set(modelStats, 'Data', data);



% --- Executes during object creation, after setting all properties.
function modelStats_CreateFcn(hObject, eventdata, handles)
  % hObject    handle to modelStats (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
  % hObject    handle to pushbutton_add (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  disp('pushbutton_add_Callback');

  conf = getappdata(0, 'conf');
  playbackOptions = getappdata(0, 'playbackOptions');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  modelData = getappdata(0, 'modelData');
  audio_data = getappdata(0, 'audio_data');
  audio_info = getappdata(0, 'audio_info')
  sampleRate = audio_info.SampleRate;

  disp('initial modelData:');
  disp(modelData);


  if ~((clickpos1 > 1) && (clickpos2 < (length(audio_data) / playbackOptions.downSampleFactor)))
    disp('useless parameters, returning...');
    return
  end

  % label = getClassLabel(c);
  % thisSetSize = length(classData.continuousClassSignals.(label));
  % thisSegment = getSignalClipNoSilence();

  % % push signal to cell array
  % classData.continuousClassSignals.(label){thisSetSize+1} = thisSegment;
  % classData.classSampleCounts.(label) = classData.classSampleCounts.(label) + length(thisSegment);
  % classData.classesAssigned = unique([classData.classesAssigned c]);

  % % check in bounds
  % if clickpos1 < 1
  %   clickpos1 = 1;
  % end
  % if clickpos2 * playbackOptions.downSampleFactor > length(audio_data)
  %   clickpos2 = floor(length(audio_data) / playbackOptions.downSampleFactor);
  % end
  % clickpos1Up = clickpos1 * playbackOptions.downSampleFactor;
  % clickpos2Up = clickpos2 * playbackOptions.downSampleFactor;

  clip = getSignalClip(audio_data);
  modelData.audioClips{length(modelData.audioClips)+1} = clip;
  modelData.limits{length(modelData.limits)+1} = [clickpos1 clickpos2];
  modelData.seconds = modelData.seconds + (length(clip) / sampleRate);


  disp('saving modelData:');
  disp(modelData);

  setappdata(0, 'modelData', modelData);

  disp(sprintf('added signal to class'));
  modelStats_refresh(handles.modelStats);
  plotTrainSegments(modelData, playbackOptions);


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
  % hObject    handle to pushbutton_save (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  modelData = getappdata(0, 'modelData');
  conf = getappdata(0, 'conf');








