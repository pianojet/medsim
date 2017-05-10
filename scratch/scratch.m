audioPath = '/Users/justin/Documents/MATLAB/medsim_analysis/data/med4/Med4.wav';
truthPath = '/Users/justin/Documents/MATLAB/medsim_analysis/data/med4/Med4_gndbysam.mat';


x = audioread(audioPath);
gnd = load(truthPath);
gnd = gnd.g;

signal = x(gnd(:,2) ~= 5);
signalGnd = gnd(gnd(:,2) ~= 5, :);
g = signalGnd(:,2);


classLabels = {};
continuousClassSignals = struct;
classSampleCounts = struct;



for c = 1:length(unique(g))
  label = sprintf('class%d', c);
  classLabels{c} = label;
  continuousClassSignals.(label) = {};
  classSampleCounts.(label) = 0;
end


segmentCount = 1;
limit_start = 1;
currentClass = g(1);
for i = 1:length(g)
  if g(i) ~= currentClass
    limit_end = i-1;
    thisSegment = signal(limit_start:limit_end);
    thisSetSize = length(continuousClassSignals.(classLabels{currentClass}));
    continuousClassSignals.(classLabels{currentClass}){thisSetSize+1} = thisSegment;
    classSampleCounts.(classLabels{currentClass}) = classSampleCounts.(classLabels{currentClass}) + length(thisSegment);
    currentClass = g(i);
    fprintf('Changed class to %d\n', currentClass);
    limit_start = i;
  end
end
limit_end = length(g);
thisSegment = signal(limit_start:limit_end);
thisSetSize = length(continuousClassSignals.(classLabels{currentClass}));
continuousClassSignals.(classLabels{currentClass}){thisSetSize+1} = thisSegment;
classSampleCounts.(classLabels{currentClass}) = classSampleCounts.(classLabels{currentClass}) + length(thisSegment);







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% audioPath=/Users/justin/Documents/MATLAB/medsim_analysis/data/med4/Med4.wav
% truthPath=/Users/justin/Documents/MATLAB/medsim_analysis/data/med4/Med4_gndbysam.mat
% extractedForTestPath=/Users/justin/Documents/MATLAB/medsim/data/med4/Med4_extractedForTest.mat
% metaPath=/Users/justin/Documents/MATLAB/medsim/data/med4/Med4_meta.mat

audioPath='/Users/justin/Documents/MATLAB/medsim_analysis/data/med4/Med4_5m.wav';
truthPath='/Users/justin/Documents/MATLAB/medsim_analysis/data/med4/Med4_5m_gndbysam.mat';

limit_start = 1;
limit_end = a.SampleRate*60*5;

new_x = x(limit_start:limit_end);
g = gnd(limit_start:limit_end,:);

save(truthPath, 'g');
audiowrite(audioPath, new_x, a.SampleRate);











thisSegment = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11;];
scanHopSam = 2;
scanWinSam = 4;


for i = 1:scanHopSam:length(thisSegment)
  win_start = i;
  win_end = i + scanWinSam - 1;
  if win_end > length(thisSegment)
    win_end = length(thisSegment);
  end
  x = thisSegment(win_start:win_end);
  fprintf('win_start %d, win_end %d\n', win_start, win_end);
  disp(x);
end









featuresByClass =

    [1776x12 double]    [2386x12 double]    [227x12 double]    [720x12 double]



featuresByClass =

    [928x12 double]    [1287x12 double]    [139x12 double]    [390x12 double]



















% config
pathconf = loadConfig('/Users/justin/Documents/MATLAB/scratch/path_config.ini');
conf = loadConfig('/Users/justin/Documents/MATLAB/scratch/medsim_config.ini');
if isstr(conf.selectedFeatures)
  conf.selectedFeatures = {conf.selectedFeatures};
end
conf.classPath = pathconf.classPath;
conf.audioPath = pathconf.audioPath;
conf.truthPath = pathconf.truthPath;
conf.extractedForTestPath = pathconf.extractedForTestPath;
conf.metaPath = pathconf.metaPath;
conf.modelknnPath = pathconf.modelknnPath;
conf.modelcnbPath = pathconf.modelcnbPath;


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



