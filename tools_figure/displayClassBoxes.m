function displayClassBoxes(classData, options)
  % display silence markers on audio axes

  if not (nargin > 1)
    options = struct;
  end

  if ~isfield(options, 'colors') options.colors = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.0 0.9 0.9; 0.9 0.0 0.9; 0.0 0.0 0.0];
  end
  colors = options.colors;

  if ~isfield(options, 'figure') options.figure = figure;
  end
  axesHandle = options.figure;



  if ~isfield(options, 'EdgeColor') options.EdgeColor = [0 0.5 0];
  end

  if ~isfield(options, 'LineStyle') options.LineStyle = '--';
  end

  if ~isfield(options, 'LineWidth') options.LineWidth = 3;
  end

  if ~isfield(options, 'BoxShrink')
    spanShrink = 2;
    shiftShrink = -1;
  else
    spanShrink = 2*(options.BoxShrink);
    shiftShrink = -1*(spanShrink/2);
  end

  num_markers = size(markers);
  num_silences = num_markers(2) / 2; % num_markers should already be even!


  axesHandle;
  for m = 1:1:num_silences
    class_box = [markers((m*2)-1), shiftShrink, markers(m*2)-markers((m*2)-1), spanShrink];
    %silence_box = [markers((m*2)-1)..markers(m*2), -1..1];
    sprintf('Plotting %s', mat2str(class_box));
    % plot( plot::Rectangle(markers((m*2)-1)..markers(m*2), -1..1, FillPattern = CrossedLines );
    rectangle('Position', class_box, 'EdgeColor', EdgeColor, 'LineStyle', LineStyle, 'LineWidth', LineWidth);
    % plot([markers(m) markers(m)], [-1 1], 'r', 'LineWidth', 2);
  end
