% --- Executes on button press in zoombutton.
function zoombutton_Callback(hObject, eventdata, handles)
  % hObject    handle to zoombutton (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % playbackOptions = getappdata(0, 'playbackOptions');
  % playbackOptions.
  % gndOptions = getappdata(0, 'gndOptions');
  refreshPlaybackAxes();