x = audioread(conf.audioPath);
a = audioinfo(conf.audioPath);
gnd = load(conf.truthPath);
gnd = gnd.g;

signal = x(gnd(:,2) ~= 5);
signalGnd = gnd(gnd(:,2) ~= 5, 2);




















%%%%%

% x = audio signal
% a = audio info
% conf = configuration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Data Loading & Configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % config
% conf = loadConfig('/Users/justin/Documents/MATLAB/medsim/config/scan_config_20160912.ini');
% if isstr(conf.selectedFeatures)
%   conf.selectedFeatures = {conf.selectedFeatures};
% end

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

% % audio
% a = audioinfo(conf.audioPath);
% x = audioread(conf.audioPath);

% % ground truth
% gnd = load(conf.truthPath);
% gnd = gnd.g;

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

% load classifier model data
if strcmp(conf.classifier, 'knn')
  mdlData = load(conf.modelknnPath, 'mdl');
  getClass = @getClassKnn;
elseif strcmp(conf.classifier, 'naivebayes')
  mdlData = load(conf.modelcnbPath, 'mdl');
  getClass = @getClassNaiveBayes;
end
mdl = mdlData.mdl;

% mappings
% mapping = load(conf.mappingPath);
% mus = mapping.mus;
% sigmas = mapping.sigmas;

% globals
sample_rate = a.SampleRate;
total_samples = a.TotalSamples; % original # samples of original signal
total_working_samples = length(signal); % number of samples after accounting for possible silence removal

bits = a.BitsPerSample;
total_segments = total_working_samples/sample_rate;
segmentAudio = {};
segmentFeatures = {};
classCount = length(mdl.ClassNames);
totalClusters = conf.numClusters*classCount;

scanWinSam = floor(conf.scan_wintime*sample_rate);
scanHopSam = floor(conf.scan_hoptime*sample_rate);
subSegmentSamSize = scanHopSam;
subSegmentCount = ceil(total_working_samples/subSegmentSamSize);
subSegmentCountPerWin = ceil(scanWinSam/scanHopSam);
subSegmentScores = {}; % raw signal per subsegment
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



fprintf('\n\n\n######################################\nClassifying %d total windows (sub-segments)... \n', subSegmentCount);
fprintf('TIME:')
disp(clock);
fprintf('Processed Samples:\n');
limits = [];
subSegmentIndex = 0;
txt = ' ';
% for s = 1:scanHopSam:(total_working_samples+mod(total_working_samples,scanHopSam))
for s = 1:scanHopSam:total_working_samples
  for txt_i=1:size(txt,2) fprintf('\b'); end;
  txt = sprintf('%15d / %d', [s total_working_samples]);
  fprintf(txt);

  subSegmentIndex = subSegmentIndex + 1;
  limit_start = s;
  limit_end = s+scanHopSam-1;

  seg_start = subSegmentIndex;
  seg_end = seg_start+subSegmentCountPerWin-1;

  if limit_end > total_working_samples
    limit_end = total_working_samples;
  end

  if seg_end > subSegmentCount
    seg_end = subSegmentCount;
  end

  limits = [limits; [limit_start limit_end]];

  signal_window = signal(limit_start:limit_end);
  features = getFeatures(signal_window, sample_rate, conf.selectedFeatures, featExtOptions);
  mus = getMus(features, classCount, conf.numClusters);
  norm_hist = getHist(features, mus, conf.mappingType);
  [label, score] = predict(mdl, norm_hist);
  for scoreSeg = seg_start:seg_end
    subSegmentScores{scoreSeg} = [subSegmentScores{scoreSeg}; [score label]];
  end
  %subSegmentScores(seg_start:seg_end, :) = repmat([score label], seg_end-seg_start+1, 1);
  subSegmentLabels(seg_start:seg_end) = repmat(label, seg_end-seg_start+1, 1);

  % disp([limit_start limit_end]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% )  TEST: map segment results to initial signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n######################################\nReferencing back to audio...\n');
