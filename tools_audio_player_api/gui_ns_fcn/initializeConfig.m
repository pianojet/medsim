function initializeConfig()
  disp('Loading config...')
  appConfig = loadConfig('/Users/justin/Documents/MATLAB/medsim/config/app_config.ini');
  disp(appConfig);
  conf = resetConfig(appConfig);
