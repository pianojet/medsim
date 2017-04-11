function saveAnalysis(conf, audio_data, gnd_data, finalResults, filterStats, options)


  truth = gnd_data(1:options.downSampleFactor:length(gnd_data));
  x_down = audio_data(1:options.downSampleFactor:length(audio_data));
  c_down = finalResults.signalClassified(1:options.downSampleFactor:length(finalResults.signalClassified));
  sample_down = options.sample_rate / options.downSampleFactor;

  if strcmp(conf.classifier, 'knn')
    graphPath = conf.graphDirKNN;
  elseif strcmp(conf.classifier, 'naivebayes')
    graphPath = conf.graphDirNB;
  end


  n = -1;
  ex = 10000;
  while ex > 0
    n = n + 1;
    if finalResults.err < 10
      batchDir = sprintf('%s/err_0%d_%d', graphPath, round(finalResults.err*1000), n);
    else
      batchDir = sprintf('%s/err_%d_%d', graphPath, round(finalResults.err*1000), n);
    end
    ex = exist(batchDir);
  end

  f = mkdir(batchDir);
  graphFile = sprintf('%s/graph.png', batchDir);
  filterBinFile = sprintf('%s/filtered.jpg', batchDir);
  allFilterBinFile = sprintf('%s/allFiltered.jpg', graphPath);
  % wrapperBinFile = sprintf('%s/wrappered.jpg', batchDir);
  % allWrapperBinFile = sprintf('%s/allWrappered.jpg', conf.graphDir);
  newConfFile = sprintf('%s/conf.mat', batchDir);
  initialPrototypes = sprintf('%s/initialPrototypes.jpg', batchDir);

  % disp('filterStats:');
  % disp(filterStats);




  % comes from the test
  %saveas(gcf, graphFile);
  plotOptions = options;
  plotOptions.sample_down = sample_down;
  f = makePlot(x_down, c_down, truth, plotOptions);
  set(f,'PaperPositionMode','auto')
  print(graphFile, '-djpeg', '-r0')
  close(f);




  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % )  prototype plot
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure;
  hold on
  stem(filterStats.initialModelSums');
  % stem(b2', 'Color', 'black', 'Marker', 'p');
  title(sprintf('Initial Prototype Comparison'));
  hold off
  saveas(gcf, initialPrototypes);
  close(gcf);


  for i = 1:length(filterStats.filterBinTracking)
    thesePrototypes = sprintf('%s/thesePrototypes_%03d.jpg', batchDir, i);
    figure;
    hold on
    stem(filterStats.filterMuTracking{i}');
    xx = filterStats.filterBinTracking{i};
    yy = zeros(1,length(filterStats.filterBinTracking{i}));
    h = stem(xx,yy,'filled');
    h.Color = 'black';
    h.BaseValue = 0;
    title(sprintf('This Prototype Comparison %03d', i));
    hold off
    saveas(gcf, thesePrototypes);
    close(gcf);
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % )  filtered bin plots filter method
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if isfield(conf, 'filterBins') && (conf.filterBins)
    figure;
    plot(filterStats.filterX,filterStats.filterY,'-*');
    set(gca,'XTick',filterStats.filterX);
    xlabel('Prototype Count (after filtered)');
    ylabel('Error %');
    title('Filtered Bin Analysis (filter method)');
    saveas(gcf, filterBinFile);
    close(gcf);
  end


  % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % % )  filtered bin plots wrapper method
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % if isfield(conf, 'wrapperBins') && (conf.wrapperBins)
  %   clf;
  %   plot(wrapperErrStats.filterX,wrapperErrStats.filterY,'-*');
  %   set(gca,'XTick',wrapperErrStats.filterX);
  %   xlabel('Prototype Count (after filtered)');
  %   ylabel('Error %');
  %   title('Filtered Bin Analysis (wrapper method)');
  %   saveas(gcf, wrapperBinFile);
  %   close(gcf);
  % end
