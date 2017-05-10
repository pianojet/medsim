function population = quicktrain_ga()
  disp('quicktrain_ga');
  rootConfPath = '/Users/justin/Documents/MATLAB/medsim/quicktrain/config/spk_app_config.ini';
  conf = resetConfig(loadConfig(rootConfPath));
  conf.saveFiles = 0;
  originalConf = conf;
  qtOptions.disablePlotting = true;

  thisGeneration = 1;
  totalGenerations = 1000;

  globalBestMember = struct;
  globalBestMember.err = 100;
  globalBestMean = 100;
  population = [];
  popsize = 7;
  reproducers = 6;


  featureErrors = struct;
  featureTimes = struct;
  for i = 1:length(conf.availableFeatures)
    feat = conf.availableFeatures{i};
    featureErrors.(feat) = [];
    featureTimes.(feat) = [];
  end


  % start off putting a couple members in using current working config
  goodMember = struct;
  goodMember.conf = conf;
  returnData = quicktrainassess(conf, qtOptions);
  goodMember.result = returnData.results;
  goodMember.err = returnData.results.err;
  goodMember.time = returnData.time;
  goodMember.errRpt = '';
  population = [population goodMember];
  population = [population goodMember];

  while (length(population) < popsize)
    member = generate_member(originalConf, qtOptions);
    if isstruct(member) && isfield(member, 'errRpt') && isempty(member.errRpt)
      population = [population member];
    end
  end

  while thisGeneration < totalGenerations
    newPop = [];

    errz = [population.err];
    thisMean = mean(errz);
    [B, I] = sort(errz);

    if thisMean < globalBestMean
      globalBestMean = thisMean;
      bestMeanFile = sprintf('%sbest_means.txt', conf.metaPath);
      fileID = fopen(bestMeanFile, 'a');
      fprintf(fileID, '%04d %05.2f\n', thisGeneration, globalBestMean);
      fclose(fileID);
    end


    % log stats of this generation
    logline = sprintf('Gen: %04d', thisGeneration);
    logline = [logline sprintf(' | MIN: %05.2f  MEAN: %05.2f  MAX: %05.2f', min(B), thisMean, max(B))];
    logline = [logline sprintf(' | Top Values: ')];
    logline = [logline sprintf(' %05.2f', B(1:reproducers))];
    loglineFile = sprintf('%sfitness_record.txt', conf.metaPath);
    fileID = fopen(loglineFile, 'a');
    fprintf(fileID, '%s\n', logline);
    fclose(fileID);

    % log running average error & time performance per feature
    logline = sprintf('Gen: %04d\n', thisGeneration);

    for p = 1:length(population)
      member = population(p);
      for f = length(member.conf.selectedFeatures)
        feat = member.conf.selectedFeatures{f};
        featureErrors.(feat) = [featureErrors.(feat) member.err];
        featureTimes.(feat) = [featureTimes.(feat) member.time];
      end
    end
    fields = fieldnames(featureErrors);
    for f = 1:numel(fields)
      feat = fields{f};
      featMean = mean(featureErrors.(feat));
      featTime = mean(featureTimes.(feat));

      if length(feat) > 10
        feat = feat(1:10);
      end
      logline = [logline sprintf('\t|%11s-  err: %05.2f  sec: %05.2f\n', feat, featMean, featTime)];
    end

    % logline = [logline sprintf(' | Min:%07.4f Mean:%07.4f Max:%07.4f', min(B), thisMean, max(B))];
    % logline = [logline sprintf(' | Values: ')];
    % logline = [logline sprintf(' %07.4f', B)];
    loglineFile = sprintf('%sfield_record.txt', conf.metaPath);
    fileID = fopen(loglineFile, 'w');
    fprintf(fileID, '%s\n', logline);
    fclose(fileID);




    betterIdx = I(1:reproducers);
    betterPop = population(betterIdx);

    thisBestMember = betterPop(1);
    if thisBestMember.err < globalBestMember.err
      globalBestMember = thisBestMember;
      bestMemberFile = sprintf('%s%d_best_member_err_%07.4f.mat', conf.metaPath, thisGeneration, globalBestMember.err);
      save(bestMemberFile, '-struct', 'globalBestMember');
    end

    newPop = [newPop thisBestMember];

    for p = 1:(reproducers/2)
      member1 = betterPop(1);
      member2 = betterPop(p+1);
      newMemberConf = merge_member_confs(member1, member2);
      newMember = generate_member(newMemberConf, qtOptions);
      if isstruct(newMember) && isfield(newMember, 'errRpt') && isempty(newMember.errRpt)
        newPop = [newPop newMember];
      end
    end

    % revBetterPop = fliplr(betterPop);

    for p = 1:2:reproducers
      member1 = betterPop(p);
      member2 = betterPop(p+1);
      newMemberConf = merge_member_confs(member1, member2);
      newMember = generate_member(newMemberConf, qtOptions);
      if isstruct(newMember) && isfield(newMember, 'errRpt') && isempty(newMember.errRpt)
        newPop = [newPop newMember];
      end
    end

    if length(newPop) > popsize
      newPop = newPop(1:popsize);

    else
      while (length(newPop) < popsize)
        member = generate_member(originalConf, qtOptions);
        if isstruct(member) && isfield(member, 'errRpt') && isempty(member.errRpt)
          newPop = [newPop member];
        end
      end
    end

    % mutate
    mutateIdx = randr(2,2*length(newPop));
    if mutateIdx < length(newPop)
      disp(fprintf('Mutating member %d...',mutateIdx));
      mutateMember = mutate_member(newPop(mutateIdx), qtOptions);
      if isstruct(mutateMember) && isfield(mutateMember, 'errRpt') && isempty(mutateMember.errRpt)
        newPop(mutateIdx) = mutateMember;
      end
    end

    % occasionally remove a feature set if there are many
    % (we want fewer feature sets b/c it takes time to proc them)
    for i = 2:length(newPop)
      member = newPop(i);
      numFeatures = length(member.conf.selectedFeatures);
      numAvailFeatures = length(member.conf.availableFeatures);
      if numFeatures >= (numAvailFeatures-2) && randr(1,2) == 1
        member.conf.selectedFeatures = randr(member.conf.selectedFeatures, 3);
      end
    end

    population = newPop;
    thisGeneration = thisGeneration + 1;
  end


  % for c = 1:popsize
  %   population = [];
  %   while (length(population) < popsize)
  %     result = quicktrainassess(rootConfPath, options);
  %   end
  % end
  disp('done');


