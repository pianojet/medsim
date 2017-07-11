function classFeatures = getFeaturesFromFile(signalFileName, truthFileName, options)
% options:
%   options.interval           seconds of audio to extract from file
%   options.selectedFeatures   cell-array of feature names to extract

signalFileName = '/Users/justin/Documents/_SONATA_VOLUME_04.wav';
truthFileName = '/Users/justin/Documents/_SONATA_VOLUME_04_gnd.mat';
options.interval = 10;
options.selectedFeatures = {'melfcc'};


melfccOpt = struct;
melfccOpt.feature_wintime = 0.0650;
melfccOpt.feature_hoptime = 0.0100;
melfccOpt.feature_numcep = 12;
melfccOpt.feature_lifterexp = 0.2014;
melfccOpt.feature_sumpower = 4;
melfccOpt.feature_preemph = 0.5611;
melfccOpt.feature_dither = 0;
melfccOpt.feature_minfreq = 32;
melfccOpt.feature_maxfreq = 691;
melfccOpt.feature_nbands = 17;
melfccOpt.feature_bwidth = 0.5924;
melfccOpt.feature_dcttype = 3;
melfccOpt.feature_fbtype = 'bark';
melfccOpt.feature_usecmp = 0;




signal = audioread(signalFileName);
audioInfo = audioinfo(signalFileName);
gnd = load(truthFileName);
gnd = gnd.g;

signal = signal(gnd < 100);
signalGnd = gnd(gnd < 100);


% group up class audio (skipped doing separated continuous segments)
numSamples = audioInfo.SampleRate * options.interval;
classLabelStr = 'class%d';
classNumbers = unique(signalGnd);
classSignals = struct;
for c = classNumbers'
  label = sprintf(classLabelStr, c);
  allsamples = signal(signalGnd == c);
  if length(allsamples) > numSamples
    classSignals.(label) = allsamples(1:numSamples);
  else
    classSignals.(label) = allsamples;
  end
end

% get features
classFeatures = struct;
for c = classNumbers'
  label = sprintf(classLabelStr, c);
  classFeatures.(label) = getFeatures(signal, audioInfo.SampleRate, options.selectedFeatures, melfccOpt);
end


