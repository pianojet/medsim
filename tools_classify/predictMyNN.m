function [label scores] = predictMyNN(mdl, features)

  classes = mdl(features');
  testIndices = vec2ind(classes);

  totalObs = size(testIndices, 2);
  numClasses = size(mdl.userdata.sortedlabels, 1);

  scores = [];
  for c = 1:numClasses
    scores = [scores sum(testIndices==c)];
  end

  scores = scores ./ sum(scores);

  [M, idx] = max(scores);
  label = mdl.userdata.sortedlabels(idx);
