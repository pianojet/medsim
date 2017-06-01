% --- Executes on button press in zoombutton.
function zoombutton_Callback(hObject, eventdata, handles)
  % hObject    handle to zoombutton (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % playbackOptions = getappdata(0, 'playbackOptions');
  % playbackOptions.
  % gndOptions = getappdata(0, 'gndOptions');
  disp(sprintf('\nzoombutton_Callback()'));
  refreshPlaybackAxes();

  clickpos1 = getappdata(0, 'clickpos1');
  setappdata(0, 'zoomClickposDelta', clickpos1);
  disp(sprintf(' (zoombutton_Callback) zoomClickposDelta set to %d', clickpos1));
