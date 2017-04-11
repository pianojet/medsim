function plotTrainSegments(modelData, options)
  % display silence markers on audio axes
  % modelData.limits.(label) = array of start & end times
  %   limits must be start & end pairs
  % options: struct
  %   EdgeColor: RGB array
  %     e.g. [0 0.5 0]
  %   LineStyle: style of lines of the box
  %   LideWidth: width of lines of the box
  %   BoxShrink: percent size of max, (max being -1 to 1 (size 2))
  %

  if not (nargin > 1)
    options = struct;
  end

  if ~isfield(modelData, 'classLabels') modelData.classLabels = {};
  end

  if ~isfield(modelData, 'limits') modelData.limits = struct;
  end

  if isfield(options, 'LineStyle')
    LineStyle = options.LineStyle;
  else
    LineStyle = '--';
  end

  if isfield(options, 'LineWidth')
    LineWidth = options.LineWidth;
  else
    LineWidth = 3;
  end

  if isfield(options, 'BoxShrink')
    spanShrink = 2*(options.BoxShrink);
    shiftShrink = -1*(spanShrink/2);
  else
    spanShrink = 2;
    shiftShrink = -1;
  end

  if ~isfield(options, 'figure') options.figure = axes;
  end

  axes(options.figure);
  hold on;
  for c = 1:length(modelData.classLabels)
    label = modelData.classLabels{c};
    for l = 1:length(modelData.limits.(label))
      limits = modelData.limits.(label){l};
      classBox = [limits(1), shiftShrink, limits(2)-limits(1), spanShrink];
      rectangle('Position', classBox, 'EdgeColor', 'black', 'LineStyle', LineStyle, 'LineWidth', LineWidth);
    end
  end
  hold off;

  % for m = 1:1:num_silences
  %   silence_box = [markers((m*2)-1), shiftShrink, markers(m*2)-markers((m*2)-1), spanShrink];
  %   %silence_box = [markers((m*2)-1)..markers(m*2), -1..1];
  %   vprint(sprintf('Plotting %s', mat2str(silence_box)));
  %   % plot( plot::Rectangle(markers((m*2)-1)..markers(m*2), -1..1, FillPattern = CrossedLines );
  %   rectangle('Position', silence_box, 'EdgeColor', EdgeColor, 'LineStyle', LineStyle, 'LineWidth', LineWidth);
  %   % plot([markers(m) markers(m)], [-1 1], 'r', 'LineWidth', 2);
  % end
