function returnData = quicktrainassess(maybeRootConfPath, options)
t1 = clock;
if (nargin == 0)
  maybeRootConfPath = '/Users/justin/Documents/MATLAB/medsim/quicktrain/config/spk_app_config.ini';
end

if (nargin < 2)
  options = struct;
end

if ~isfield(options, 'disablePlotting') options.disablePlotting = false; end;

returnData = struct;

if ischar(maybeRootConfPath)
  disp(sprintf('quicktrainassess.m, maybeRootConfPath: %s', maybeRootConfPath));
  conf = resetConfig(loadConfig(maybeRootConfPath));
elseif isstruct(maybeRootConfPath)
  conf = maybeRootConfPath;
else
  error('Bad conf input');
  return
end

if ~isfield(conf, 'saveFiles') conf.saveFiles = true; end;

[pathstr,thisAudioFileName,ext] = fileparts(conf.audioFile);
% conf.audioFile = 'data/emotion/raw/angry_neutral_trainer_train80pct.wav';
% conf.truthFile = 'data/emotion/raw/angry_neutral_trainer_train80pct_gnd.mat';

% if isstr(conf.selectedFeatures)
%   conf.selectedFeatures = {conf.selectedFeatures};
% end

% if isfield(pathconf, 'audioFile') conf.audioFile = pathconf.audioFile; end;
% if isfield(pathconf, 'truthFile') conf.truthFile = pathconf.truthFile; end;
% conf.metaPath = pathconf.metaPath;
% conf.mappingPath = pathconf.mappingPath;
% conf.modelknnPath = pathconf.modelknnPath;
% conf.modelcnbPath = pathconf.modelcnbPath;
% conf.graphDir = pathconf.graphDir;
% conf.modelmyNBPath = pathconf.modelmyNBPath;



% feature options & features (NOTE: mfcc (as opposed to melfcc) does not currently utilize options as thoroughly)
featExtOptions.wintime = conf.feature_wintime;
featExtOptions.hoptime = conf.feature_hoptime;
featExtOptions.numcep = conf.feature_numcep; % 13
featExtOptions.lifterexp = conf.feature_lifterexp; % 0.6
featExtOptions.sumpower = conf.feature_sumpower;
featExtOptions.preemph = conf.feature_preemph;
featExtOptions.dither = conf.feature_dither;
featExtOptions.minfreq = conf.feature_minfreq; % 0
featExtOptions.maxfreq = conf.feature_maxfreq; % 8000
featExtOptions.nbands = conf.feature_nbands;
featExtOptions.bwidth = conf.feature_bwidth;
featExtOptions.dcttype = conf.feature_dcttype;
featExtOptions.fbtype = conf.feature_fbtype; % 'bark' | 'mel' | 'htkmel' | 'fcmel'
featExtOptions.usecmp = conf.feature_usecmp;
featExtOptions.modelorder = conf.feature_modelorder;



% populationSize = 12;

%%%%%%%%%%%%
% train_20161013(conf);
% [signalClassified, err] = test_with_stats(conf);
%%%%%%%%%%%%

% population = []

% for i = 1:4
%   population = [population; featExtOptions];
% end

% newOptions.wintime = conf.feature_wintime;
% newOptions.hoptime = conf.feature_hoptime;
% newOptions.numcep = conf.feature_numcep; % 13
% newOptions.lifterexp = conf.feature_lifterexp;
% newOptions.sumpower = conf.feature_sumpower;
% newOptions.preemph = conf.feature_preemph;
% newOptions.dither = conf.feature_dither;
% newOptions.minfreq = conf.feature_minfreq; % 0
% newOptions.maxfreq = conf.feature_maxfreq; % 8000
% newOptions.nbands = conf.feature_nbands;
% newOptions.bwidth = conf.feature_bwidth;
% newOptions.dcttype = conf.feature_dcttype;
% newOptions.fbtype = conf.feature_fbtype; % 'bark' | 'mel' | 'htkmel' | 'fcmel'
% newOptions.usecmp = conf.feature_usecmp;
% newOptions.modelorder = conf.feature_modelorder;

if isfield(conf, 'continuousTraining') && conf.continuousTraining == 1
  maxPartitions = floor(1/conf.trainPartition);
