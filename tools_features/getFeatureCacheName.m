function filename = getFeatureCacheName(conf, audio_info)

disp('getFeatureCacheName...');

prefix = 'cache';

featureString = [];
for i = 1:length(conf.selectedFeatures)
  featureString = [featureString '-' conf.selectedFeatures{i}];
end

settingString = [ ...
  sprintf('%2.4f', conf.feature_wintime) '-' ...
  sprintf('%2.4f', conf.feature_hoptime) '-' ...
  sprintf('%2.4f', conf.scan_wintime) '-' ...
  sprintf('%2.4f', conf.scan_hoptime) '-' ...
  sprintf('%02d', conf.feature_numcep) '-' ...
  sprintf('%06d', audio_info.SampleRate) '-' ...
  sprintf('%06d', audio_info.TotalSamples)
];

filename = [prefix featureString settingString '.mat'];