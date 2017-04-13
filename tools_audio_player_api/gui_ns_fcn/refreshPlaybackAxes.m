function refreshPlaybackAxes()
  % options
  playbackOptions = getappdata(0, 'playbackOptions');
  % gndOptions = getappdata(0, 'gndOptions');
  % modelData = getappdata(0, 'modelData');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  audio_info = getappdata(0, 'audio_info');
  user_def_refresh_callbacks = getappdata(0, 'user_def_refresh_callbacks');

  % audio data
  [audio_data limits] = getSignalClip(getappdata(0, 'audio_data'));
  % [playbackOptions.signalClassified limits] = getSignalClip(getappdata(0, 'gnd_data'), playbackOptions.downSampleFactor);
  playbackOptions.samplelimits = limits;
  % gndOptions.samplelimits = limits;
  setappdata(0, 'playbackOptions', playbackOptions);
  % setappdata(0, 'gndOptions', gndOptions);

  % % display audio
  % signalClassified = getappdata(0, 'signalClassified');
  % fullClassified = getappdata(0, 'fullClassified');

  % % if full signal, ensure it's same size as audio_data above
  % % keeping the top "playback" area as gnd, and the current gnd as classifier display
  % if length(fullClassified) > 0
  %   gndOptions.signalClassified = getSignalClip(fullClassified, gndOptions.downSampleFactor);
  % else
  %   gndOptions.signalClassified = signalClassified;
  % end

  % % if full signal, ensure it's same size as audio_data above
  % if (clickpos1 <= playbackOptions.downSampleFactor) && clickpos2 >= floor(audio_info.TotalSamples/playbackOptions.downSampleFactor)
  %   playbackOptions.signalClassified = getSignalClip(signalClassified, playbackOptions.downSampleFactor);
  % else
  %   playbackOptions.signalClassified = signalClassified;
  % end

  refreshaxes(audio_data, audio_info, playbackOptions);
  % refreshaxes(audio_data, audio_info, gndOptions);

  % new player
  newPlayer(audio_data, audio_info, playbackOptions);

  if user_def_refresh_callbacks
  end
  % plotTrainSegments(modelData, playbackOptions);
