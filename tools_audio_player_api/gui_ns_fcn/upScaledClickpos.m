function [clickpos1Up clickpos2Up] = upScaledClickpos(signal)
  % `signal` can be undefined

  playbackOptions = getappdata(0, 'playbackOptions');
  clickpos1 = getappdata(0, 'clickpos1');
  clickpos2 = getappdata(0, 'clickpos2');

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
