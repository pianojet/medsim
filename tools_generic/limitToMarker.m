function markers = limitToMarker(limits, totalSamples)
  % converts a set of pairs of sound "limits" to a set
  % of pairs of markers that indicate silence, inclusive
  %
  % totalSamples is required for the last segment of silence

  s = size(limits);
  markers = [];
  if limits(1,1) > 1
    markers = [markers 1 (limits(1,1)-1)];
  end

  for n = 1:1:(s(1)-1)
    markers = [markers (limits(n,2)+1) (limits(n+1, 1)-1)];
  end

  if limits(end,2) < totalSamples
    markers = [markers (limits(end,2)+1) totalSamples];
  end
