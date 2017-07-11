function [label, scores] = myNB_getPosterior(mdl, observation)
  cc = mdl.cc;
  numClasses = mdl.numClasses;
  numFeat = mdl.numFeat;
  classnames = mdl.ClassNames;


  pp = ones(numClasses, 1); %%%%%%% could init with priors

  for c = 1:numClasses
    thisPosterior = pp(c);
    for feat = 1:numFeat
      thisPosterior = thisPosterior * (cc(c,feat)^observation(feat));
    end
    pp(c) = thisPosterior;
  end
  [a, label] = max(pp);
  label = classnames(label);
  scores = pp';

