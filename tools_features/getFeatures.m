function features = getFeatures(x, sr, selectedFeatures, options)
  features = ExtractMultipleFeaturesinit(selectedFeatures);
  if length(x) > 0
    theseFeatures = ExtractMultipleFeatures(x, sr, selectedFeatures, options);
    % flatten
    seg = [];
    for f = 1:length(selectedFeatures)
      seg = [seg theseFeatures.(selectedFeatures{f})];
    end
    features = seg;
  end
