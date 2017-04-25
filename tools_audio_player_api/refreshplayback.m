function player = refreshplayback(audio_data, audio_info, options)
  disp('`refreshplayback`');
  % instantiates an "audioplayer" coupled with a moving playhead

  if not (nargin > 2)
    options = struct;
  end

  if ~isfield(options, 'downSampleFactor') options.downSampleFactor = 1;
  end
  downSampleFactor = options.downSampleFactor;

  if ~isfield(options, 'figure') options.figure = figure;
  end
  axesHandle = options.figure;

  if ~isfield(options, 'playHeadLoc'); options.playHeadLoc = 1;
  end
  playHeadLoc = options.playHeadLoc;

  if playHeadLoc < 1
    playHeadLoc = 1;
  end


  disp('playback options:');
  disp(options);
  % vars for playhead plot
  frame_rate = 5;
  frameT = 1/frame_rate;
  axes(axesHandle);
  hold on
  ax = plot([playHeadLoc playHeadLoc], [-1 1], 'r', 'LineWidth', 2);

  % player handle
  player = audioplayer(audio_data, audio_info.SampleRate);

  % struct for playhead stats
  myStruct.playHeadLoc = playHeadLoc;
  myStruct.frameT = frameT;
  myStruct.ax = ax;
  myStruct.SampleRate = floor(audio_info.SampleRate/downSampleFactor);
  set(player, 'UserData', myStruct);
  set(player, 'TimerFcn', @apCallback);
  set(player, 'TimerPeriod', frameT);
  setappdata(0, 'player_handle', player);


function src = apCallback(src, eventdata)
  % play head tracking

  myStruct = get(src, 'UserData'); %//Unwrap

  incr = round(myStruct.frameT * myStruct.SampleRate);
  newPlayHeadLoc = myStruct.playHeadLoc + incr;
  set(myStruct.ax, 'Xdata', [newPlayHeadLoc newPlayHeadLoc])

  myStruct.playHeadLoc = newPlayHeadLoc;
  set(src, 'UserData', myStruct); %//Rewrap
