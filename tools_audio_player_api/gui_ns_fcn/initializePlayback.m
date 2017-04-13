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
