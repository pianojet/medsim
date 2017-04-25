function signalFigure_buttondownfcn(ax, hit)
  audio_info = getappdata(0, 'audio_info');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  playbackOptions = getappdata(0, 'playbackOptions');

  ax; % figure axes1


  % setappdata(0, 'signalClassified', []);


  % playbackOptions.figure;
  % hitDownSampled = round(hit.IntersectionPoint(1))/playbackOptions.downSampleFactor;

  % fprintf('pre click positions:\n');
  % fprintf('clickpos1:\n');
  % disp(getappdata(0, 'clickpos1'));
  % fprintf('clickpos2:\n');
  % disp(getappdata(0, 'clickpos2'));

  hold on;
  if clickpos1 == 1 || round(hit.IntersectionPoint(1)) < clickpos1
    if round(hit.IntersectionPoint(1)) < clickpos1
      plot([clickpos1 clickpos1], [-1 1], 'w', 'LineWidth', 2);
    end
    clickpos1 = round(hit.IntersectionPoint(1));
    playbackOptions.playHeadLoc = clickpos1;
    plot([clickpos1 clickpos1], [-1 1], 'k', 'LineWidth', 2);
  elseif clickpos2 < floor(audio_info.TotalSamples/playbackOptions.downSampleFactor)
    plot([clickpos1 clickpos1], [-1 1], 'w', 'LineWidth', 2);
    plot([clickpos2 clickpos2], [-1 1], 'w', 'LineWidth', 2);
    clickpos1 = round(hit.IntersectionPoint(1));
    playbackOptions.playHeadLoc = clickpos1;
    clickpos2 = floor(audio_info.TotalSamples/playbackOptions.downSampleFactor);
    plot([clickpos1 clickpos1], [-1 1], 'k', 'LineWidth', 2);
  else
    clickpos2 = round(hit.IntersectionPoint(1));
    plot([clickpos2 clickpos2], [-1 1], 'k', 'LineWidth', 2);
  end
  hold off;
  setappdata(0, 'clickpos1', clickpos1);
  setappdata(0, 'clickpos2', clickpos2);
  setappdata(0, 'playbackOptions', playbackOptions);

  % fprintf('set click positions:\n');
  % fprintf('clickpos1:\n');
  % disp(getappdata(0, 'clickpos1'));
  % fprintf('clickpos2:\n');
  % disp(getappdata(0, 'clickpos2'));
