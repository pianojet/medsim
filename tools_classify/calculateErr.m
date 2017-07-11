function percentError = calculateErr(data, truth)
  specialClassLimit = max(unique(data));

  truthNoSpecialClasses = truth(truth<=specialClassLimit);
  dataNoSpecialClasses = data(truth<=specialClassLimit);

  % truthNoSpecialClasses = truth(truth<=100);
  % dataNoSpecialClasses = data(truth<=100);
  comparison = dataNoSpecialClasses==truthNoSpecialClasses; %comparison = comparison.*x_down;

  errorCount = sum(comparison==0);
  percentError = (errorCount/length(comparison))*100;

  % percentCorrectNotUnknown = 100-errCalcNotUnknown;
  disp(sprintf('Error Percent: %%%3.2f', percentError));
