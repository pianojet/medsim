function loadAudio(handles)
  conf = getappdata(0, 'conf');
  [filename, pathname] = uigetfile('*.wav', 'select an WAV file');
  %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';
  fullpath = [pathname, filename];
  disp('fullpath:');
  disp(fullpath);

  set(handles.dataPath, 'String', fullpath);
  conf.audioFile = fullpath;
  setappdata(0, 'conf', conf);
  % % conf = resetConfig();
  % conf.audioFile = [pathname, filename];
  initializePlayback(handles); % getPlaybackHandles
