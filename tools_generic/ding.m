function ding()
  audiopath = '/Users/justin/Documents/ding.wav';
  audio_data = audioread(audiopath);
  player = audioplayer(audio_data, 44100);
  disp('#!!! DING !!!#');
  for n = 1:3
    playblocking(player);
  end