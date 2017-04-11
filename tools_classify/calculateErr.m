function percentError = calculateErr(data, truth)
  comparison = data==truth; %comparison = comparison.*x_down;

  errorCount = sum(comparison==0);
  percentError = (errorCount/length(comparison))*100;

  % percentCorrectNotUnknown = 100-errCalcNotUnknown;
  disp(sprintf('Error Percent: %%%3.2f', percentError));
