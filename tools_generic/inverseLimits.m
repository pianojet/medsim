function inverse = inverseLimits(limits, totalSamples)
  % Inverses a list of integer pairs (limit endpoints)
  %   into a list of pairs that exist between the limits

  l1 = limits;
  inverse = [];

  while (size(l1,1) > 1)
    this_seg = l1(1,:);
    next_seg = l1(2,:);

    rseg = [this_seg(2)+1 next_seg(1)-1];
    inverse = [inverse; rseg];

    l1(1,:) = [];
  end

  this_seg = l1(1,:);
  if this_seg(2) < totalSamples
    rseg = [this_seg(2)+1 totalSamples];
    inverse = [inverse; rseg];
  end