fprintf('TIME:')
disp(clock);
signalClassified = [];
for i = 1:subSegmentCount
  %c = subSegmentLabels(i);
  s = subSegmentScores{i};
  c = getClass(s, conf.topPosteriorThreshold);

  sizeSoFar = size(signalClassified,1);
  augToSize = limits(i,2);
  augThisMuch = augToSize - sizeSoFar;

  dataToAug = c * ones(augThisMuch,1);
  % else
  %   dataToAug = zeros(augThisMuch,1);
  % end
  signalClassified = [signalClassified; dataToAug];
end






















sample_rate = 22050;
conf.feature_hoptime = 0.0100;







seconds = floor(totalFeatureSize/featuresPerSecond);








totalFeatureSize = size(totalFeaturesForThisClass,1);
descriptorLength = size(totalFeaturesForThisClass,2);
featuresPerSecond = ceil(1 / (conf.feature_hoptime))
lastSecond = mod(totalFeatureSize, featuresPerSecond);
rowCounts = repmat(featuresPerSecond, 1, floor(totalFeatureSize/featuresPerSecond));

if lastSecond
  rowCounts = [rowCounts lastSecond];
end

colCounts = repmat(descriptorLength, 1, length(rowCounts));



C = mat2cell(totalFeaturesForThisClass, rowCounts, colCounts);






class1 = x(gnd(:,2) == 1);
class2 = x(gnd(:,2) == 2);
class3 = x(gnd(:,2) == 3);
class4 = x(gnd(:,2) == 4);

newclass1 = class1(1:(22050*15));
newclass2 = class2(1:(22050*15));
newclass3 = class3(1+50000:(22050*10)+50000);
newclass4 = class4(1+500000:(22050*10)+500000);

newsignal = [newclass1; newclass2; newclass3; newclass4];
audiowrite(audioPath, newsignal, 22050);

gg.g = ones(330750, 1);
gg.g = [gg.g; 2*ones(330750, 1)];
gg.g = [gg.g; 3*ones(220500, 1)];
gg.g = [gg.g; 4*ones(220500, 1)];

audioPath='/Users/justin/Documents/MATLAB/medsim_analysis/data/med4/Med4_mashup.wav';
truthPath='/Users/justin/Documents/MATLAB/medsim_analysis/data/med4/Med4_mashup_gndbysam.mat';

save(truthPath, '-struct', 'gg');

loadgg = load(truthPath);












norm_hist = modelTable(1,:);
[label, score] = predict(mdl, norm_hist);


load hospital
hospital.Weight = modelTable(:,1);

pd_kernel = fitdist(hospital.Weight,'Kernel')
x = 1:1:200;
pdf_kernel = pdf(pd_kernel,x);
plot(x,pdf_kernel,'Color','b','LineWidth',2);

% tt = modelTable(:,1);
% xx = 1:1:length(tt);
% ff = fitdist(tt,'Kernel', 'BandWidth', 5, 'Kernel', 'normal');
% ff = fitdist(tt,'Kernel');
% pdf_ff = pdf(ff, xx);
% plot(xx,pdf_ff, 'Color','b');
% hold on;
% plot(xx,tt, 'Color','r');
% hold off;






length(modelLabel) / size(modelLabel(modelLabel == 4), 1)




norm_hist = modelTable(1,:);
[label, score] = predict(mdl, norm_hist);


pd_kernel = fitdist(modelTable(:,1),'Kernel')
x = 0:0.0001:1;
pdf_kernel = pdf(pd_kernel,x);
plot(x,pdf_kernel,'Color','b','LineWidth',2);




class4Sum = sum(modelTable(31:40,:));

temp_hist = class4Sum;
norm_hist = [];
v = temp_hist;
sum_v = sum(v);

normalized = [];
for c = 1:size(v,2)
  n = v(c)/sum_v;
  normalized = [normalized n];
end
norm_hist = normalized;

newModelTable = [newModelTable; norm_hist];




newModelLabel = [1; 2; 3; 4];
mdl = fitcnb(newModelTable, newModelLabel, 'DistributionNames','kernel', 'Kernel','normal');

save(conf.modelcnbPath,'mdl');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


mdl = fitcnb(modelTable, modelLabel, 'DistributionNames','kernel', 'Kernel','normal');


t = subSegmentHists{1};
[label, score] = predict(mdl, t)




for i = 1:length(subSegmentHists)
  t = subSegmentHists{i};
  [label, score] = predict(mdl, t)
