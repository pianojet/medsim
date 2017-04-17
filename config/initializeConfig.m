function conf = initializeConfig(iniFile)
  disp('Loading config...')
  appConfig = loadConfig(iniFile);
  disp(appConfig);
  conf = resetConfig(appConfig);
