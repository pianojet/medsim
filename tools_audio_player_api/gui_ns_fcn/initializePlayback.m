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
  setappdata(0, 'signalClassified', []);

  % gndOptions = playbackOptions;
  % gndOptions.figure = handles.gndFigure;
  % gndOptions.title = 'Classified';
  % setappdata(0, 'gndOptions', gndOptions);

  set(handles.signalFigure, 'buttondownfcn', @signalFigure_buttondownfcn);
  setappdata(0, 'clickpos1', 1);
  setappdata(0, 'clickpos2', ceil(audio_info.TotalSamples/conf.playbackDSFactor));

  % init playback gui
  refreshPlaybackAxes();
