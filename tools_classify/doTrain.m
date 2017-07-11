function mdl = doTrain(conf, modelData)

if ~isfield(conf, 'nn_patternnet')
  conf.nn_patternnet = 5;
end

if ~isfield(conf, 'nn_showWindow')
  conf.nn_showWindow = 0;
end

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
  % save(conf.modelknnFile,'mdl');
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
  % save(conf.modelcnbFile,'mdl');
%%% needs more logic to reduce to multiple 2-class modals for svm
% else
%   mdl = fitcsvm(modelTable, modelLabel);
elseif strcmp(conf.classifier, 'myNB')
  mdl = myNB_trainClassConditionals(modelTable, modelLabel);
  % save(conf.modelmyNBFile,'mdl');
elseif strcmp(conf.classifier, 'nn')
  if ~isfield(modelData, 'featuresByClass')
    error 'Can not train neural network without features';
  end

  ff = modelData.featuresByClass;
  labelcells = fieldnames(ff);
  numClasses = length(labelcells);

  nn_x = [];
  nn_t = [];
  tagClass = zeros(numClasses,1);
  tagClass(1,1) = 1;

  % ensure sorted by number... not string, can't do sort(labelcells)
  sortedlabels = sort(cellfun(@(s)sscanf(s,conf.classLabelStr), labelcells));
  for label = sortedlabels'
    labelfield = sprintf(conf.classLabelStr,label);
    features = ff.(labelfield);
    numFeatures = size(features,1);
    nn_x = [nn_x features'];
    nn_t = [nn_t ones(numClasses,numFeatures).*tagClass];
    tagClass = circshift(tagClass,1); % rotate to be able to tag next class
  end
  mdl = patternnet(conf.nn_patternnet);
  mdl.trainParam.showWindow = conf.nn_showWindow;
  [mdl,tr] = train(mdl,nn_x,nn_t);
  mdl.userdata.sortedlabels = sortedlabels;


end

disp('Training completed.');
