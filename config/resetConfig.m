function conf = resetConfig(appConfig)
  % conf = getappdata(0, 'appConf');
  dataConf = loadConfig([appConfig.rootPath, '/', appConfig.dataConfigFile]);
  pathConf = loadConfig([appConfig.rootPath, '/', appConfig.dataPathFile]);

  % add paths to dataConf: prepend `rootPath` (which is absolute) to paths as defined in config
  fields = fieldnames(pathConf);
  for i = 1:numel(fields)
    % don't make absolute if already absolute
    p = pathConf.(fields{i});
    if strcmp(p(1), '/')
      dataConf.(fields{i}) = p;
    else
      dataConf.(fields{i}) = [appConfig.rootPath, '/', p];
    end
  end

  % now add all dataConf fields to a central `conf` struct
  fields = fieldnames(dataConf);
  for i = 1:numel(fields)
    conf.(fields{i}) = dataConf.(fields{i});
  end

  % ensure fields that can be lists are consistently cells even with one item
  if isstr(conf.selectedFeatures)
    conf.selectedFeatures = {conf.selectedFeatures};
  end

  setappdata(0, 'conf', conf);
