function c = getClassKnn(scores, options)
  % expect the predicted label to be last element
  % assumes classCount + 1 to be silence class
  % assumes classCount + 2 to be unknown class (if posterior below topThreshold)

  if ~isfield(options, 'topThreshold') options.topThreshold = 0;
  end
  topThreshold = options.topThreshold;

  if ~isfield(options, 'midThreshold') options.midThreshold = 0;
  end
  midThreshold = options.midThreshold;

  if ~isfield(options, 'lowThreshold') options.lowThreshold = 0;
  end
  lowThreshold = options.lowThreshold;


  if size(scores, 1) > 1
    scores = mean(scores);
  end

  numClasses = size(scores, 2) - 1;
  midClsDelta = numClasses;
  unconfident = 100; % class 100 is reserved for unconfident / unknown class

  scoresNoLabel = scores(1:(end-1));

  [M, cls] = max(scoresNoLabel);
  if (M >= topThreshold)
    c = cls;
  elseif (M >= midThreshold)
    c = cls + midClsDelta;
  else
    c = unconfident;
  end




  % c = scores(1,end);