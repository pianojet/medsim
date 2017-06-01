function refreshAxes_Callback(hObject, eventdata, handles)
  % --- Executes on button press in refreshAxes.
  audio_info = getappdata(0, 'audio_info');
  playbackOptions = getappdata(0, 'playbackOptions');

  % refresh playbackOptions ?????? remove ???????
  playbackOptions.start = str2num(get(handles.axesTimeStart, 'String')) * audio_info.SampleRate;
  playbackOptions.end = str2num(get(handles.axesTimeEnd, 'String')) * audio_info.SampleRate;

  % playbackOptions.playHeadLoc = str2num(get(handles.axesTimeStart, 'String')) * audio_info.SampleRate;
  playbackOptions.playHeadLoc = 1;
  setappdata(0, 'playbackOptions', playbackOptions);
  setappdata(0, 'clickpos1', 1);
  setappdata(0, 'clickpos2', floor(audio_info.TotalSamples/playbackOptions.downSampleFactor));
  setappdata(0, 'zoomClickposDelta', 0);


  % % view changes, deprecates this signalClassified
  % fullClassified = getappdata(0, 'fullClassified');
  % if length(fullClassified) > 0
  %   clickpos1 = getappdata(0, 'clickpos1');
  %   clickpos2 = getappdata(0, 'clickpos2');
  %   if clickpos2*playbackOptions.downSampleFactor > length(fullClassified)
  %     clickpos2 = floor(length(fullClassified) / playbackOptions.downSampleFactor);
  %     setappdata(0, 'clickpos2', clickpos2);
  %   end
  %   % setappdata(0, 'signalClassified', fullClassified(clickpos1*playbackOptions.downSampleFactor:clickpos2*playbackOptions.downSampleFactor));
  %   setappdata(0, 'signalClassified', getSignalClip(fullClassified));
  % else
  %   setappdata(0, 'signalClassified', []);
  % end

  % refresh axes
  refreshPlaybackAxes();
  % refreshGndAxes(handles.axes6);
