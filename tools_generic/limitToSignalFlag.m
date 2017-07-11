function flagged = limitToSignalFlag(limits, totalSamples)
  % Flags ranges between limits as 1 with all other bits as 0
  %   for the length of a column with size `totalSamples`

  flagged = zeros(totalSamples,1);

  l1 = limits;
  while (size(l1,1) > 0)
    seg = l1(1,:);
    flagged(seg(1):seg(2),1) = 1;
    l1(1,:) = [];
  end