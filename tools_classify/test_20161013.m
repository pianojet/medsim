function [signalClassified, badIndices, modelSums] = test_20161013(conf, classifierData)
% function [signalClassified, percentError,   truth, x_down, c_down, sample_down,  badIndices, modelSums] = test_20161013(conf, modelData)
disp('tools_classify/test_20161013');
% if (nargin > 1)
%   mus = modelData.mus;
% else
%   mapping = load(conf.modelDataFile);
%   mus = mapping.mus;
% end

% if isfield(conf, 'modelClassifierFile') && ~isempty(conf.modelClassifierFile)
%   mdlData = load(conf.modelClassifierFile, 'mdl');
%   if strcmp(class(mdlData.mdl), 'ClassificationKNN')
%     conf.classifier = 'knn';
%     getClass = @getClassKnn;
%     customClassify = @predict;

%   elseif strcmp(class(mdlData.mdl), 'ClassificationNaiveBayes')
%     conf.classifier = 'naivebayes';
%     getClass = @getClassNaiveBayes;
%     customClassify = @predict;

%   end

% else
%   % load classifier model data
%   if strcmp(conf.classifier, 'knn')
%     mdlData = load(conf.modelknnFile, 'mdl');
%     getClass = @getClassKnn;
%     customClassify = @predict;
%   elseif strcmp(conf.classifier, 'naivebayes')
%     mdlData = load(conf.modelcnbFile, 'mdl');
%     getClass = @getClassNaiveBayes;
%     customClassify = @predict;
%   elseif strcmp(conf.classifier, 'myNB')
%     mdlData = load(conf.modelmyNBFile, 'mdl');
%     getClass = @getClassNaiveBayes;
%     customClassify = @myNB_getPosterior;
%   end
% end
% mdl = mdlData.mdl;




if (nargin > 1)
  mdlData = classifierData;
  if isfield(classifierData, 'selectedFeatures')
    conf.selectedFeatures = classifierData.selectedFeatures;
  end

  if isfield(classifierData, 'numClusters')
    conf.numClusters = classifierData.numClusters;
  end

  if isfield(classifierData, 'mappingType')
    conf.mappingType = classifierData.mappingType;
  end

  if isfield(classifierData, 'filterBins')
    conf.filterBins = classifierData.filterBins;
  end


elseif isfield(conf, 'modelClassifierFile') && ~isempty(conf.modelClassifierFile)
  mdlData = load(conf.modelClassifierFile, 'mdl');
  if strcmp(class(mdlData.mdl), 'ClassificationKNN')
    conf.classifier = 'knn';
    % getClass = @getClassKnn;
    % customClassify = @predict;

  elseif strcmp(class(mdlData.mdl), 'ClassificationNaiveBayes')
    conf.classifier = 'naivebayes';
    % getClass = @getClassNaiveBayes;
    % customClassify = @predict;

  else
    conf.classifier = 'myNB';
  end
end

% load classifier model data
if strcmp(conf.classifier, 'knn')
  getClass = @getClassKnn;
  customClassify = @predict;
elseif strcmp(conf.classifier, 'naivebayes')
  getClass = @getClassNaiveBayes;
  customClassify = @predict;
elseif strcmp(conf.classifier, 'myNB')
  getClass = @getClassNaiveBayes;
  customClassify = @myNB_getPosterior;
end
mdl = mdlData.mdl;
mus = mdlData.mus;



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

% determine signal from what the silence mode is
if isfield(conf, 'silenceMode') && strcmp(conf.silenceMode, 'remove')
  %signal = x(gnd(:,2) ~= 5);
  disp('silenceMode=remove  NOT IMPLEMENTED');
  signal = x;
  %signalGnd = gnd(gnd(:,2) ~= 5, :);
else
  signal = x;
  %signalGnd = gnd;
end


% mappings
badIndices = [];
modelSums = [];

% globals
sample_rate = a.SampleRate;
total_samples = a.TotalSamples; % original # samples of original signal
total_working_samples = length(signal); % number of samples after accounting for possible silence removal

bits = a.BitsPerSample;
total_segments = total_working_samples/sample_rate;
segmentAudio = {};
segmentFeatures = {};
%classCount = length(mdl.ClassNames);
classCount = conf.numClasses;
totalClusters = conf.numClusters*classCount;

scanWinSam = floor(conf.scan_wintime*sample_rate);
scanHopSam = floor(conf.scan_hoptime*sample_rate);
subSegmentSamSize = scanHopSam;
subSegmentCount = ceil(total_working_samples/subSegmentSamSize);
subSegmentCountPerWin = ceil(scanWinSam/scanHopSam);
subSegmentScores = {}; % raw signal per subsegment
subSegmentHists = {};
subSegmentLimits = {};
%subSegmentScores = zeros(subSegmentCount, classCount+1); % determined scores via `predict`
subSegmentLabels = zeros(subSegmentCount, 1); % determined classes via `predict`

