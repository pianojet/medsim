function audio_info = defaultAudioInfo()
  audio_info = struct;
  audio_info.SampleRate = 22050;
  audio_info.BitsPerSample = 16;
  audio_info.NumChannels = 1;
  audio_info.CompressionMethod = 'Uncompressed';
