function plotGnd(axesHandle, audio_data, audio_info, truth, options )

  if not (nargin > 4)
      options = struct;
  end

  if isfield(options, 'colors')
    colors = options.colors;
  else
    colors = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.0 0.9 0.9; 0.9 0.0 0.9; 0.0 0.0 0.0];
  end

  % if isfield(options, 'downSampleFactor')
  %   n = options.downSampleFactor;
  % else
  %   n = 4;
  % end

  % if isfield(options, 'figure')
  %   plotFigure = options.figure;
  % else
  %   plotFigure = figure;
  % end

  % if isfield(options, 'gndDisplay')
  %   figureDisplay = getFigure(plotFigure, options.gndDisplay);
  % else
  %   figureDisplay = false;
  % end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % )  PLOT/OUTPUT:  downsize gnd-truth and class data
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % fprintf('\n\n######################################\nPlotting...\n');
  % fprintf('TIME:')
  % disp(clock);
  % rawGndTest = signalGnd(:, 2);
  % rawSigTest = signal;

  % n = 4;
  % truth = rawGndTest(1:n:length(rawGndTest));
  % x_down = rawSigTest(1:n:length(rawSigTest));
  % c_down = signalClassified(1:n:length(signalClassified));
  % sample_down = sample_rate/n;

  %%%%%% for now, no downsize:
  x_down = audio_data;
  sample_down = audio_info.SampleRate;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 8)  PLOT/OUTPUT:  graph
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  xaxes = 1:length(x_down);

  class1 = truth==1; class1 = class1.*x_down;
  class2 = truth==2; class2 = class2.*x_down;
  class3 = truth==3; class3 = class3.*x_down;
  class4 = truth==4; class4 = class4.*x_down;
  class5 = truth==5; class5 = class5.*x_down;
  axes(axesHandle);
  cla;
  hold on;
  plot(xaxes, class1, 'Color', colors(1, :));
  plot(xaxes, class2, 'Color', colors(2, :));
  plot(xaxes, class3, 'Color', colors(3, :));
  plot(xaxes, class4, 'Color', colors(4, :));
  plot(xaxes, class5, 'Color', colors(5, :));
  xlim([xaxes(1) xaxes(end)]);
  legend('Speaker #1','Speaker #2', 'Speaker #3', 'Speaker #4', 'Silence');
  xlabel('Samples');
  ylabel('Signal Amplitude');
  title('Ground Truth');
  hold off;

  % class1 = c_down==1; class1 = class1.*x_down;
  % class2 = c_down==2; class2 = class2.*x_down;
  % class3 = c_down==3; class3 = class3.*x_down;
  % class4 = c_down==4; class4 = class4.*x_down;
  % class5 = c_down==5; class5 = class5.*x_down;
  % class6 = c_down==6; class6 = class6.*x_down;
  % subplot(3, 1, 2);
  % hold on;
  % plot(xaxes, class1, 'Color', colors(1, :));
  % plot(xaxes, class2, 'Color', colors(2, :));
  % plot(xaxes, class3, 'Color', colors(3, :));
  % plot(xaxes, class4, 'Color', colors(4, :));
  % plot(xaxes, class5, 'Color', colors(5, :));
  % plot(xaxes, class6, 'Color', colors(6, :));
  % legend('Speaker #1','Speaker #2', 'Speaker #3', 'Speaker #4', 'Silence', 'Unknown');
  % xtk = get(gca, 'XTick');
  % xtklbl = xtk/sample_down;
  % set(gca, 'XTick', xtk, 'XTickLabel',xtklbl);
  % xlabel('Seconds');
  % ylabel('Signal Amplitude');
  % title('Classified');




  % comparison = truth==c_down; comparison = comparison.*x_down;

  % errorCount = sum(comparison==0);
  % percentError = (errorCount/length(comparison))*100;
  % percentCorrect = 100-percentError;
  % percentCorrectNotUnknown = 100-errCalcNotUnknown;
  % disp(sprintf('Error Percent: %%%3.2f', percentError));

  % % class2 = c_test==2; class2 = class2.*x_down;
  % % class3 = c_test==3; class3 = class3.*x_down;
  % % class5 = c_test==5; class5 = class5.*x_down;
  % subplot(3, 1, 3);
  % hold on;
  % plot(xaxes, comparison, 'Color', [0.0 0.0 0.0]);
  % % plot(xaxes, class2, 'Color', colors(2, :));
  % % plot(xaxes, class3, 'Color', colors(3, :));
  % % plot(xaxes, class5, 'Color', colors(5, :));
  % % legend('Speaker #1','Speaker #2', 'Speaker #3', 'Silence');
  % txt = sprintf('Correctly Classified Samples: %3.2f%%, Not-Unknown: %3.2f%%', percentCorrect, percentCorrectNotUnknown);
  % xlabel(txt);
  % ylabel('Signal Amplitude');
  % title('Comparison');

  % set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.







  % fprintf('\n\n######################################\nCompleted\n');
  % fprintf('TIME:')
  % disp(clock);
  % disp('######################################')





%%%%% deprecated? 20161002


  % % plot x (a signal) colored according to labeled ground-truth data "gnd"

  % if not (nargin > 3)
  %     options = struct;
  % end

  % if isfield(options, 'colors')
  %   colors = options.colors;
  % else
  %   colors = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.0 0.9 0.9];
  % end

  % if isfield(options, 'colorSilence')
  %   colorSilence = options.colorSilence;
  % else
  %   colorSilence = [0.7 0.7 0.7];
  % end

  % if isfield(options, 'figure')
  %   plotFigure = options.figure;
  % else
  %   plotFigure = false;
  % end

  % if isfield(options, 'gndDisplay')
  %   figureDisplay = getFigure(plotFigure, options.gndDisplay);
  % else
  %   figureDisplay = false;
  % end

  % if isfield(options, 'gndPrecision')
  %   figureDisplay = options.gndPrecision
  % else
  %   figureDisplay = 'second';
  % end



  % % calculate artificial segments and limits to use original plot loop code
  % segments = {};
  % Limits = [];
  % if strcmp(figureDisplay, 'sample')
  %   for i = 1:length(gnd)
  %     limit_start = (i*fs)-fs+1;
  %     limit_end = i*fs;
  %     if limit_end > length(x)
  %       limit_end = length(x);
  %     end
  %     segments{i} = x(limit_start:limit_end);
  %     Limits = [Limits; limit_start limit_end ];
  %   end
  % else
  %   for i = 1:length(gnd)
  %     limit_start = (i*fs)-fs+1;
  %     limit_end = i*fs;
  %     if limit_end > length(x)
  %       limit_end = length(x);
  %     end
  %     segments{i} = x(limit_start:limit_end);
  %     Limits = [Limits; limit_start limit_end ];
  %   end
  % end

  % axes(figureDisplay);
  % hold on;
  % time = 0:1/fs:(length(x)-1) / fs;
  % P1 = plot(time, x); set(P1, 'Color', colorSilence);

  % for (j=1:length(segments))
  %     color = colors(gnd(j), :);
  %     timeTemp = Limits(j,1)/fs:1/fs:Limits(j,2)/fs;
  %     P = plot(timeTemp, segments{j});
  %     set(P, 'Color', color);
  % end
  % legend('Silence', 'Speaker #1','Speaker #2', 'Speaker #3', 'Speaker #4');
  % xlabel('Samples');
  % ylabel('Signal Amplitude');
  % title('Ground Truth');