postProcess = conf.postProcess;
if isstr(conf.glazeThreshold) && strcmp(conf.glazeThreshold,'hoptime')
  glazeSam = floor(conf.scan_hoptime * sample_rate);
elseif isnumeric(conf.glazeThreshold)
  glazeSam = floor(conf.glazeThreshold * sample_rate);
else
  postProcess = false;
end


%init score segs
for s = 1:subSegmentCount
  subSegmentScores{s} = [];
  subSegmentHists{s} = [];
  subSegmentLimits{s} = [];
end

% %limit_start = 1;
% for s = 1:subSegmentCount
%   % limit_end = limit_start+subSegmentSamSize;
%   % if limit_end > length(signal)
%   %   limit_end = length(signal);
%   % end
%   %subSegmentSamples{s} = signal(limit_start:limit_end);
%   subSegmentScores{s} = [];
%   subSegmentLabels{s} = 0;
% end

histOptions = struct;
if strcmp(conf.classifier, 'naivebayes') && strcmp(conf.naivebayes_DistributionNames, 'mn')
  histOptions.normalize = false;
else
  histOptions.normalize = true;
end
if isfield(conf, 'histDist')
  histOptions.distance = conf.histDist;
end


fprintf('\n\n\n######################################\nClassifying %d total windows (sub-segments)... \n', subSegmentCount);
fprintf('TIME:')
disp(clock);
fprintf('Processed Samples:\n');
signalWindows = {};
limits = [];
subSegmentIndex = 0;
txt = ' ';
allscores = [];
noFeaturesFound = [];
% for s = 1:scanHopSam:(total_working_samples+mod(total_working_samples,scanHopSam))
for s = 1:scanHopSam:total_working_samples
  for txt_i=1:size(txt,2) fprintf('\b'); end;
  txt = sprintf('%15d / %d', [s total_working_samples]);
  fprintf(txt);

  subSegmentIndex = subSegmentIndex + 1;
  limit_start = s;
  limit_end = s+scanWinSam-1;

  seg_start = subSegmentIndex;
  seg_end = seg_start+subSegmentCountPerWin-1;

  if limit_end > total_working_samples
    limit_end = total_working_samples;
  end

  if seg_end > subSegmentCount
    seg_end = subSegmentCount;
  end

  limits = [limits; [limit_start limit_end]];

  % disp([seg_start seg_end]);
  % disp([limit_start limit_end]);

  signal_window = signal(limit_start:limit_end);
  features = getFeatures(signal_window, sample_rate, conf.selectedFeatures, featExtOptions);

  if isempty(features) || (size(features,2) ~= size(mus,2))
    warning('Bad features size, continuing...');
    continue;
  end

  % if size(features,1) > 0
  %   norm_hist = getHist(features, mus, conf.mappingType, histOptions);
  % else
  %   noFeaturesFound = [noFeaturesFound; [limit_start limit_end]];
  %   norm_hist = zeros(1,totalClusters);
  % end
  norm_hist = getHist(features, mus, conf.mappingType, histOptions);
  [label, score] = customClassify(mdl, norm_hist);
  allscores = [allscores; score];
  for scoreSeg = seg_start:seg_end
    subSegmentLimits{scoreSeg} = [subSegmentLimits{scoreSeg}; limit_start limit_end];
    subSegmentScores{scoreSeg} = [subSegmentScores{scoreSeg}; [score label]];
    subSegmentHists{scoreSeg} = [subSegmentHists{scoreSeg}; norm_hist];
  end
  %subSegmentScores(seg_start:seg_end, :) = repmat([score label], seg_end-seg_start+1, 1);
  subSegmentLabels(seg_start:seg_end) = repmat(label, seg_end-seg_start+1, 1);

  % disp([limit_start limit_end]);
end

