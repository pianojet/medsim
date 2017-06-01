function loadAudio(handles)
  conf = getappdata(0, 'conf');
  [filename, pathname] = uigetfile('*.wav', 'select an WAV file');
  %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';
  fullpath = [pathname, filename];
  disp('fullpath:');
  disp(fullpath);

  if ~isempty(find(fullpath==0))
    return
  end

  set(handles.dataPath, 'String', fullpath);
  conf.audioFile = fullpath;
  setappdata(0, 'conf', conf);
  setappdata(0, 'zoomClickposDelta', 0);
  % % conf = resetConfig();
  % conf.audioFile = [pathname, filename];
  initializePlayback(handles); % getPlaybackHandles