function member = generate_member(conf, qtOptions)
  disp('generate_member');
  member = struct;

  % set new params for member
  scanwintime = randr({0.50, 0.75, 1.0, 1.25, 1.5});
  conf.scan_wintime = scanwintime{1};
  conf.scan_hoptime = conf.scan_wintime / 2;

  featwintime = randr({0.02, 0.025, 0.03, 0.035, 0.04, 0.045, 0.05, 0.055, 0.06, 0.065, 0.07});
  conf.feature_wintime = featwintime{1};
  conf.feature_hoptime = 0.01;

  numOfSelFeatures = randr(1,3);
  if randr(1,4) == 1
    numOfSelFeatures = numOfSelFeatures + randr(2,length(conf.availableFeatures));
  end
  conf.selectedFeatures = randr(conf.availableFeatures, numOfSelFeatures);

  conf.feature_numcep = randr(1,13);
  conf.feature_lifterexp = randr(0, 1.5);
  conf.feature_sumpower = randr(1, 5);
  conf.feature_preemph = randr(0.1, 1.0);
  conf.feature_dither = randr(0, 1);
  conf.feature_minfreq = randr(0, 6000);
  conf.feature_maxfreq = randr(conf.feature_minfreq, conf.feature_minfreq+randr(8000));
  conf.feature_nbands = randr(2,40);
  conf.feature_bwidth = randr(0.5, 2.5);
  conf.feature_dcttype = randr(1, 4);

  selfbtype = randr({'mel', 'bark', 'htkmel', 'fcmel'});
  conf.feature_fbtype = selfbtype{1};

  selmappingtype = randr({'crisp', 'fuzzy'});
  conf.mappingType = selmappingtype{1};
  selclassifiertype = randr({'naivebayes', 'knn'});
  conf.classifier = selclassifiertype{1};
  conf.numClusters = randr(10,40);
  conf.filterBins = randr(0,5);

  try
    member.conf = conf;
    returnData = quicktrainassess(conf, qtOptions);
    member.result = returnData.results;
    member.err = returnData.results.err;
    member.time = returnData.time;
    member.errRpt = '';
  catch ME
    errRpt = getReport(ME);
    errRef = randr('alphanum', 8);
    errFileName = sprintf('%sga_err_%s.mat', conf.errorPath, errRef);
    member.errRpt = errRpt;
    warning(sprintf('Problem attaining results for conf saved file `%s`',errFileName));
    save(errFileName, '-struct', 'member');
  end


