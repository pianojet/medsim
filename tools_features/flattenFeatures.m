function flatFeatures = flattenFeatures(features)

  if length(features) <= 0
    error('Empty features argument.');
  end

  flatFeatures = [];
  names = fieldnames(features(1));
  for i = 1:length(features)
    segFeatures = [];
    for n = 1:length(names)
      f = getfield(features(i), names{n});
      segFeatures = [segFeatures f];
    end
    flatFeatures = [flatFeatures; segFeatures];
  end