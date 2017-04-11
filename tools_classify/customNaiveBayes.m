function mdl = trainClassConditionals(modelTables, modelLabels)
  numObs = size(modelTables, 1);
  numFeat = size(modelTables, 2);
  if numObs ~= length(modelLabels)
    warning 'OBSERVATIONS DONT MATCH LABELS'
  end

  numClasses = length(unique(modelLabels));
  classRanges = {};

  % scan for labeled indices
  limit_start = 1;
  thisClass = modelLabels(limit_start);
  for i = 1:numObs
    if modelLabels(i) ~= thisClass
      r = [limit_start i-1];
      classRanges{thisClass} = r;

      limit_start = i;
      thisClass = modelLabels(i);
    end
  end
  classRanges{thisClass} = [limit_start numObs];



  % Class Conditionals per feature & class
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  nn = zeros(numClasses, numFeat);
  dd = ones(numClasses, 1);

  for feat = 1:numFeat
    for c = 1:numClasses
      thisFeat = 0;
      for obs = classRanges{c}(1):classRanges{c}(2)
        thisFeat = thisFeat + modelTables(obs,feat);
      end
      nn(c,feat) = thisFeat;
    end
  end

  dd = sum(nn, 2);
  %cc = bsxfun(@rdivide, (nn), (dd));
  cc = bsxfun(@rdivide, (nn+1), (dd+numFeat));  %Laplace smoothing

  mdl.cc = cc;
  mdl.numClasses = numClasses;
  mdl.numFeat = numFeat;


function [label, scores] = getPosterior(observation)
  pp = ones(numClasses, 1); %%%%%%% could init with priors

  for c = 1:numClasses
    thisPosterior = pp(c);
    for feat = 1:numFeat
      thisPosterior = thisPosterior * (cc(c,feat)^observation(feat));
    end
    pp(c) = thisPosterior;
  end
  [a, label] = max(pp);
  scores = pp;

