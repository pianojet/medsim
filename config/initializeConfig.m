function conf = initializeConfig(iniFile)
  appConfig = loadConfig(iniFile);
  disp('Loaded `appConfig`:');
  disp(appConfig);
  conf = resetConfig(appConfig);
