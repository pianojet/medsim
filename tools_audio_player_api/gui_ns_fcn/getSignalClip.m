function [signal_clip limits] = getSignalClip(signal)
  % selected area
  [clickpos1Up clickpos2Up] = upScaledClickpos(signal);
  signal_clip = signal( clickpos1Up:clickpos2Up , :);
  limits = [clickpos1Up clickpos2Up];
