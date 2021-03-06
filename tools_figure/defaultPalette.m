function palette = defaultPalette()
  palette = struct;

  % red; green; blue; magenta;
  palette.speaker = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.9 0.0 0.9; ...
    0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0];

  palette.emo = [1 0.8 0.8; 0.8 1 0.8; 1 0.0 0.0; 0.0 1 0.0; ...
    0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0];

  palette.speakerEmo = [1 0.8 0.8; 0.8 1 0.8; 0.8 0.8 1; 1 0.8 1; ...
    0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.9 0.0 0.9; 0.0 0.0 0.0];

  % default unclassified color "bland blue"
  palette.default = [0.5 0.5 0.7; 0.5 0.5 0.7; 0.5 0.5 0.7; 0.5 0.5 0.7; ...
    0.5 0.5 0.7; 0.5 0.5 0.7; 0.5 0.5 0.7; 0.5 0.5 0.7];

  % default classified colors
  palette.classifiedDefault = [0.9 0.0 0.0; 0.0 0.9 0.0; 0.0 0.0 0.9; 0.9 0.0 0.9; ...
    0.9 0.9 0.0; 0.0 0.9 0.9; 0.5 0.9 0.5; 0.9 0.5 0.5];