function mutateMember = mutate_member(member, qtOptions)
  disp('mutate_member');

  mutateMember = member;
  whichItem = randr(18);
  conf = member.conf;

  switch whichItem
    case 1
      scanwintime = randr({0.50, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0});
      conf.scan_wintime = scanwintime{1};
      conf.scan_hoptime = conf.scan_wintime / 2;
    case 2
      featwintime = randr({0.02, 0.025, 0.03, 0.035, 0.04});
      conf.feature_wintime = featwintime{1};
      conf.feature_hoptime = 0.01;
    case 3
      numOfSelFeatures = randr(1,length(conf.availableFeatures));
      conf.selectedFeatures = randr(conf.availableFeatures, numOfSelFeatures);
    case 4
      conf.feature_numcep = randr(1,13);
    case 5
      conf.feature_lifterexp = randr(0, 1.5);
    case 6
      conf.feature_sumpower = randr(1, 5);
    case 7
      conf.feature_preemph = randr(0.1, 1.0);
    case 8
      conf.feature_dither = randr(0, 1);
    case 9
      conf.feature_minfreq = randr(0, 6000);
    case 10
      conf.feature_maxfreq = randr(conf.feature_minfreq, conf.feature_minfreq+randr(8000));
    case 11
      conf.feature_nbands = randr(2,40);
    case 12
      conf.feature_bwidth = randr(0.5, 2.5);
    case 13
      conf.feature_dcttype = randr(1, 4);
    case 14
      selfbtype = randr({'mel', 'bark', 'htkmel', 'fcmel'});
      conf.feature_fbtype = selfbtype{1};
    case 15
      selmappingtype = randr({'crisp', 'fuzzy'});
      conf.mappingType = selmappingtype{1};
    case 16
      selclassifiertype = randr({'naivebayes', 'knn'});
      conf.classifier = selclassifiertype{1};
    case 17
      conf.numClusters = randr(10,40);
    case 18
      conf.filterBins = randr(0,5);
  end

  try
    mutateMember.conf = conf;
    returnData = quicktrainassess(conf, qtOptions);
    mutateMember.result = returnData.results;
    mutateMember.err = returnData.results.err;
    mutateMember.time = returnData.time;
    mutateMember.errRpt = '';
  catch ME
    errRpt = getReport(ME);
    errRef = randr('alphanum', 8);
    errFileName = sprintf('%sga_err_%s.mat', conf.errorPath, errRef);
    mutateMember.errRpt = errRpt;
    warning(sprintf('Problem attaining results for conf saved file `%s`',errFileName));
    save(errFileName, '-struct', 'member');
  end


function new_conf = merge_member_confs(member1, member2)
  disp('merge_member_confs');

  conf = member1.conf;

  scanhopmem = randr({member1, member2});
  conf.scan_wintime = scanhopmem{1}.conf.scan_wintime;
  conf.scan_hoptime = scanhopmem{1}.conf.scan_hoptime;

  scanhopmem = randr({member1, member2});
  conf.feature_wintime = scanhopmem{1}.conf.feature_wintime;
  conf.feature_hoptime = scanhopmem{1}.conf.feature_hoptime;


  numFeatures = round((length(member1.conf.selectedFeatures)+length(member2.conf.selectedFeatures))/2);
  % featureUnion = union(member1.conf.selectedFeatures, member2.conf.selectedFeatures);
  fList = [member1.conf.selectedFeatures member2.conf.selectedFeatures];
  conf.selectedFeatures = randr(fList, numFeatures);

  conf.feature_numcep = round(mean([member1.conf.feature_numcep member2.conf.feature_numcep]));
  conf.feature_lifterexp = mean([member1.conf.feature_lifterexp member2.conf.feature_lifterexp]);
  conf.feature_sumpower = mean([member1.conf.feature_sumpower member2.conf.feature_sumpower]);
  conf.feature_preemph = mean([member1.conf.feature_preemph member2.conf.feature_preemph]);
  conf.feature_dither = mean([member1.conf.feature_dither member2.conf.feature_dither]);
  conf.feature_minfreq = round(mean([member1.conf.feature_minfreq member2.conf.feature_minfreq]));
  conf.feature_maxfreq = round(mean([member1.conf.feature_maxfreq member2.conf.feature_maxfreq]));
  conf.feature_nbands = round(mean([member1.conf.feature_nbands member2.conf.feature_nbands]));
  conf.feature_bwidth = mean([member1.conf.feature_bwidth member2.conf.feature_bwidth]);

  dctmem = randr({member1, member2});
  conf.feature_dcttype = dctmem{1}.conf.feature_dcttype;

  fbtypemem = randr({member1, member2});
  conf.feature_fbtype = fbtypemem{1}.conf.feature_fbtype;

  mapmem = randr({member1, member2});
  conf.mappingType = mapmem{1}.conf.mappingType;

  classifiermem = randr({member1, member2});
  conf.classifier = classifiermem{1}.conf.classifier;

  conf.numClusters = round(mean([member1.conf.numClusters member2.conf.numClusters]));
  conf.filterBins = round(mean([member1.conf.filterBins member2.conf.filterBins]));

  new_conf = conf;


