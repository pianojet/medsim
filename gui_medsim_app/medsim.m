function varargout = medsim(varargin)
% MEDSIM MATLAB code for medsim.fig
%      MEDSIM, by itself, creates a new MEDSIM or raises the existing
%      singleton*.
%
%      H = MEDSIM returns the handle to a new MEDSIM or the handle to
%      the existing singleton*.
%
%      MEDSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEDSIM.M with the given input arguments.
%
%      MEDSIM('Property','Value',...) creates a new MEDSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before medsim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to medsim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help medsim

% Last Modified by GUIDE v2.5 13-Apr-2017 15:24:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @medsim_OpeningFcn, ...
                   'gui_OutputFcn',  @medsim_OutputFcn, ...
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


% --- Executes just before medsim is made visible.
function medsim_OpeningFcn(hObject, eventdata, handles, varargin)
  disp('medsim_OpeningFcn');
  % This function has no output args, see OutputFcn.
  % hObject    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % varargin   command line arguments to medsim (see VARARGIN)

  % Choose default command line output for medsim
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);
  usrInit = @initMedsim;
  setappdata(0, 'usrInit', usrInit);
  initMedsim(handles);


  % UIWAIT makes medsim wait for user response (see UIRESUME)
  % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = medsim_OutputFcn(hObject, eventdata, handles)
  % varargout  cell array for returning output args (see VARARGOUT);
  % hObject    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)

  % Get default command line output from handles structure
  varargout{1} = handles.output;

function initMedsim(handles)
  disp('`initMedsim`');
  conf = struct;
  % conf = initializeConfig('/Users/justin/Documents/MATLAB/medsim/config/emo_app_config.ini');
  %set(handles.text_emotion_classifier_file, 'String', []);
  % set(handles.text_emotion_model_file, 'String', []);
  % conf = initializeConfig('/Users/justin/Documents/MATLAB/medsim/config/spk_app_config.ini');
  %set(handles.text_speaker_classifier_file, 'String', []);
  % set(handles.text_speaker_model_file, 'String', []);
  if isfield(conf, 'audioFile') conf = rmfield(conf, 'audioFile'); end; % gui needs user to choose audiofile

  set(handles.radiobutton_speakerEmo, 'Enable', 'off');
  set(handles.radiobutton_speaker, 'Enable', 'off');
  set(handles.radiobutton_emo, 'Enable', 'off');

  setappdata(0, 'conf', conf);
  setappdata(0, 'spkSignalClassified', []);
  setappdata(0, 'emoSignalClassified', []);
  setappdata(0, 'signalClassified', []);
  setappdata(0, 'palette', defaultPalette());
  setappdata(0, 'isSignalClassifiedCombined', 0);


function pushbutton_find_speakers_Callback(hObject, eventdata, handles)
  disp('find speakers...');
  conf = initializeConfig('/Users/justin/Documents/MATLAB/medsim/config/spk_app_config.ini');
  conf.audioFile = get(handles.dataPath, 'String');
  if (~isfield(conf, 'audioFile') || isempty(conf.audioFile))
    disp('Cannot continue without selecting an audio file!');
    return
  end
  conf.modelClassifierFile = get(handles.text_speaker_classifier_file, 'String');

  if isempty(conf.modelClassifierFile) || isempty(conf.audioFile)
    warning('no classifier or audio available');
    return
  end

  setappdata(0, 'conf', conf);

  classifierData = load(conf.modelClassifierFile);
  [spkSignalClassified, badIndices, modelSums] = test_20161013(conf, classifierData);
  setappdata(0, 'spkSignalClassified', spkSignalClassified);

  updateDisplay(handles);


function pushbutton_find_anger_Callback(hObject, eventdata, handles)
  conf = initializeConfig('/Users/justin/Documents/MATLAB/medsim/config/emo_app_config.ini');
  conf.audioFile = get(handles.dataPath, 'String');
  if (~isfield(conf, 'audioFile') || isempty(conf.audioFile))
    disp('Cannot continue without selecting an audio file!');
    return
  end
  conf.modelClassifierFile = get(handles.text_emotion_classifier_file, 'String');

  if isempty(conf.modelClassifierFile) || isempty(conf.audioFile)
    warning('no classifier or audio available');
    return
  end

  setappdata(0, 'conf', conf);

  classifierData = load(conf.modelClassifierFile);
  [emoSignalClassified, badIndices, modelSums] = test_20161013(conf, classifierData);
  setappdata(0, 'emoSignalClassified', emoSignalClassified);

  updateDisplay(handles);



