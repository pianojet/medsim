function modelFile = getModelFileName()
  modelData = getappdata(0, 'modelData');
  conf = getappdata(0, 'conf');

  classifierFeatures = conf.selectedFeatures{1};
  for f = 2:length(conf.selectedFeatures)
    classifierFeatures = [classifierFeatures '|' conf.selectedFeatures{f}];
  end
  classNumberList = sort(unique(modelData.modelLabel));
  classString = sprintf('%d', classNumberList(1));
  for classIndex = 2:length(classNumberList)
    classString = [classString '|' sprintf('%d', classNumberList(classIndex))];
  end
  modelFile = sprintf('%sapp_%s_%dBins_%s.mat', conf.modelPath, classifierFeatures, length(modelData.mus), classString);

