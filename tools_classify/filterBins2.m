function [badIndices, sums] = filterBins2(modelTable, modelLabel, removeCount)
if nargin < 3
  removeCount = 5;
end

badIndices = [];
sums = [];

numObs = size(modelTable, 1);
numFeat = size(modelTable, 2);
numClasses = length(unique(modelLabel));
classes = unique(modelLabel);

modelTable = [modelTable modelLabel];

classRanges = {};

for i = 1:length(classes)
  c = classes(i);
  classRanges{c} = modelTable(modelTable(:, (numFeat+1)) == c, 1:numFeat);
end

for i = 1:length(classes)
  c = classes(i);
  sumFeat = sum(classRanges{c});
  normSumFeat = sumFeat ./ sum(sumFeat);
  % normSumFeat = sumFeat;
  sums = [sums; normSumFeat];
end




values = [];
getValue = @(v) (max(max(squareform(pdist(v)))));
for c = 1:numFeat
  values = [values getValue(sums(:,c))];
end
[v, I] = sort(values, 'descend');




if length(I) > removeCount
  badIndices = I(1:removeCount);
else
  badIndices = I;
  warning 'removing more indices than exist';
end