function updateDisplay(handles)
  spkSignalClassified = getappdata(0, 'spkSignalClassified');
  emoSignalClassified = getappdata(0, 'emoSignalClassified');
  palette = getappdata(0, 'palette');
  playbackOptions = getappdata(0, 'playbackOptions');
  isSignalClassifiedCombined = getappdata(0, 'isSignalClassifiedCombined');

  if isempty(spkSignalClassified) && isempty(emoSignalClassified)
    playbackOptions.colors = palette.default;
    setappdata(0, 'playbackOptions', playbackOptions);
    refreshPlaybackAxes();
    return
  end


  if ~isempty(spkSignalClassified) && ~isempty(emoSignalClassified)
    set(handles.radiobutton_speakerEmo, 'Enable', 'on');
    set(handles.radiobutton_speaker, 'Enable', 'on');
    set(handles.radiobutton_emo, 'Enable', 'on');

    showAll = (get(handles.radiobutton_speakerEmo, 'Value') == 1);
    showSpk = (get(handles.radiobutton_speaker, 'Value') == 1);
    showEmo = (get(handles.radiobutton_emo, 'Value') == 1);

  else
    set(handles.radiobutton_speakerEmo, 'Enable', 'off');
    set(handles.radiobutton_speaker, 'Enable', 'off');
    set(handles.radiobutton_emo, 'Enable', 'off');

    showSpk = isempty(emoSignalClassified);
    showEmo = ~showSpk;

  end


  if showSpk
    setappdata(0, 'signalClassified', spkSignalClassified);
    playbackOptions.colors = palette.speaker;
  elseif showEmo
    setappdata(0, 'signalClassified', emoSignalClassified);
    playbackOptions.colors = palette.emo;
  elseif showAll
    spkSignalClassified(emoSignalClassified==3) = spkSignalClassified(emoSignalClassified==3)+4;
    setappdata(0, 'signalClassified', spkSignalClassified);
    playbackOptions.colors = palette.speakerEmo;
  else
    playbackOptions.colors = palette.default;
  end


  setappdata(0, 'playbackOptions', playbackOptions);
  refreshPlaybackAxes();


function pushbutton_find_all_Callback(hObject, eventdata, handles)
  pushbutton_find_speakers_Callback(hObject, eventdata, handles);
  pushbutton_find_anger_Callback(hObject, eventdata, handles);





function pushbutton_emotion_classifier_Callback(hObject, eventdata, handles)
  disp('`pushbutton_emotion_classifier_Callback`');
  [filename, pathname] = uigetfile('*.mat', 'select a classifier (.MAT file)');
  %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';
  fullpath = [pathname, filename];
  disp('fullpath:');
  disp(fullpath);

  if ~isempty(find(fullpath==0))
    return
  end

  set(handles.text_emotion_classifier_file, 'String', fullpath);
  setappdata(0, 'emoSignalClassified', []);
  updateDisplay(handles);



function pushbutton_speaker_classifier_Callback(hObject, eventdata, handles)
  disp('`pushbutton_speaker_classifier_Callback`');
  [filename, pathname] = uigetfile('*.mat', 'select a classifier (.MAT file)');
  %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';
  fullpath = [pathname, filename];
  disp('fullpath:');
  disp(fullpath);

  if ~isempty(find(fullpath==0))
    return
  end

  set(handles.text_speaker_classifier_file, 'String', fullpath);
  setappdata(0, 'spkSignalClassified', []);
  updateDisplay(handles);



function uibuttongroup_display_Callback(hObject, eventdata, handles)
  disp('`uibuttongroup_display_Callback`');
  disp('eventdata:');
  disp(eventdata.NewValue);

function radiobutton_speaker_Callback(hObject, eventdata, handles)
  disp('`radiobutton_speaker_Callback`');
  updateDisplay(handles);

function radiobutton_emo_Callback(hObject, eventdata, handles)
  disp('`radiobutton_emo_Callback`');
  updateDisplay(handles);

function radiobutton_speakerEmo_Callback(hObject, eventdata, handles)
  disp('`radiobutton_speakerEmo_Callback`');
  updateDisplay(handles);