end





hold on; stem(subSegmentHists{3}(1,:), 'Color', 'red'); stem(subSegmentHists{3}(2,:), 'Color', 'blue'); hold off;






model1 = modelTable(3,:);
model2 = modelTable(16,:);
model3 = modelTable(32,:);
model4 = modelTable(42,:);

newModelTable = [model1; model2; model3; model4];
newModelLabel = [1; 2; 3; 4];
mdl = fitcnb(newModelTable, newModelLabel, 'DistributionNames','kernel', 'Kernel','normal');
save(conf.modelcnbPath,'mdl');



mystem(subSegmentHists{1})






src='/Users/justin/Documents/MATLAB/medsim/data/med9/Med9_gndbysam.mat';


%%%%

fprintf('\n####  testing:\n');
txt = ' ';
featuresPerSecond = floor(1 / (conf.feature_hoptime));
limit_start = 1;
numSegs = 10000;
for i = 1:numSegs
  for txt_i=1:size(txt,2) fprintf('\b'); end;
  txt = sprintf('%15d / %d', [i numSegs]);
  fprintf(txt);
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aa = [2 2 3 3 4 4 5 5; 22 33 44 22 33 44 55 55; 100 100 100 100 100 100 100 100];

aa = [1 10 100; 5 50 500; 10 100 5];







distSums = dist(sums);






classRanges{1} = [9 8 1 1 1 5 1 1; 9 9 1 2 1 5 1 1];
classRanges{2} = [1 1 9 9 1 5 1 1; 1 1 8 9 1 5 1 1];
classRanges{3} = [1 1 2 2 9 5 1 1; 1 1 0 1 9 5 1 1];
classRanges{4} = [1 1 2 2 1 5 8 8; 1 1 1 1 1 5 8 9];


modelTable = [9 9 1 1 1 5 1 1; 9 9 1 1 1 5 1 1; 1 1 9 9 1 5 1 1; 1 1 9 9 1 5 1 1];
modelTable = [modelTable; [1 1 1 1 9 5 1 1; 1 1 1 1 9 5 1 1; 1 1 1 1 1 5 9 9; 1 1 1 1 1 5 9 9]];
modelLabel = [1;1;2;2;3;3;4;4];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


