function [badIndices, sums] = filterBins3(modelTable, modelLabel, removeCount)
if nargin < 3
  removeCount = 5;
end

badIndices = [];
sums = [];

numObs = size(modelTable, 1);
numFeat = size(modelTable, 2);
numClasses = length(unique(modelLabel));
classes = unique(modelLabel);

protoConfidence = [];

protoIndex = 1;
yy = classes';
for protoIndex = 1:numFeat
  mtx = modelTable(:,protoIndex);
  [IDX, D] = knnsearch(mtx,mtx,'K',11);

  % obs = 1;
  thisConfidence = 0;
  for obs = 1:numObs
    xx = IDX(obs,2:end); % omit first since it will be 0 (distance to itself)

    % translate to class
    for c = 1:length(xx)
      xx(c) = modelLabel(xx(c));
    end
    counts = hist(xx,yy);
    thisConfidence = thisConfidence + max(counts) - min(counts);
  end
  protoConfidence = [protoConfidence thisConfidence];
end

[v, I] = sort(protoConfidence);
if length(I) > removeCount
  badIndices = I(1:removeCount);
else
  badIndices = I;
  warning 'removing more indices than exist';
end



%%% process sums
modelTable = [modelTable modelLabel];

classRanges = {};

for i = 1:length(classes)
  c = classes(i);
  classRanges{c} = modelTable(modelTable(:, (numFeat+1)) == c, 1:numFeat);
end

for i = 1:length(classes)
  c = classes(i);
  if size(classRanges{c},1) > 1
    sumFeat = sum(classRanges{c});
  else
    sumFeat = classRanges{c};
  end
  normSumFeat = sumFeat ./ sum(sumFeat);
  % normSumFeat = sumFeat;
  sums = [sums; normSumFeat];
end



