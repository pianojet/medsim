function newPlayer(audio_data, audio_info, playbackOptions)
  % requires pre-scaled, pre-snipped audio data (which is why these are params, and not getappdata)
  playbackOptions.playHeadLoc = 1;
  setappdata(0, 'playbackOptions', playbackOptions);
  player = refreshplayback(audio_data, audio_info, playbackOptions);
  % set(player, 'StopFcn', @stopCallback); `StopFcn` also called when pause
  setappdata(0, 'player_handle', player);
