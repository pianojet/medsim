function loadAudio(handles)
  [filename, pathname] = uigetfile('*.wav', 'select an WAV file');
  %dataPath = '/Users/justin/Documents/MATLAB/medsim/data/med4_mashup';

  disp('[filename, pathname]:');
  disp([filename, pathname]);

  set(handles.dataPath, 'String', [pathname, filename]);
  % % conf = resetConfig();
  % conf.audioFile = [pathname, filename];
  initializePlayback(handles); % getPlaybackHandles
