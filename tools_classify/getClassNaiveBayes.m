function c = getClassNaiveBayes(scores, options)
  % expect the predicted label to be last element
  % assumes classCount + 1 to be silence class
  % assumes classCount + 2 to be unknown class (if posterior below topThreshold)

  % c = scores(1,end);

  if ~isfield(options, 'topThreshold') options.topThreshold = 0;
  end
  topThreshold = options.topThreshold;

  c = NaN;

  classCount = size(scores,2) - 1;
  topPct = max(abs(diff(mean(scores(:,1:classCount), 1)))); % get the % diff of top percent
  if isnan(topPct)
    scores = scores(~any(isnan(scores),2),:);
    c = mode(scores(:,end));
  elseif topPct >= topThreshold
    [Y, I] = max(mean(scores(:,1:classCount))); % get the class that's top
    c = I;
  end

  if isnan(c)
    c = classCount + 2;
  end