function confmat = confusionMatrix(clsfy, truth)

  specialClassLimit = max(unique(clsfy));

  truth = truth(truth<=specialClassLimit);
  clsfy = clsfy(truth<=specialClassLimit);

  cm = confusionmat(truth, clsfy);
  cmSums = sum(cm');
  for s = 1:size(cm, 1)
    cm(s,:) = cm(s,:) / cmSums(s);
  end

  figure;
  imshow(cm, 'InitialMagnification' ,10000);
  colormap(jet)

  cm = cm.*100;

  disp('matrix:');
  disp(cm);

  confmat = cm;
  disp('confusion matrix completed');