function classifierFile = getClassifierFileName()
  classifierData = getappdata(0, 'classifierData');
  conf = getappdata(0, 'conf');

  classifierFeatures = conf.selectedFeatures{1};
  for f = 2:length(conf.selectedFeatures)
    classifierFeatures = [classifierFeatures '|' conf.selectedFeatures{f}];
  end
  classNumberList = sort(unique(classifierData.modelLabel));
  classString = sprintf('%d', classNumberList(1));
  for classIndex = 2:length(classNumberList)
    classString = [classString '|' sprintf('%d', classNumberList(classIndex))];
  end
  if strcmp(class(classifierData.mdl), 'ClassificationKNN')
    conf.classifier = 'knn';
  elseif strcmp(class(classifierData.mdl), 'ClassificationNaiveBayes')
    conf.classifier = 'naivebayes';
  else
    conf.classifier = 'myNB';
  end

  % classifierFile = sprintf('%s/qt_err_%04d_%s_%s_%dBins_%s.mat', conf.classifierPath, round(classifierData.err*100), conf.classifier, classifierFeatures, length(classifierData.mus), classString);
  classifierFile = sprintf('%sapp_%s_%s_%dBins_%s.mat', conf.classifierPath, conf.classifier, classifierFeatures, length(classifierData.mus), classString);
