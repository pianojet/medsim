function [badIndices] = filterMisClassified(segTable, segLabel, segLimits, removeCount)
if nargin < 3
  removeCount = 5;
end

badIndices = [];

numObs = size(modelTable, 1);
numFeat = size(modelTable, 2);
numClasses = length(unique(modelLabel));
numPerClass = numFeat / numClasses;

misClsBins = {};

modelTable = [modelTable modelLabel];

for i = 1:numClasses
  misClsBins{i} = [];
  classRange = numPerClass;
  limit_start = 1*i;
  limit_end = limit_start + numPerClass - 1;
  notThisClassObs = modelTable(modelTable(:, (numFeat+1)) ~= i, limit_start:limit_end);
  for obs = 1:size(notThisClassObs,1)

  end
end




% badIndices = [];
% sums = [];

% numObs = size(modelTable, 1);
% numFeat = size(modelTable, 2);
% numClasses = length(unique(modelLabel));


% modelTable = [modelTable modelLabel];

% classRanges = {};

% for i = 1:numClasses
%   classRanges{i} = modelTable(modelTable(:, (numFeat+1)) == i, 1:numFeat);
% end

% for c = 1:numClasses
%   sumFeat = sum(classRanges{c});
%   normSumFeat = sumFeat ./ sum(sumFeat);
%   % normSumFeat = sumFeat;
%   sums = [sums; normSumFeat];
% end

% values = [];
% getValue = @(v) (max(max(squareform(pdist(v)))));
% for c = 1:numFeat
%   values = [values getValue(sums(:,c))];
% end
% [v, I] = sort(values, 'descend');

% if length(I) > removeCount
%   badIndices = I(1:removeCount);
% else
%   badIndices = I;
%   warning 'removing more indices than exist';
% end