else
  maxPartitions = conf.whichTrainingSegment;
end

allFilterErrStats = struct;
allFilterErrStats.filterX = [];
allFilterErrStats.filterY = [];
allWrapperErrStats = struct;
allWrapperErrStats.filterX = [];
allWrapperErrStats.filterY = [];

while conf.whichTrainingSegment <= maxPartitions
  fprintf('\nPartition %d...\n', conf.whichTrainingSegment);


  filterCount = 0;
  if isfield(conf, 'filterBins') && (conf.filterBins)
    filterCountMax = conf.filterBins;
  else
    filterCountMax = 0;
  end

  wrapperCount = 1;
  if isfield(conf, 'wrapperBins') && (conf.wrapperBins)
    wrapperCountMax = conf.wrapperBins;
  else
    wrapperCountMax = 0;
  end

  returnData = getModelWithGnd(conf);

  finalResults = struct;
  finalResults.err = 100;
  finalResults.featuresByClass = returnData.featuresByClass;

  filterErrStats = struct;
  filterErrStats.filterX = [];
  filterErrStats.filterY = [];

  wrapperErrStats = struct;
  wrapperErrStats.filterX = [];
  wrapperErrStats.filterY = [];

  filterBinTracking = {};
  for i = 1:filterCountMax
    filterBinTracking{i} = [];
  end
  filterMuTracking = {};
  for i = 1:filterCountMax
    filterMuTracking{i} = [];
  end



  classifierFeatures = conf.selectedFeatures{1};
  for f = 2:length(conf.selectedFeatures)
    classifierFeatures = [classifierFeatures '|' conf.selectedFeatures{f}];
  end
  if size(returnData.modelLabel, 1) > 0
    classNumberList = sort(unique(returnData.modelLabel));
  else
    classNumberList = [0];
  end
  classString = sprintf('%d', classNumberList(1));
  for classIndex = 2:length(classNumberList)
    classString = [classString '|' sprintf('%d', classNumberList(classIndex))];
  end
  returnData.selectedFeatures = conf.selectedFeatures;
  returnData.numClusters = conf.numClusters;
  returnData.mappingType = conf.mappingType;

  modelFile = sprintf('%s/qt_%dBins_%s_%s.%s.mat', conf.modelPath, length(returnData.mus), classifierFeatures, classString, thisAudioFileName);
  [thisfilepath,thisfilename]=fileparts(modelFile);
  if ~exist(thisfilepath)
    mkdir(thisfilepath);
  end
  if isfield(conf, 'saveFiles') && conf.saveFiles
    save(modelFile, '-struct', 'returnData');
  end

  if isempty(returnData.modelTable)
    continue
  end

  badIndices = [];
  badIndexHistory = [];
  initialPrototypeData = struct;

  conf.override.modelLabel = returnData.modelLabel;
  conf.override.modelTable = returnData.modelTable;
  conf.override.mus = returnData.mus;

  [badIndices, modelSums] = filterBins3(conf.override.modelTable, conf.override.modelLabel, 0); % running this just to get modelSums
  initialPrototypeData.modelSums = modelSums;

  while (filterCount <= filterCountMax) % should run at least once


    if (filterCount > 0)
      % updatedRemoveCount = conf.removeCount * (conf.filterIterations-filterCount);  % includes running with no bins removed

      % [badIndices, modelSums] = filterBins(modelTable, modelLabel, conf.varFilterThreshold);
      [badIndices, modelSums] = filterBins3(conf.override.modelTable, conf.override.modelLabel, conf.removeCount);
      % initialPrototypeData.modelSums = modelSums;

      filterBinTracking{filterCount} = badIndices;
      filterMuTracking{filterCount} = modelSums;

      conf.override.modelTable(:, badIndices) = [];
      conf.override.mus(badIndices, :) = [];

      fprintf(sprintf('\n\nBin iteration %d, prototype count: %d\n', filterCount, length(conf.override.mus)));

    end

    % conf.override.modelTable(:, badIndices) = [];
    % conf.override.mus(badIndices, :) = [];

    conf.override.mdl = doTrain(conf, conf.override);
    [signalClassified, err,    truth, x_down, c_down, sample_down,  badIndices, modelSums] = test_with_stats(conf);




    filterErrStats.filterX = [length(conf.override.mus) filterErrStats.filterX];
    filterErrStats.filterY = [err filterErrStats.filterY];




    fprintf('\n\n\n%f is < than %f ????????', err, finalResults.err);
    if err < finalResults.err

      finalResults.err = err;
      finalResults.truth = truth;
      finalResults.x_down = x_down;
      finalResults.c_down = c_down;
      finalResults.sample_down = sample_down;

      % used for wrapper filter later
      % finalResults.segLabel = segLabel;
      %finalResults.segTrain = segTrain;
      finalResults.mdl = conf.override.mdl;
      finalResults.modelTable = conf.override.modelTable;
      finalResults.modelLabel = conf.override.modelLabel;
      finalResults.mus = conf.override.mus;
      finalResults.modelPath = modelFile;
      classCount = length(unique(finalResults.modelLabel));
      finalResults.filterBins = length(finalResults.mus) - (classCount*conf.numClusters);

    end


    %badIndexHistory = [badIndexHistory badIndices];
    filterCount = filterCount + 1;
  end



  % initialize with starting point
  wrapperErrStats.filterX = [length(conf.override.mus) wrapperErrStats.filterX];
  wrapperErrStats.filterY = [err wrapperErrStats.filterY];


  % NOTE how `badIndices` holds the worst bins of the current state


  while (wrapperCount <= wrapperCountMax)

    disp(fprintf('\n\n\nWrapper iteration: %d', wrapperCount));
    % [badIndices] = filterMisClassified(segTable, segLabel, segLimits, signalClassified)

    conf.override.modelTable(:, badIndices) = [];
    conf.override.mus(badIndices, :) = [];

    mdl = doTrain(conf, conf.override);
    conf.override.mdl = mdl;
    % [signalClassified, err,    truth, x_down, c_down, sample_down,  segLabel, segTable, segLimits] = test_with_stats(conf);
    [signalClassified, err,    truth, x_down, c_down, sample_down,  badIndices, modelSums] = test_with_stats(conf);

    % for plotting...
    wrapperErrStats.filterX = [length(conf.override.mus) wrapperErrStats.filterX];
    wrapperErrStats.filterY = [err wrapperErrStats.filterY];


    fprintf('\n\n\n%f is < than %f ????????', err, finalResults.err);
    if err < finalResults.err

      finalResults.err = err;
      finalResults.truth = truth;
      finalResults.x_down = x_down;
      finalResults.c_down = c_down;
      finalResults.sample_down = sample_down;

      % used for wrapper filter later
      % finalResults.segLabel = segLabel;
      %finalResults.segTrain = segTrain;
      finalResults.mdl = mdl;
      finalResults.modelTable = conf.override.modelTable;
      finalResults.modelLabel = conf.override.modelLabel;
      finalResults.mus = conf.override.mus;
      finalResults.modelPath = modelFile;
      classCount = length(unique(finalResults.modelLabel));
      finalResults.filterBins = length(finalResults.mus) - (classCount*conf.numClusters);
    end


    wrapperCount = wrapperCount + 1;
  end







