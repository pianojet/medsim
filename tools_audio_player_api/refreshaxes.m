function refreshaxes(audio_data, audio_info, options)
  % refresh gui axes panel for audio

  if not (nargin > 2)
    options = struct;
  end

  if ~isfield(options, 'colors')
    palette = defaultPalette();
    options.colors = palette.default;
  end
  colors = options.colors;

  if ~isfield(options, 'signalClassified') options.signalClassified = [];
  end
  signalClassified = options.signalClassified;

  if ~isfield(options, 'downSampleFactor') || (isfield(options, 'downSampleFactor') && options.downSampleFactor >= length(audio_data))
    options.downSampleFactor = 1;
  end
  downSampleFactor = options.downSampleFactor;

  if ~isfield(options, 'figure') options.figure = figure;
  end
  axesHandle = options.figure;

  if ~isfield(options, 'title') options.title = 'Classified';
  end

  % if ~isfield(options, 'samplelimits') options.samplelimits = [1 audio_info.TotalSamples];
  % end
  if ~isfield(options, 'samplelimits') options.samplelimits = [1 audio_info.TotalSamples];
  end


  if downSampleFactor > 1
    x_down = audio_data(1:downSampleFactor:length(audio_data));
    lim_down = ceil(options.samplelimits / downSampleFactor);
  else
    x_down = audio_data;
    lim_down = options.samplelimits;
  end
  xaxes = 1:length(x_down);
  axes(axesHandle);
  cla;
  hold on;

  if length(signalClassified) > 0
    if length(audio_data) ~= length(signalClassified)
      disp('CLASSIFIED AND SIGNAL WINDOW ARE NOT EQUAL (might be because of lossy scaling for plot)');
      fprintf('length(audio_data) = %d;  length(signalClassified) = %d;\n', length(audio_data), length(signalClassified));
    end

    % useful for when we downsize, but that's not impl yet
    if downSampleFactor > 1
      c_down = signalClassified(1:downSampleFactor:length(signalClassified));
      sample_down = round(audio_info.SampleRate/downSampleFactor);
    else
      c_down = signalClassified;
      sample_down = audio_info.SampleRate;
    end
    xlim_step = ceil((lim_down(2) - lim_down(1))/5);
    xlim_samples = lim_down(1):xlim_step:lim_down(2);  xlim_samples = [xlim_samples lim_down(2)];
    xlim_samples = unique(xlim_samples);
    xlim_seconds = xlim_samples / sample_down;
    xlim_labels = {};
    for i = 1:length(xlim_seconds)
      xlim_labels{i} = sprintf('%2.3f', xlim_seconds(i));
    end

    ylim([-1.2 1.2]);
    xlim([xaxes(1) xaxes(end)]);
    % xlim(lim_down);
    axesHandle.XAxis.Color = 'black';
    % xtk = get(axesHandle, 'XTick');
    % xtklbl = xtk/sample_down;
    xtk = xlim_samples;
    xtklbl = xlim_labels;
    set(axesHandle, 'XTick', xtk, 'XTickLabel',xtklbl);


    class1 = c_down==1; class1 = class1.*x_down;
    class2 = c_down==2; class2 = class2.*x_down;
    class3 = c_down==3; class3 = class3.*x_down;
    class4 = c_down==4; class4 = class4.*x_down;
    class5 = c_down==5; class5 = class5.*x_down;
    class6 = c_down==6; class6 = class6.*x_down;
    class7 = c_down==7; class7 = class7.*x_down;
    class8 = c_down==8; class8 = class8.*x_down;

    class100 = c_down==100; class100 = class100.*x_down;
    class101 = c_down==101; class101 = class101.*x_down;


    plot(xaxes, class1, 'Color', colors(1, :));
    plot(xaxes, class2, 'Color', colors(2, :));
    plot(xaxes, class3, 'Color', colors(3, :));
    plot(xaxes, class4, 'Color', colors(4, :));
    plot(xaxes, class5, 'Color', colors(5, :));
    plot(xaxes, class6, 'Color', colors(6, :));
    plot(xaxes, class7, 'Color', colors(7, :));
    plot(xaxes, class8, 'Color', colors(8, :));

    plot(xaxes, class100, 'Color', 'black'); % silence
    plot(xaxes, class101, 'Color', 'grey'); % unknown / unintelligble

    %legend('Class #1','Class #2', 'Class #3', 'Class #4', 'Silence', 'Unknown');


    xlabel('Seconds', 'Color', 'black');
    ylabel('Signal Amplitude', 'Color', 'black');
    title(options.title, 'Color', 'black');



  else
    plot(xaxes, x_down);
    ylim([-1.2 1.2]);
    xlim([xaxes(1) xaxes(end)]);
    xlabel('Sample');
  end

  hold off;


  disp('`refreshaxes` done.');