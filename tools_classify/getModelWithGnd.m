function modelData = getModelWithGnd(conf)
disp('scratch getModel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Data Loading & Configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % config
% pathconf = loadConfig('/Users/justin/Documents/MATLAB/scratch/path_config.ini');
% conf = loadConfig('/Users/justin/Documents/MATLAB/scratch/medsim_config.ini');
% if isstr(conf.selectedFeatures)
%   conf.selectedFeatures = {conf.selectedFeatures};
% end
% conf.classPath = pathconf.classPath;
% conf.audioPath = pathconf.audioPath;
% conf.truthPath = pathconf.truthPath;
% conf.extractedForTestPath = pathconf.extractedForTestPath;
% conf.metaPath = pathconf.metaPath;
% conf.graphDir = pathconf.graphDir;
% conf.mappingPath = pathconf.mappingPath;
% conf.modelknnPath = pathconf.modelknnPath;
% conf.modelcnbPath = pathconf.modelcnbPath;
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

x = audioread(conf.audioFile);
a = audioinfo(conf.audioFile);
gnd = load(conf.truthFile);
gnd = gnd.g;

if size(gnd,2) > 1
  signal = x(gnd(:,2) ~= 5);
  signalGnd = gnd(gnd(:,2) ~= 5, 2);
else
  signal = x(gnd(:) ~= 5);
  signalGnd = gnd(gnd(:) ~= 5);
end
% g = signalGnd(:,2);

trainPartition = conf.trainPartition;
whichTrainingSegment = conf.whichTrainingSegment;

classLabels = {};
classCount = length(unique(signalGnd));
continuousClassSignals = struct;
classSampleCounts = struct;
featuresByClass = {};

sample_rate = a.SampleRate;
total_samples = a.TotalSamples; % original # samples of original signal
total_working_samples = length(signal); % number of samples after accounting for possible silence removal

scanWinSam = floor(conf.scan_wintime*sample_rate);
scanHopSam = floor(conf.scan_hoptime*sample_rate);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  group up continuous audio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for c = 1:classCount
  label = sprintf('class%d', c);
  classLabels{c} = label;
  continuousClassSignals.(label) = {};
  classSampleCounts.(label) = 0;
  featuresByClass{c} = [];
end


segmentCount = 1;
limit_start = 1;
currentClass = signalGnd(1);
for i = 1:length(signalGnd)
  if signalGnd(i) ~= currentClass
    limit_end = i-1;
    thisSegment = signal(limit_start:limit_end);
    thisSetSize = length(continuousClassSignals.(classLabels{currentClass}));
    continuousClassSignals.(classLabels{currentClass}){thisSetSize+1} = thisSegment;
    classSampleCounts.(classLabels{currentClass}) = classSampleCounts.(classLabels{currentClass}) + length(thisSegment);
    currentClass = signalGnd(i);
    limit_start = i;
  end
end
limit_end = length(signalGnd);
thisSegment = signal(limit_start:limit_end);
thisSetSize = length(continuousClassSignals.(classLabels{currentClass}));
continuousClassSignals.(classLabels{currentClass}){thisSetSize+1} = thisSegment;
classSampleCounts.(classLabels{currentClass}) = classSampleCounts.(classLabels{currentClass}) + length(thisSegment);
% save(conf.extractedForTestPath, '-struct', 'continuousClassSignals');
% save(conf.metaPath, '-struct', 'classSampleCounts');





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  extract features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = [];
sigmas = [];
mus = [];
all_C = [];
all_Idx = [];
featuresByClass = {};

for c = 1:classCount
  featuresByClass{c} = [];
  fprintf('\n\n####  Class %d  ####\n', c);

  theseSignals = [];
  label = sprintf('class%d', c);
  % label = 'class1';
  trainingSize = floor(classSampleCounts.(label) * trainPartition);

  % set start limit and segments
  currentSignal = 1;
  limit_start = (trainingSize * whichTrainingSegment) - trainingSize + 1;
  fprintf('\nlimit_start set to %d\n', limit_start);
  while limit_start > length(continuousClassSignals.(label){currentSignal});
    limit_start = limit_start - length(continuousClassSignals.(label){currentSignal});
    currentSignal = currentSignal + 1;
  end
  fprintf('\nlimit_start set to %d\n', limit_start);

  pulledSamples = 0;
  %limit_end = limit_start + trainingSize - 1;
  whatsLeft = trainingSize;
  %whatsLeft = limit_start + trainingSize - 1;


  totalFeaturesForThisClass = [];
  featuresByClassCount = 1;
  fprintf('Extracting training data of %d samples, starting with currentSignal %d, limit_start %d\n, whatsLeft %d, scanHopSam %d, scanWinSam %d\n', trainingSize, currentSignal, limit_start, whatsLeft, scanHopSam, scanWinSam);
  while (whatsLeft + limit_start - 1) > length(continuousClassSignals.(label){currentSignal})
    fprintf('pulling currentSignal %d,  %d - %d\n', currentSignal, limit_start, length(continuousClassSignals.(label){currentSignal}))
    thisSignal = continuousClassSignals.(label){currentSignal}(limit_start:end);


    for i = 1:scanHopSam:length(thisSignal)
      win_start = i;
      win_end = i + scanWinSam - 1;
      if win_end > length(thisSignal)
        win_end = length(thisSignal);
      end
      thisSegmentClip = thisSignal(win_start:win_end);

      segmentFeatures = ExtractMultipleFeatures(thisSegmentClip, sample_rate, conf.selectedFeatures, featExtOptions);
      seg = [];
      for f = 1:length(conf.selectedFeatures)
        seg = [seg segmentFeatures.(conf.selectedFeatures{f})];
      end

      % featuresByClass{c}{featuresByClassCount} = seg;
      totalFeaturesForThisClass = [totalFeaturesForThisClass; seg];
      % featuresByClassCount = featuresByClassCount + 1;
    end

    currentSignal = currentSignal + 1;
    limit_start = 1;
    whatsLeft = whatsLeft - length(thisSignal);
    previousSignals = 0;
    fprintf('new currentSignal = %d, limit_start = %d, whatsLeft = %d\n', currentSignal, limit_start, whatsLeft);



  end

  whatsLeft = limit_start+whatsLeft-1;
  fprintf('(last pull) pulling currentSignal %d,  %d - %d\n', currentSignal, limit_start, whatsLeft);
  thisSignal = continuousClassSignals.(label){currentSignal}(limit_start:whatsLeft);


  for i = 1:scanHopSam:length(thisSignal)
    win_start = i;
    win_end = i + scanWinSam - 1;
    if win_end > length(thisSignal)
      win_end = length(thisSignal);
    end
    thisSegmentClip = thisSignal(win_start:win_end);

    segmentFeatures = ExtractMultipleFeatures(thisSegmentClip, sample_rate, conf.selectedFeatures, featExtOptions);
    seg = [];
    for f = 1:length(conf.selectedFeatures)
      seg = [seg segmentFeatures.(conf.selectedFeatures{f})];
    end

    % featuresByClass{c}{featuresByClassCount} = seg;
    totalFeaturesForThisClass = [totalFeaturesForThisClass; seg];
    % featuresByClassCount = featuresByClassCount + 1;
  end

  [ctrs, U] = fcm(totalFeaturesForThisClass, conf.numClusters, [2.0]);
  mus = [mus; ctrs];

  featuresByClass{c} = totalFeaturesForThisClass;
end


% featuresByClass{c} = {};
% featuresPerSecond = floor(1 / (conf.feature_hoptime));
% for c = 1:classCount
%   for i = 1:length(featuresByClass{c})
%     if
%   end
% end

segsByClass = {};



% get observations
modelTable = [];
modelLabel = [];

histOptions = struct;
if strcmp(conf.classifier, 'naivebayes') && strcmp(conf.naivebayes_DistributionNames, 'mn')
  histOptions.normalize = false;
else
  histOptions.normalize = true;
end



fprintf('\n\nGetting observation segments:\n')
for c = 1:classCount
  segsByClass{c} = {};
  % segCount = 1;
  fprintf('\n####  Class %d:\n', c);
  txt = ' ';
  featuresPerSecond = floor(1 / (conf.feature_hoptime));
  limit_start = 1;
  numSegs = ceil(length(featuresByClass{c})/featuresPerSecond);
  for i = 1:numSegs
    for txt_i=1:size(txt,2) fprintf('\b'); end;
    txt = sprintf('%15d / %d', [i numSegs]);
    fprintf(txt);

    limit_end = featuresPerSecond*i;
    if limit_end > length(featuresByClass{c})
      limit_end = length(featuresByClass{c});
    end

    % segsByClass{c}{i} = featuresByClass{c}(limit_start:limit_end,:);
    seg = featuresByClass{c}(limit_start:limit_end,:);
    % histsByClass{c}{i} = getHist(segsByClass{c}{i}, mus, conf.mappingType);
    % segCount = segCount + 1;
    voteHist = getHist(seg, mus, conf.mappingType, histOptions);
    modelTable = [modelTable; voteHist];
    modelLabel = [modelLabel; c];

    limit_start = limit_end + 1;
  end
end

fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% )  NEW TRAIN: filter out useless bins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


modelData = struct;
modelData.mus = mus;
modelData.sigmas = sigmas;
modelData.modelTable = modelTable;
modelData.modelLabel = modelLabel;
% save the models

save(conf.modelDataFile, '-struct', 'modelData');


disp('Models processed.');
