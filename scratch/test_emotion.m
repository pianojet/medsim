conf = initializeConfig('/Users/justin/Documents/MATLAB/medsim/scratch/emotion.ini');

conf.audioFile = '/Users/justin/Documents/MATLAB/medsim/data/emotion/raw/angry_neutral_trainer.wav';
conf.truthFile = '/Users/justin/Documents/MATLAB/medsim/data/emotion/raw/angry_neutral_trainer_gnd.mat';

audio_data = audioread(conf.audioPath);
audio_info = audioinfo(conf.audioPath);
gnd_data = load(conf.truthFile);
gnd = gnd_data.g;

% refresh list of classes
classes = unique(gnd);


% continuousClassSignals.(classLabels{currentClass}){} = segments of signals
classData.continuousClassSignals = struct;
classData.classSampleCounts = struct;
classData.limits = struct;
classData.featuresByClass = {};
classData.classesAssigned = []; % list of classes that have been populated (should be unique set)
classData.colors = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.0 0.9 0.9; 0.9 0.0 0.9; 0.0 0.0 0.0];
classData.classLabels = {};
classData.undo = []; % list of previously touched classes (so that we can remove "previous" set)
classData.truth = gnd_data;

for c = 1:length(classes)
  label = getClassLabel(c);

  classData.featuresByClass{c} = [];
  classData.classLabels{c} = label;

  classData.continuousClassSignals.(label) = {};
  classData.classSampleCounts.(label) = 0;
  classData.limits.(label) = {};

end


