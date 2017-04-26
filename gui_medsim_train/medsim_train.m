function varargout = medsim_train(varargin)
% MEDSIM_TRAIN MATLAB code for medsim_train.fig
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
%      applied to the GUI before medsim_train_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to medsim_train_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help medsim_train

% Last Modified by GUIDE v2.5 13-Apr-2017 15:04:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @medsim_train_OpeningFcn, ...
                   'gui_OutputFcn',  @medsim_train_OutputFcn, ...
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


% --- Executes just before medsim_train is made visible.
function medsim_train_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to medsim_train (see VARARGIN)

% Choose default command line output for medsim_train
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
initializeConfig('/Users/justin/Documents/MATLAB/medsim/config/spk_app_config.ini');
initializeData(handles);
setappdata(0, 'usrInit', []);
setappdata(0, 'audio_info', defaultAudioInfo());

% UIWAIT makes medsim_train wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = medsim_train_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function initializeData(handles)
  % conf = getappdata(0, 'conf');

  % track model data
  % classData.name = '';
  % classData.bins = 30;
  % classData.features = {'melfcc'};
  % classData.audioClips = {};
  % classData.audioFeatures = {}; % keeping association with clips in case we want to impl removal
  % classData.centers = containers.Map;
  % classData.centers('30') = [];
  % classData.seconds = 0.0;
  % classData.limits = {};
  classData.classNumberList = [];
  classData.continuousClassSignals = struct;
  classData.classSampleCounts = struct;
  classData.featuresByClass = struct;
  classData.centers = struct;
  setappdata(0, 'classData', classData);
  % = containers.Map;
  % classData.centers('30') = [];

  modelData.mus = [];
  modelData.sigmas = [];
  modelData.modelTable = [];
  modelData.modelLabel = [];
  modelData.selectedFeatures = {};
  setappdata(0, 'modelData', modelData);

  modelStats_refresh(handles);
  listbox_features_refresh(handles);
  edit_bins_refresh(handles);


function edit_bins_refresh(handles)
  conf = getappdata(0, 'conf');
  set(handles.edit_bins, 'String', conf.numClusters);


function listbox_features_refresh(handles)
  conf = getappdata(0, 'conf');
  featureIdx = [];
  for f = 1:length(conf.selectedFeatures)
    idx = find(strcmp(conf.availableFeatures, conf.selectedFeatures{f}));
    featureIdx = [featureIdx idx];
  end
  set(handles.listbox_features, 'String', conf.availableFeatures, 'Max', length(conf.availableFeatures));
  set(handles.listbox_features, 'Value', featureIdx);


function modelStats_refresh(handles)
  modelStats = handles.modelStats;
  conf = getappdata(0, 'conf');
  audio_info = getappdata(0, 'audio_info');
  tableData = [];
  appClassList = [];
  listboxList = {};

  for classNumber = 1:100
    filename = getClassFileName(classNumber);
    if exist(filename) == 2
      classFileData = load(filename);
      label = sprintf(conf.classLabelStr, classNumber);
      displaySeconds = sprintf('%2.2f', (classFileData.classSampleCounts.(label) / audio_info.SampleRate));
      colData = [classNumber {displaySeconds}];
      tableData = [tableData; colData];
      appClassList = [appClassList classNumber];
      listboxList{length(listboxList)+1} = sprintf('Class %d (%ss)', classNumber, displaySeconds);
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

  set(handles.listbox_classlist, 'String', listboxList, 'Max', length(listboxList));



function modelStats_CreateFcn(hObject, eventdata, handles)
  % hObject    handle to modelStats (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    empty - handles not created until after all CreateFcns called
  % rowNames = {'scan_wintime', 'scan_hoptime', 'topPosteriorThreshold', 'feature_maxfreq', 'mappingType', 'numClusters', 'Classified?', 'Success %'}
  modelStats_refresh(handles);



function listbox_classlist_CreateFcn(hObject, eventdata, handles)
  disp('`listbox_classlist_CreateFcn`');


function pushbutton_make_model_Callback(hObject, eventdata, handles)
  conf = getappdata(0, 'conf');
  classData = getappdata(0, 'classData');
  appClassList = getappdata(0, 'appClassList');
  disp('`pushbutton_make_model_Callback`');

  availableFeatures = get(handles.listbox_features, 'String');
  selectedFeaturesIdx = get(handles.listbox_features, 'Value');
  selectedFeatures = {};
  for i = selectedFeaturesIdx
    selectedFeatures{length(selectedFeatures)+1} = availableFeatures{i};
  end
  conf.selectedFeatures = selectedFeatures;

  selectedClasses = get(handles.listbox_classlist, 'Value');
  for classIdx = selectedClasses
    classNumber = appClassList(classIdx);
    label = sprintf(conf.classLabelStr, classNumber);
    filename = getClassFileName(classNumber);
    filedata = load(filename);

    classData.classNumberList = [classData.classNumberList classNumber];
    classData.continuousClassSignals.(label) = filedata.continuousClassSignals.(label);
    classData.classSampleCounts.(label) = filedata.classSampleCounts.(label);
    classData.featuresByClass.(label) = [];
  end

  disp('selectedFeatures:');
  disp(conf.selectedFeatures);
  disp('classData:');
  disp(classData);

  setappdata(0, 'conf', conf);

  modelData = getModel(conf, classData);
  modelData.selectedFeatures = conf.selectedFeatures;
  modelFileName = getModelFileName(conf, modelData);
  set(handles.text_modelpath, 'String', modelFileName);
  fprintf('Saved model in %s\n', modelFileName);
  save(modelFileName, '-struct', 'modelData');
  setappdata(0, 'modelData', modelData);


function edit_bins_Callback(hObject, eventdata, handles)
  disp('`edit_bins_ChangeFcn`');
  conf = getappdata(0, 'conf');
  conf.numClusters = str2num(get(handles.edit_bins, 'String'));
  setappdata(0, 'conf', conf);


function pushbutton_load_model_Callback(hObject, eventdata, handles)
  conf = getappdata(0, 'conf');
  [filename, pathname] = uigetfile('*.mat', 'select a MAT file');
  %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';
  fullpath = [pathname, filename];
  disp('fullpath:');
  disp(fullpath);

  set(handles.text_modelpath, 'String', fullpath);
  modelData = load(fullpath);

  appClassList = getappdata(0, 'appClassList');
  thisClassList = unique(modelData.modelLabel);
  newClassIndexes = [];
  for i = 1:length(thisClassList)
    idx = find(appClassList==thisClassList(i));
    newClassIndexes = [newClassIndexes idx];
  end
  set(handles.listbox_classlist, 'Value', newClassIndexes);




  conf.selectedFeatures = modelData.selectedFeatures;
  setappdata(0, 'modelData', modelData);
  setappdata(0, 'conf', conf);
  initializeData(handles);









