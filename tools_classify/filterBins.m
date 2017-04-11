function [badIndices, sums] = filterBins(modelTable, modelLabel, varThreshold)
if nargin < 3
  varThreshold = 0.000005;
  disp('threshold set to default')
end

badIndices = [];
sums = [];

numObs = size(modelTable, 1);
numFeat = size(modelTable, 2);
numClasses = length(unique(modelLabel));


modelTable = [modelTable modelLabel];

classRanges = {};

for i = 1:numClasses
  classRanges{i} = modelTable(modelTable(:, (numFeat+1)) == i, 1:numFeat);
end

for c = 1:numClasses
  sumFeat = sum(classRanges{c});
  normSumFeat = sumFeat ./ sum(sumFeat);
  % normSumFeat = sumFeat;
  sums = [sums; normSumFeat];
end

vsums = var(sums);
% normVsums = vsums ./ sum(vsums);
% badIndices = find(normVsums < varThreshold);

badIndices = find(vsums < varThreshold);
