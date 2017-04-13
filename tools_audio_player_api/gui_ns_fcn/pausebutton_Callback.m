function pausebutton_Callback(hObject, eventdata, handles)
  % pause / resume playback
  action = get(hObject, 'String');
  player = getappdata(0, 'player_handle');
  if strcmp(action, 'Pause')
    pause(player);
    set(hObject, 'String', 'Resume');
  else
    resume(player);
    set(hObject, 'String', 'Pause');
  end
