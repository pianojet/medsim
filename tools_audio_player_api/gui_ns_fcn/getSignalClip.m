function [signal_clip limits] = getSignalClip(signal)
  % selected area
  [clickpos1Up clickpos2Up] = upScaledClickpos(signal);
  fprintf('getSignalClip up scaled sample range: %d - %d\n', clickpos1Up, clickpos2Up);
  signal_clip = signal( clickpos1Up:clickpos2Up , :);
  limits = [clickpos1Up clickpos2Up];