stem(returnData.modelSums');

r1 = returnData.modelSums;
b1 = returnData.badIndices;
xx = zeros(4,120);
xx(:,b1) = 1;

b2 = r1 .* xx;


% r1 = returnData.modelSums;
% r1(setdiff(1:end,returnData.badIndices)) = 0;
% xx = zeros(4,120) + r1;


hold on
stem(returnData.modelSums');
stem(b2', 'Color', 'black', 'Marker', 'p');
hold off








tol = 3;
withinTol = @(x, y) (abs(x-y) <= tol);



c1 = [1; 1; 20; 1];















modelTable = conf.override.modelTable;
modelLabel = conf.override.modelLabel;

[badIndices] = filterMisClassified(conf.override.modelTable, conf.override.modelLabel, wrapperUpdatedRemoveCount);






theseErrStats.filterX = [120 115];
theseErrStats.filterY = [10.3 11.4];
plot(theseErrStats.filterX,theseErrStats.filterY);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


modelTable = [9 9 1 1 1 5 1 1; 9 9 1 1 1 5 1 1; 1 1 9 9 1 5 1 1; 1 1 9 9 1 5 1 1];
modelTable = [modelTable; [1 1 1 1 9 5 1 1; 1 1 1 1 9 5 1 1; 1 1 1 1 1 5 9 9; 1 1 1 1 1 5 9 9]];
modelLabel = [1;1;2;2;3;3;4;4];
removeCount = 3;


col = [1;1;1;1;9;9;1;1;];
modelTable = [modelTable; col];


[badIndices, sums] = filterBins2(modelTable, modelLabel, removeCount);


v = sums(:,5);
max(max(squareform(pdist(v))))



%%%% entropy





hold on;
stem(filterMuTracking{1}');
xx = filterBinTracking{1};
yy = zeros(1,length(filterBinTracking{1}));
h = stem(xx,yy,'filled');
h.Color = 'black';
h.BaseValue = 0;
hold off;

xx(filterBinTracking{1}) = 1;

h.Color = 'black';

% stem();
% stem(b2', 'Color', 'black', 'Marker', 'p');
title(sprintf('This Prototype Comparison'));








mt = returnData.modelTable;
ml = returnData.modelLabel;

protoIndex = 1;
mtx = mt(:,protoIndex);
[IDX, D] = knnsearch(mtx,mtx,'K',11);

obs = 1;
xx = IDX(obs,1:end); % omit first since it will be 0 (distance to itself)
for c = 1:length(xx)
  xx(c) = ml(xx(c));
end
yy = unique(ml)';
counts = hist(xx,yy);
rangeCount = max(counts) - min(counts);






hold on;
xx = IDX(1,1:end);  % to plot close values


hold on;
yy = zeros(1,length(xx));
stem(mtx);
h = stem(xx,yy,'filled');
h.Color = 'black';
h.BaseValue = 0;
hold off;








xx = IDX(obs,2:end); % omit first since it will be 0 (distance to itself)
for c = 1:length(xx)
  xx(c) = ml(xx(c));
end
yy = unique(ml)';
counts = hist(xx,yy);
rangeCount = max(counts) - min(counts);

max(squareform(pdist(h')))



h = [3 4 3 3];
max(squareform(pdist(h')))
min(squareform(pdist(h')))

h = [6 4 3 0];
mmax = max(squareform(pdist(h')))
mmin = min(squareform(pdist(h')))





counts = [4 3 3 3];
rangeCount = max(counts) - min(counts)





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(handles.classlist, 'String', {1,2,3,4});














audioPath = '/Users/justin/Documents/MATLAB/medsim/data/emotion/raw/emo_verbal_unnorm_100pct.wav';
truthPath = '/Users/justin/Documents/MATLAB/medsim/data/emotion/raw/emo_verbal_unnorm_100pct_gnd.mat';
x = audioread(audioPath);
a = audioinfo(audioPath);

mp = 437406;
tot = 781824; % a.TotalSamples

class1 = ones(mp, 1);
class2 = 2*ones((tot-mp), 1);
gnd.g = [class1; class2];
save(truthPath, '-struct', 'gnd');


gnd = load(truthPath);
gnd = gnd.g;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obsPath = '/Users/justin/Documents/MATLAB/medsim/data/emotion/raw/troubleshoot/obs.mat';
modelPath = '/Users/justin/Documents/MATLAB/medsim_analysis/data/emotion/emotion_mapping.mat';
obs = load(obsPath);
modelData = load(modelPath);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



scores = [0.9 0.1 1];





scores = subSegmentScores{10};
if size(scores, 1) > 1
  scores = mean(scores);
end

topThreshold = 0.8;
midThreshold = 0.5;
lowThreshold = 0.0;

numClasses = size(scores, 2) - 1;
midClsDelta = numClasses;
unconfident = 6; % class 6 is reserved for low confidence class

scoresNoLabel = scores(1:(end-1));

[M, cls] = max(scoresNoLabel);
if (M >= topThreshold)
  c = cls;
elseif (M >= midThreshold)
  c = cls + midClsDelta;
else
  c = unconfident;
end











tt.l1 = [1 2 3];
for i = tt.l1
  disp(i);
end










l1 = [1;2;3;4;5;6;7;8;9;10];
l2 = [1;1;1;1;2;2;2;2;2;2];

l1(l2=1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


l1 = [1;2;3;4;5;6;7;8;9;10];

l2 = [1;1;2;2;2;3;3;4;4;4];  % +4 for strong
l3 = [1;3;3;2;2;2;4;4;4;4];

l2(l3==3||l3==4) = l2(l3==3||l3==4)+4;






spkSignalClassified(emoSignalClassified==3|emoSignalClassified==4) = spkSignalClassified(emoSignalClassified==3|emoSignalClassified==4)+4;





emo = ones(275625, 1);
emo = [emo; 2*ones(275625,1)];
emo = [emo; 3*ones(275625,1)];
emo = [emo; 4*ones(275625,1)];








memberPath = '/Users/justin/Documents/MATLAB/medsim/data/ga/meta/20170504/43_best_member_err_32.0812.mat';
member = load(memberPath);

