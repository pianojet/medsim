function plotSegments( x, fs, segments, Limits, options )
  % plot x (a signal) colored according to segments and Limits

  if not (nargin > 4)
      options = struct;
  end

  if isfield(options, 'colors')
    colors = options.colors;
  else
    colors = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.0 0.9 0.9];
  end

  if isfield(options, 'colorSilence')
    colorSilence = options.colorSilence;
  else
    colorSilence = [0.7 0.7 0.7];
  end

  if isfield(options, 'figure')
    plotFigure = options.figure;
  else
    plotFigure = false;
  end

  if isfield(options, 'segDisplay')
    figureDisplay = getFigure(plotFigure, options.segDisplay);
  else
    figureDisplay = false;
  end

  axes(figureDisplay);

  time = 0:1/fs:(length(x)-1) / fs;
  for (i=1:length(segments))
      hold off;
      P1 = plot(time, x); set(P1, 'Color', colorSilence);    
      hold on;
      for (j=1:length(segments))
          if (i~=j)
              timeTemp = Limits(j,1)/fs:1/fs:Limits(j,2)/fs;
              P = plot(timeTemp, segments{j});
              set(P, 'Color', colors(1, :));
          end
      end
      timeTemp = Limits(i,1)/fs:1/fs:Limits(i,2)/fs;
      P = plot(timeTemp, segments{i});
      set(P, 'Color', colors(1, :));
      axis([0 time(end) min(x) max(x)]);
  end

  legend('Silence', 'Speaker #1', 'Speaker #2', 'Speaker #3', 'Speaker #4');
  xlabel('Samples');
  ylabel('Signal Amplitude');
  title('Segmentation Results');