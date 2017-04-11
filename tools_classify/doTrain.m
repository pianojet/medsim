function doTrain(conf, modelData)


if isfield(modelData, 'modelTable')
  modelTable = modelData.modelTable;
else
  warning 'No `modelTable` found in supplied config';
end
if isfield(modelData, 'modelLabel')
  modelLabel = modelData.modelLabel;
else
  warning 'No `modelLabel` found in supplied config';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% )  NEW TRAIN: train classifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(conf.classifier, 'knn')
  NumNeighbors = conf.knn_NumNeighbors; %default = 1
  Distance = conf.knn_Distance;
  % Standardize = conf.knn_Standardize;
  % IncludeTies = true;
  % BreakTies = 'nearest';
  mdl = fitcknn(modelTable, modelLabel, 'NumNeighbors',NumNeighbors, 'Distance',Distance); % default num neighbors: 1
  save(conf.modelknnFile,'mdl');
elseif strcmp(conf.classifier, 'naivebayes')
  DistributionNames = conf.naivebayes_DistributionNames;
  Kernel = conf.naivebayes_Kernel;
  %Width = conf.naivebayes_Width * ones(size(unique(modelLabel), 1), size(modelTable, 2));

  %mdl = fitcnb(modelTable, modelLabel, 'DistributionNames',Distribution, 'Kernel',Kernel, 'Width',Width); % default distribution: normal
  %mdl = fitcnb(modelTable, modelLabel, 'DistributionNames',DistributionNames, 'Kernel',Kernel, 'Width',Width); % default distribution: normal
  if strcmp(DistributionNames, 'kernel')
    % mdl = fitcnb(modelTable, modelLabel, 'DistributionNames',DistributionNames, 'Kernel',Kernel, 'ScoreTransform', 'ismax'); % default distribution: normal
    mdl = fitcnb(modelTable, modelLabel, 'DistributionNames',DistributionNames, 'Kernel',Kernel); % default distribution: normal
  else
    mdl = fitcnb(modelTable, modelLabel, 'DistributionNames',DistributionNames); % default distribution: normal
  end
  save(conf.modelcnbFile,'mdl');
%%% needs more logic to reduce to multiple 2-class modals for svm
% else
%   mdl = fitcsvm(modelTable, modelLabel);
elseif strcmp(conf.classifier, 'myNB')
  mdl = myNB_trainClassConditionals(modelTable, modelLabel);
  save(conf.modelmyNBFile,'mdl');
end

disp('Training completed.');
