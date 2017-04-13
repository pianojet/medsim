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
