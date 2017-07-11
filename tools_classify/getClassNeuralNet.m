function [c confidence] = getClassNeuralNet(scores, options)
  % expect the predicted label to be last element


  if ~isfield(options, 'topThreshold') options.topThreshold = 0;
  end
  topThreshold = options.topThreshold;

  if ~isfield(options, 'midThreshold') options.midThreshold = 0;
  end
  midThreshold = options.midThreshold;

  if ~isfield(options, 'lowThreshold') options.lowThreshold = 0;
  end
  lowThreshold = options.lowThreshold;

  if ~isfield(options, 'labelMap')
    keySet = 1:100;
    valueSet = 1:100;
    options.labelMap = containers.Map(keySet, valueSet);
  end

  if size(scores, 1) > 1
    scores = mean(scores);
  end

  numClasses = size(scores, 2) - 1;
  midClsDelta = numClasses;
  unconfident = 101; % class 101 is reserved for unconfident / unknown class

  scoresNoLabel = scores(1:(end-1));

  [M, cls] = max(scoresNoLabel);
  mapValues = options.labelMap.values();
  c = mapValues{cls};
  if (M >= topThreshold)
    confidence = 1;
  elseif (M >= midThreshold)
    confidence = 2;
  else
    c = unconfident;
    confidence = 3;
  end
