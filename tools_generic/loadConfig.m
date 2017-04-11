function conf = loadConfig(configPath)
  if nargin == 0
    error('loadConfig: required path missing');
  end

  conf = struct;
  ini = IniConfig();
  ini.ReadFile(configPath);
  sections = ini.GetSections();
  delimiter = ',';


  for s = 1:length(sections)
    keys = ini.GetKeys(sections{s});
    values = ini.GetValues(sections{s});
    for k = 1:length(keys)
      if isstr(values{k})
        if strcmp(values{k}, 'true')
          conf.(keys{k}) = true;
        elseif strcmp(values{k}, 'false')
          conf.(keys{k}) = false;
        elseif ~isempty(strfind(values{k}, delimiter))
          conf.(keys{k}) = strsplit(values{k}, delimiter);
        else
          conf.(keys{k}) = values{k};
        end
      else
        conf.(keys{k}) = values{k};
      end
    end
  end
