function [c confidence] = getClassNaiveBayes(scores, options)
  % expect the predicted label to be last element of scores


  c = scores(end);

  % if ~isfield(options, 'topThreshold') options.topThreshold = 0;
  % end
  % topThreshold = options.topThreshold;

  % if ~isfield(options, 'labelMap')
  %   keySet = 1:100;
  %   valueSet = 1:100;
  %   options.labelMap = containers.Map(keySet, valueSet);
  % end


  % c = NaN;
  % unconfident = 101; % class 101 is reserved for unconfident / unknown class

  % classCount = size(scores,2) - 1;
  % topPct = max(abs(diff(mean(scores(:,1:classCount), 1)))); % get the % diff of top percent
  % if isnan(topPct)
  %   scores = scores(~any(isnan(scores),2),:);
  %   c = mode(scores(:,end));
  % elseif topPct >= topThreshold
  %   [Y, I] = max(mean(scores(:,1:classCount))); % get the class that's top
  %   c = I;
  % end

  % if isnan(c)
  %   c = unconfident;
  % end










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
  unconfident = 101; % class 101 is reserved for unconfident / unknown class


  scoresNoLabel = scores(1:numClasses);
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




  % if size(scores, 1) > 1
  %   scores = mean(scores);
  % end

  % numClasses = size(scores, 2) - 1;
  % midClsDelta = numClasses;
  % unconfident = 101; % class 101 is reserved for unconfident / unknown class

  % scoresNoLabel = scores(1:(end-1));

  % [M, cls] = max(scoresNoLabel);
  % mapValues = options.labelMap.values();
  % c = mapValues{cls};
  % if (M >= topThreshold)
  %   confidence = 1;
  % elseif (M >= midThreshold)
  %   confidence = 2;
  % else
  %   c = unconfident;
  %   confidence = 3;
  % end
