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
  initializeConfig();
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





% --- Executes on button press in pushbutton_new.
function pushbutton_new_Callback(hObject, eventdata, handles)
  % hObject    handle to pushbutton_new (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  loadAudio(handles);
  initializeData(handles);



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









