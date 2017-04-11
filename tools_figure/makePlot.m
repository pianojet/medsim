function f = makePlot(signal, classified, gnd, options)

  if not (nargin > 3)
      options = struct;
  end

  if ~isfield(options, 'colors') options.colors = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.0 0.9 0.9; 0.9 0.0 0.9; 0.0 0.0 0.0];
  end
  colors = options.colors;

  if ~isfield(options, 'downSampleFactor') options.downSampleFactor = 1;
  end
  downSampleFactor = options.downSampleFactor;

  if ~isfield(options, 'sample_down') options.sample_down = options.sample_rate / options.downSampleFactor;
  end


  n = options.downSampleFactor;
  truth = gnd(1:n:length(gnd));
  x_down = signal(1:n:length(signal));
  c_down = classified(1:n:length(classified));
  sample_down = options.sample_down;



  comparison = truth==c_down; comparison = comparison.*x_down;

  errorCount = sum(comparison==0);
  percentError = (errorCount/length(comparison))*100;
  percentCorrect = 100-percentError;




  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 8)  PLOT/OUTPUT:  graph
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  xaxes = 1:length(x_down);

  class1 = truth==1; class1 = class1.*x_down;
  class2 = truth==2; class2 = class2.*x_down;
  class3 = truth==3; class3 = class3.*x_down;
  class4 = truth==4; class4 = class4.*x_down;
  class5 = truth==5; class5 = class5.*x_down;
  figure;
  subplot(3, 1, 1);
  hold on;
  plot(xaxes, class1, 'Color', colors(1, :));
  plot(xaxes, class2, 'Color', colors(2, :));
  plot(xaxes, class3, 'Color', colors(3, :));
  plot(xaxes, class4, 'Color', colors(4, :));
  plot(xaxes, class5, 'Color', colors(5, :));
  legend('Speaker #1','Speaker #2', 'Speaker #3', 'Speaker #4', 'Silence');
  xlabel('Samples');
  ylabel('Signal Amplitude');
  title('Ground Truth');
  hold off;


  class1 = c_down==1; class1 = class1.*x_down;
  class2 = c_down==2; class2 = class2.*x_down;
  class3 = c_down==3; class3 = class3.*x_down;
  class4 = c_down==4; class4 = class4.*x_down;
  class5 = c_down==5; class5 = class5.*x_down;
  class6 = c_down==6; class6 = class6.*x_down;
  subplot(3, 1, 2);
  hold on;
  plot(xaxes, class1, 'Color', colors(1, :));
  plot(xaxes, class2, 'Color', colors(2, :));
  plot(xaxes, class3, 'Color', colors(3, :));
  plot(xaxes, class4, 'Color', colors(4, :));
  plot(xaxes, class5, 'Color', colors(5, :));
  plot(xaxes, class6, 'Color', colors(6, :));
  h = legend('Speaker #1','Speaker #2', 'Speaker #3', 'Speaker #4', 'Silence', 'Unknown');
  % xtk = get(gcf, 'XTick');
  % xtklbl = xtk/sample_down;
  % set(gcf, 'XTick', xtk, 'XTickLabel',xtklbl);
  xlabel('Seconds');
  ylabel('Signal Amplitude');
  title('Classified');
  hold off;





  % class2 = c_test==2; class2 = class2.*x_down;
  % class3 = c_test==3; class3 = class3.*x_down;
  % class5 = c_test==5; class5 = class5.*x_down;
  subplot(3, 1, 3);
  hold on;
  plot(xaxes, comparison, 'Color', [0.0 0.0 0.0]);
  % plot(xaxes, class2, 'Color', colors(2, :));
  % plot(xaxes, class3, 'Color', colors(3, :));
  % plot(xaxes, class5, 'Color', colors(5, :));
  % legend('Speaker #1','Speaker #2', 'Speaker #3', 'Silence');
  txt = sprintf('Correctly Classified Samples: %3.2f%%', percentCorrect);
  xlabel(txt);
  ylabel('Signal Amplitude');
  title('Comparison');
  hold off;



  set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
  % set(gcf,'PaperPositionMode','auto')


  f = gcf;



  fprintf('\n\n######################################\nCompleted\n');
  fprintf('TIME:')
  disp(clock);
  disp('######################################')