if length(noFeaturesFound) > 0
  fprintf('NO FEATURES FOUND for %d segments', size(noFeaturesFound, 1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% )  TEST: map segment results to initial signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n######################################\nReferencing back to audio...\n');
fprintf('TIME:')
disp(clock);
signalClassified = [];

if isfield(conf, 'topThreshold') getClassOptions.topThreshold = conf.topThreshold; else getClassOptions.topThreshold = 0; end;
if isfield(conf, 'midThreshold') getClassOptions.midThreshold = conf.midThreshold; else getClassOptions.midThreshold = 0; end;

for i = 1:subSegmentCount
  %c = subSegmentLabels(i);
  s = subSegmentScores{i};
  c = getClass(s, getClassOptions);

  sizeSoFar = size(signalClassified,1);
  augToSize = limits(i,2);
  augThisMuch = augToSize - sizeSoFar;

  dataToAug = c * ones(augThisMuch,1);
  % else
  %   dataToAug = zeros(augThisMuch,1);
  % end
  signalClassified = [signalClassified; dataToAug];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% if conf.postProcess
%   fprintf('\n\n######################################\nPost-processing...\n');
%   fprintf('TIME:')
%   disp(clock);
%   fprintf('Processed Samples:\n');
%   signalClassifiedBackup = signalClassified;
%   r = signalClassified;
%   limit_start = glazeSam+1;
%   postProcessingEnd = (length(r)-(glazeSam*2)+1);
%   txt = ' ';
%   for i = (glazeSam+1):glazeSam:postProcessingEnd
%     for txt_i=1:size(txt,2) fprintf('\b'); end;
%     txt = sprintf('%15d / %d', [i postProcessingEnd]);
%     fprintf(txt);
%     limit_end = i+glazeSam-1;

%     big_start = limit_start-glazeSam;
%     big_end = limit_end+glazeSam;


%     pre = mode(r(big_start:limit_start-1));
%     ll = mode(r(limit_start:limit_end));
%     post = mode(r(limit_end+1:big_end));

%     % fprintf('\n\n\n\n%d: [ %d  [ %d - %d ]  %d ]\n', i, big_start, limit_start, limit_end, big_end);
%     % fprintf('       [ %d  [ %d ]  %d ]\n', pre, ll, post);
%     % fprintf('old r:  ');
%     % fprintf('%d', r(big_start:limit_start-1)');
%     % fprintf(' ');
%     % fprintf('%d', r(limit_start:limit_end)');
%     % fprintf(' ');
%     % fprintf('%d', r(limit_end+1:big_end)');
%     % fprintf('\n');

%     if (pre == post && ll ~= pre) || (ll ~= pre && ll ~= post && pre ~= post)
%       % disp('Equating to pre...');
%       r(limit_start:limit_end) = repmat(pre, (limit_end - limit_start + 1), 1);
%     elseif (length(unique(r(limit_start:limit_end))) > 1 && ...
%       ((r(limit_start) == ll && r(limit_end) == ll)  ||  ...
%         (r(limit_start) ~= ll && r(limit_start) ~= pre)  || ...
%         (r(limit_end) ~= ll && r(limit_end) ~= post)))


%       % disp('Equating to mode...');
%       r(limit_start:limit_end) = repmat(ll, (limit_end - limit_start + 1), 1);
%     end

%     % fprintf('new r:  ');
%     % fprintf('%d', r(big_start:limit_start-1)');
%     % fprintf(' ');
%     % fprintf('%d', r(limit_start:limit_end)');
%     % fprintf(' ');
%     % fprintf('%d', r(limit_end+1:big_end)');
%     % fprintf('\n');


%     % w = r(limit_start:limit_end);
%     limit_start = limit_end+1;
%   end
%   signalClassified = r;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n######################################\nPlotting...\n');
fprintf('TIME:')
disp(clock);
% rawGndTest = signalGnd;
% rawSigTest = signal;






% n = 10;
% truth = rawGndTest(1:n:length(rawGndTest));
% x_down = rawSigTest(1:n:length(rawSigTest));
% c_down = signalClassified(1:n:length(signalClassified));
% sample_down = sample_rate/n;




% comparison = truth==c_down; %comparison = comparison.*x_down;

% errorCount = sum(comparison==0);
% percentError = (errorCount/length(comparison))*100;
% percentCorrect = 100-percentError;

% % percentCorrectNotUnknown = 100-errCalcNotUnknown;
% disp(sprintf('Error Percent: %%%3.2f', percentError));



%%%%%%%%% GET SEGTRUTH %%%%%%%%%%
%   (subSegmentCount, rawGndTest, subSegmentLimits)

% if subSegment score error is worse than whole percent error, return the indices to remove
if isfield(conf, 'wrapperBins') && (conf.wrapperBins)

  gnd = load(conf.truthFile);
  gnd = gnd.g;

  if size(gnd,2) > 1
    signalGnd = gnd(:,2);
  else
    signalGnd = gnd;
  end

  percentError = calculateErr(signal, signalGnd);

  nixModelTable = [];
  nixModelLabel = [];
  nixRemoveCount = conf.wrapperRemoveCount;

  for i = 1:subSegmentCount
    subSegmentTest = signalClassified(subSegmentLimits{i}(1):subSegmentLimits{i}(2));
    subSegmentTruth = rawGndTest(subSegmentLimits{i}(1):subSegmentLimits{i}(2));

    comparison = subSegmentTruth==subSegmentTest;
    subSegmentError = sum(comparison==0);

    subSegmentErrorPct = (subSegmentError/length(comparison))*100;
    if subSegmentErrorPct >= percentError
      s = size(subSegmentHists{i});
      nixModelTable = [nixModelTable; subSegmentHists{i}];
      nixModelLabel = [nixModelLabel; ones(s(1),1) .* subSegmentLabels(i)];
    end

  end

  [badIndices, modelSums] = filterBins3(nixModelTable, nixModelLabel, nixRemoveCount);
end







% segLabel = subSegmentLabels;
% segTable = subSegmentHists;
% segLimits = subSegmentLimits;

