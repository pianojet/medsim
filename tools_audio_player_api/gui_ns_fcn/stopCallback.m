function src = stopCallback(src, eventdata)
  % reset playhead
  myStruct = get(src, 'UserData');
  myStruct.playHeadLoc = 1;
  set(myStruct.ax, 'Xdata', [0 0]);
  set(src, 'UserData', myStruct);
