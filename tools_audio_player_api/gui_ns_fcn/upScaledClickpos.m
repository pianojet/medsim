function [clickpos1Up clickpos2Up] = upScaledClickpos(signal)
  disp(sprintf('\nupScaledClickpos()'));
  % `signal` can be undefined

  playbackOptions = getappdata(0, 'playbackOptions');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');
  zoomClickposDelta = getappdata(0, 'zoomClickposDelta');

  %disp(sprintf('clickpos1: %d, clickpos2: %d, zoomClickposDelta: %d', clickpos1, clickpos2, zoomClickposDelta));
  if clickpos1 <= playbackOptions.downSampleFactor
    clickpos1Up = 1;
  else
    clickpos1Up = ((clickpos1 * playbackOptions.downSampleFactor) - playbackOptions.downSampleFactor) + 1;
  end

  if ((exist('signal','var') && ~isempty(signal)) && clickpos2 * playbackOptions.downSampleFactor > (length(signal) - playbackOptions.downSampleFactor))
    clickpos2Up = length(signal);
  else
    clickpos2Up = clickpos2 * playbackOptions.downSampleFactor;
  end

  % apply delta to account for selecting audio in an already zoomed window
  clickpos1Up = clickpos1Up + (zoomClickposDelta * playbackOptions.downSampleFactor);
  clickpos2Up = clickpos2Up + (zoomClickposDelta * playbackOptions.downSampleFactor);

  %disp(sprintf('clickpos1Up: %d, cliskpos2Up: %d\n', clickpos1Up, clickpos2Up));
