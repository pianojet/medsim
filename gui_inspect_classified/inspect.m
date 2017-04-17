function varargout = inspect(varargin)
% INSPECT MATLAB code for inspect.fig
%      INSPECT, by itself, creates a new INSPECT or raises the existing
%      singleton*.
%
%      H = INSPECT returns the handle to a new INSPECT or the handle to
%      the existing singleton*.
%
%      INSPECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSPECT.M with the given input arguments.
%
%      INSPECT('Property','Value',...) creates a new INSPECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inspect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inspect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inspect

% Last Modified by GUIDE v2.5 13-Apr-2017 15:24:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inspect_OpeningFcn, ...
                   'gui_OutputFcn',  @inspect_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);

disp('inspect.m');
disp('varargin:');
disp(varargin);

if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before inspect is made visible.
function inspect_OpeningFcn(hObject, eventdata, handles, varargin)
  disp('inspect_OpeningFcn');
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to inspect (see VARARGIN)

% Choose default command line output for inspect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% conf = initializeConfig('/Users/justin/Documents/MATLAB/medsim/scratch/emotion.ini');
conf = initializeConfig('/Users/justin/Documents/MATLAB/medsim/quicktrain/config/app_config.ini');
% remove any existing audio file data from config (gui needs user to choose)
if isfield(conf, 'audioFile')
  conf = rmfield(conf, 'audioFile');
end

setappdata(0, 'conf', conf);

% UIWAIT makes inspect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = inspect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;






function pushbutton_classify_emotion_Callback(hObject, eventdata, handles)
  disp('classifying emotions...');
  conf = getappdata(0, 'conf');
  conf.audioFile = get(handles.dataPath, 'String');
  playbackOptions = getappdata(0, 'playbackOptions');
  playbackOptions.colors = [0.7 0.0 0.0; 0.0 0.7 0.0; 1.0 0.8 0.8; 0.8 1.0 0.8; 0.9 0.0 0.9; 0.0 0.0 0.0];

  if (~isfield(conf, 'audioFile') || isempty(conf.audioFile))
    disp('Cannot continue without selecting an audio file!');
    return
  end
  modelData = load(conf.modelDataFile);

  % conf.modelknnFile='/Users/justin/Documents/MATLAB/medsim_analysis/data/emotion/knnModel.mat';
  % conf.modelcnbFile='/Users/justin/Documents/MATLAB/medsim_analysis/data/emotion/cnbModel.mat';
  % conf.modelmyNBFile='/Users/justin/Documents/MATLAB/medsim_analysis/data/emotion/myNBModel.mat';

  [signalClassified, badIndices, modelSums] = test_20161013(conf, modelData);
  playbackOptions.signalClassified = getSignalClip(signalClassified);

  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  disp('clickpos1, clickpos2, size(signalClassified):');
  disp(clickpos1);
  disp(clickpos2);
  disp(size(signalClassified));


  setappdata(0, 'playbackOptions', playbackOptions);
  refreshPlaybackAxes();