% truth = rawGndTest(1:n:length(rawGndTest));
% x_down = rawSigTest(1:n:length(rawSigTest));
% c_down = signalClassified(1:n:length(signalClassified));
% sample_down = sample_rate/n;




  disp('filterErrStats:');
  disp(filterErrStats);



  n = -1;
  ex = 10000;
  while ex > 0
    n = n + 1;
    batchDir = sprintf('%s/err_%04d_%s_%d', conf.trialPath, round(finalResults.err*100), thisAudioFileName, n);
    % if finalResults.err < 10
    %   batchDir = sprintf('%s/err_0%d_%s_%d', conf.trialPath, round(finalResults.err*100), thisAudioFileName, n);
    % else
    %   batchDir = sprintf('%s/err_%d_%s_%d', conf.trialPath, round(finalResults.err*1000), thisAudioFileName, n);
    % end
    ex = exist(batchDir);
  end



  if ~options.disablePlotting
    f = mkdir(batchDir);
  end
  allFilterBinFile = sprintf('%s/allFiltered.jpg', conf.trialPath);

  pcaFile = sprintf('%s/pca.png', batchDir);
  graphFile = sprintf('%s/graph.png', batchDir);
  filterBinFile = sprintf('%s/filtered.jpg', batchDir);
  wrapperBinFile = sprintf('%s/wrappered.jpg', batchDir);
  allWrapperBinFile = sprintf('%s/allWrappered.jpg', conf.trialPath);
  newConfFile = sprintf('%s/conf.mat', batchDir);
  initialPrototypes = sprintf('%s/initialPrototypes.jpg', batchDir);




  classifierFeatures = conf.selectedFeatures{1};
  for f = 2:length(conf.selectedFeatures)
    classifierFeatures = [classifierFeatures '|' conf.selectedFeatures{f}];
  end
  classNumberList = sort(unique(returnData.modelLabel));
  classString = sprintf('%d', classNumberList(1));
  for classIndex = 2:length(classNumberList)
    classString = [classString '|' sprintf('%d', classNumberList(classIndex))];
  end
  if strcmp(class(finalResults.mdl), 'ClassificationKNN')
    conf.classifier = 'knn';
  elseif strcmp(class(finalResults.mdl), 'ClassificationNaiveBayes')
    conf.classifier = 'naivebayes';
  else
    conf.classifier = 'myNB';
  end
  % rmfield(finalResults, 'truth');
  % rmfield(finalResults, 'x_down');
  % rmfield(finalResults, 'c_down');
  % rmfield(finalResults, 'sample_down');

  finalResults.selectedFeatures = conf.selectedFeatures;
  finalResults.numClusters = conf.numClusters;
  finalResults.mappingType = conf.mappingType;
  classifierFile = sprintf('%s/qt_err_%04d_%s_%s_%dBins_%s.%s.mat', conf.classifierPath, round(finalResults.err*100), conf.classifier, classifierFeatures, length(finalResults.mus), classString, thisAudioFileName);

  returnData.results = finalResults;
  returnData.conf = conf;
  t2 = clock;
  returnData.time = etime(t2,t1);

  if options.disablePlotting
    return
  end

  [thisfilepath,thisfilename]=fileparts(classifierFile);
  if ~exist(thisfilepath)
    mkdir(thisfilepath);
  end
  if isfield(conf, 'saveFiles') && conf.saveFiles
    save(classifierFile, '-struct', 'finalResults');
  end
  [thisfilepath,thisfilename]=fileparts(newConfFile);
  if ~exist(thisfilepath)
    mkdir(thisfilepath);
  end

  save(newConfFile, 'conf');

  makePlotWithDown(finalResults.truth, finalResults.x_down, finalResults.c_down, finalResults.sample_down);


  % save the best classifier
  % finalClassifierDataFile = sprintf('%s/bestClassifier%s.mat', batchDir, conf.classifier);
  % finalModelDataFile = sprintf('%s/bestModel%s.mat', conf.classifierPath, conf.classifier);


  % tempconf = conf;
  % tempconf.modelknnFile = finalClassifierDataFile;
  % tempconf.modelcnbFile = finalClassifierDataFile;
  % tempconf.modelmyNBFile = finalClassifierDataFile;
  %mdl = doTrain(tempconf, finalResults);


  % comes from the test
  %saveas(gcf, graphFile);
  set(gcf,'PaperPositionMode','auto')
  print(graphFile, '-djpeg', '-r0')
  close(gcf);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% )  pca plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  clf;
  colors = {'rx' 'bx' 'gx' 'cx' 'ro' 'bo' 'go' 'co'};
  allFeatures = [];
  fields = fieldnames(finalResults.featuresByClass);
  for i = 1:numel(fields)
    allFeatures = [allFeatures; finalResults.featuresByClass.(fields{i})];
  end
  [Y Z]=pca(allFeatures);
  figure; title('PCA');
  hold on
  b = 1;
  for i = 1:numel(fields)
    e = size(finalResults.featuresByClass.(fields{i})) + b - 1;
    plot( Z(b:e,1) , Z(b:e,2) , colors{i} );
    b = e + 1;
  end

  % b = 1;
  % e = size(cls1Features);
  % plot(Z(b:e,1), Z(b:e,2), 'rx')
  % b = size(cls1Features,1)+1;
  % e = size(cls1Features,1)+size(cls2Features,1);
  % plot(Z(b:e,1), Z(b:e,2), 'bx')
  % b = size(cls1Features,1)+size(cls2Features,1)+1;
  % e = size(cls1Features,1)+size(cls2Features,1)+size(cls3Features);
  % plot(Z(b:e,1), Z(b:e,2), 'gx')
  % b = size(cls1Features,1)+size(cls2Features,1)+size(cls3Features)+1;
  % plot(Z(b:end,1), Z(b:end,2), 'cx')


  saveas(gcf, pcaFile);
  close(gcf);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% )  prototype plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



  clf;
  hold on
  stem(initialPrototypeData.modelSums');
  % stem(b2', 'Color', 'black', 'Marker', 'p');
  title(sprintf('Initial Prototype Comparison'));
  hold off
  saveas(gcf, initialPrototypes);
  close(gcf);


  for i = 1:length(filterBinTracking)
    thesePrototypes = sprintf('%s/thesePrototypes_%03d.jpg', batchDir, i);
    clf;
    hold on
    stem(filterMuTracking{i}');
    xx = filterBinTracking{i};
    yy = zeros(1,length(filterBinTracking{i}));
    h = stem(xx,yy,'filled');
    h.Color = 'black';
    h.BaseValue = 0;
    title(sprintf('This Prototype Comparison %03d', i));
    hold off
    saveas(gcf, thesePrototypes);
    close(gcf);
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% )  filtered bin plots filter method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if isfield(conf, 'filterBins') && (conf.filterBins)
    clf;
    plot(filterErrStats.filterX,filterErrStats.filterY,'-*');
    set(gca,'XTick',filterErrStats.filterX);
    xlabel('Prototype Count (after filtered)');
    ylabel('Error %');
    title('Filtered Bin Analysis (filter method)');
    saveas(gcf, filterBinFile);
    close(gcf);
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% )  filtered bin plots wrapper method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if isfield(conf, 'wrapperBins') && (conf.wrapperBins)
    clf;
    plot(wrapperErrStats.filterX,wrapperErrStats.filterY,'-*');
    set(gca,'XTick',wrapperErrStats.filterX);
    xlabel('Prototype Count (after filtered)');
    ylabel('Error %');
    title('Filtered Bin Analysis (wrapper method)');
    saveas(gcf, wrapperBinFile);
    close(gcf);
  end

  conf.whichTrainingSegment = conf.whichTrainingSegment + 1;

  allFilterErrStats.filterX = [allFilterErrStats.filterX; filterErrStats.filterX];
  allFilterErrStats.filterY = [allFilterErrStats.filterY; filterErrStats.filterY];

  allWrapperErrStats.filterX = [allWrapperErrStats.filterX; wrapperErrStats.filterX];
  allWrapperErrStats.filterY = [allWrapperErrStats.filterY; wrapperErrStats.filterY];

  % allFilterErrStats.filterX = [allFilterErrStats.filterX; filterErrStats.filterX];
  % allFilterErrStats.filterY = [allFilterErrStats.filterY; filterErrStats.filterY];

  % allWrapperErrStats.filterX = [allWrapperErrStats.filterX; wrapperErrStats.filterX];
  % allWrapperErrStats.filterY = [allWrapperErrStats.filterY; wrapperErrStats.filterY];

end




if isfield(conf, 'filterBins') && (conf.filterBins)
  clf;
  plot(allFilterErrStats.filterX(1,:), allFilterErrStats.filterY','-*');
  set(gca,'XTick',allFilterErrStats.filterX(1,:));
  xlabel('Prototype Count (after filtered)');
  ylabel('Error %');
  title('Total Filtered Bin Analysis (filter method)');
  saveas(gcf, allFilterBinFile);
  close(gcf);
end

if isfield(conf, 'wrapperBins') && (conf.wrapperBins)
  clf;
  plot(allWrapperErrStats.filterX(1,:), allWrapperErrStats.filterY','-*');
  set(gca,'XTick',allWrapperErrStats.filterX(1,:));
  xlabel('Prototype Count (after filtered)');
  ylabel('Error %');
  title('Total Filtered Bin Analysis (wrapper method)');
  saveas(gcf, allWrapperBinFile);
  close(gcf);
end





