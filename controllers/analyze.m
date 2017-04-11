function [finalResults, filterStats] = analyze(conf, classData)

initialConf = conf;

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


disp('Training...');


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


finalResults = struct;
finalResults.err = 100;

filterStats = struct;
filterStats.initialModelSums = [];
filterStats.filterX = [];
filterStats.filterY = [];

wrapperErrStats = struct;
wrapperErrStats.filterX = [];
wrapperErrStats.filterY = [];

filterStats.filterBinTracking = {};
for i = 1:filterCountMax
  filterStats.filterBinTracking{i} = [];
end
filterStats.filterMuTracking = {};
for i = 1:filterCountMax
  filterStats.filterMuTracking{i} = [];
end


modelData = getModel(conf, classData);

badIndices = [];
%initialPrototypeData = struct;

[badIndices, modelSums] = filterBins3(modelData.modelTable, modelData.modelLabel, 0); % running this just to get modelSums
filterStats.initialModelSums = modelSums;

while (filterCount <= filterCountMax) % should run at least once


  if (filterCount > 0)
    % updatedRemoveCount = conf.removeCount * (conf.filterIterations-filterCount);  % includes running with no bins removed

    % [badIndices, modelSums] = filterBins(modelTable, modelLabel, conf.varFilterThreshold);
    [badIndices, modelSums] = filterBins3(modelData.modelTable, modelData.modelLabel, conf.removeCount);
    % initialPrototypeData.modelSums = modelSums;

    filterStats.filterBinTracking{filterCount} = badIndices;
    filterStats.filterMuTracking{filterCount} = modelSums;

    modelData.modelTable(:, badIndices) = [];
    modelData.mus(badIndices, :) = [];

    fprintf(sprintf('\n\nBin iteration %d, prototype count: %d\n', filterCount, length(modelData.mus)));

  end


  doTrain(conf, modelData);

  % [signalClassified, err,    truth, x_down, c_down, sample_down,  badIndices, modelSums] = test_20161013(conf, modelData);
  [signalClassified, badIndices, modelSums] = test_20161013(conf, modelData);
  err = calculateErr(signalClassified, classData.truth);




  filterStats.filterX = [length(modelData.mus) filterStats.filterX];
  filterStats.filterY = [err filterStats.filterY];




  fprintf('\n\n\n%f is < than %f ????????', err, finalResults.err);
  if err < finalResults.err

    finalResults.err = err;
    finalResults.signalClassified = signalClassified;
    % finalResults.truth = truth;
    % finalResults.x_down = x_down;
    % finalResults.c_down = c_down;
    % finalResults.sample_down = sample_down;

    % used for wrapper filter later
    % finalResults.segLabel = segLabel;
    %finalResults.segTrain = segTrain;
    finalResults.modelTable = modelData.modelTable;
    finalResults.mus = modelData.mus;
  end

  filterCount = filterCount + 1;
end



% initialize with starting point
wrapperErrStats.filterX = [length(modelData.mus) wrapperErrStats.filterX];
wrapperErrStats.filterY = [err wrapperErrStats.filterY];


% NOTE how `badIndices` holds the worst bins of the current state


while (wrapperCount <= wrapperCountMax)

  disp(fprintf('\n\n\nWrapper iteration: %d', wrapperCount));
  % [badIndices] = filterMisClassified(segTable, segLabel, segLimits, signalClassified)

  modelData.modelTable(:, badIndices) = [];
  modelData.mus(badIndices, :) = [];

  doTrain(conf, modelData);
  % [signalClassified, err,    truth, x_down, c_down, sample_down,  segLabel, segTable, segLimits] = test_20161013(conf);
  [signalClassified, badIndices, modelSums] = test_20161013(conf, modelData);
  err = calculateErr(signalClassified, classData.truth);

  % for plotting...
  wrapperErrStats.filterX = [length(modelData.mus) wrapperErrStats.filterX];
  wrapperErrStats.filterY = [err wrapperErrStats.filterY];


  fprintf('\n\n\n%f is < than %f ????????', err, finalResults.err);
  if err < finalResults.err

    finalResults.err = err;
    finalResults.signalClassified = signalClassified;
    % finalResults.truth = truth;
    % finalResults.x_down = x_down;
    % finalResults.c_down = c_down;
    % finalResults.sample_down = sample_down;

    % used for wrapper filter later
    % finalResults.segLabel = segLabel;
    %finalResults.segTrain = segTrain;
    finalResults.modelTable = modelData.modelTable;
    finalResults.mus = modelData.mus;
  end


  wrapperCount = wrapperCount + 1;
end


disp('Analysis completed...');




% truth = rawGndTest(1:n:length(rawGndTest));
% x_down = rawSigTest(1:n:length(rawSigTest));
% c_down = signalClassified(1:n:length(signalClassified));
% sample_down = sample_rate/n;




% disp('filterStats:');
% disp(filterStats);








% save(newConfFile, 'conf');

% % comes from the test
% %saveas(gcf, graphFile);
% makePlot(finalResults.truth, finalResults.x_down, finalResults.c_down, finalResults.sample_down);
% set(gcf,'PaperPositionMode','auto')
% print(graphFile, '-djpeg', '-r0')
% close(gcf);




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % )  prototype plot
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% clf;
% hold on
% stem(initialPrototypeData.modelSums');
% % stem(b2', 'Color', 'black', 'Marker', 'p');
% title(sprintf('Initial Prototype Comparison'));
% hold off
% saveas(gcf, initialPrototypes);
% close(gcf);


% for i = 1:length(filterStats.filterBinTracking)
%   thesePrototypes = sprintf('%s/thesePrototypes_%03d.jpg', batchDir, i);
%   clf;
%   hold on
%   stem(filterStats.filterMuTracking{i}');
%   xx = filterStats.filterBinTracking{i};
%   yy = zeros(1,length(filterStats.filterBinTracking{i}));
%   h = stem(xx,yy,'filled');
%   h.Color = 'black';
%   h.BaseValue = 0;
%   title(sprintf('This Prototype Comparison %03d', i));
%   hold off
%   saveas(gcf, thesePrototypes);
%   close(gcf);
% end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % )  filtered bin plots filter method
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if isfield(conf, 'filterBins') && (conf.filterBins)
%   clf;
%   plot(filterStats.filterX,filterStats.filterY,'-*');
%   set(gca,'XTick',filterStats.filterX);
%   xlabel('Prototype Count (after filtered)');
%   ylabel('Error %');
%   title('Filtered Bin Analysis (filter method)');
%   saveas(gcf, filterBinFile);
%   close(gcf);
% end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % )  filtered bin plots wrapper method
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if isfield(conf, 'wrapperBins') && (conf.wrapperBins)
%   clf;
%   plot(wrapperErrStats.filterX,wrapperErrStats.filterY,'-*');
%   set(gca,'XTick',wrapperErrStats.filterX);
%   xlabel('Prototype Count (after filtered)');
%   ylabel('Error %');
%   title('Filtered Bin Analysis (wrapper method)');
%   saveas(gcf, wrapperBinFile);
%   close(gcf);
% end
