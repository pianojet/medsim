function audio_info = defaultAudioInfo()
  audio_info = struct;
  audio_info.SampleRate = 44100;
  audio_info.BitsPerSample = 16;
  audio_info.NumChannels = 1;
  audio_info.CompressionMethod = 'Uncompressed';
