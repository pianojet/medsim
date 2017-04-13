function stopbutton_Callback(hObject, eventdata, handles)
  % stop playback
  player = getappdata(0, 'player_handle');
  stop(player);
  myStruct = get(player, 'UserData');
  % myStruct.playHeadLoc = get(handles.playHeadLoc, 'String');
  myStruct.playHeadLoc = 1;
  set(myStruct.ax, 'Xdata', [0 0]);
  set(player, 'UserData', myStruct);
