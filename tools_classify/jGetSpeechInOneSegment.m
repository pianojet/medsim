function [ segments, fs, Limits ] = jGetSpeechInOneSegment( x, fs, options )

% developed from Theodoros Giannakopoulos
% http://www.di.uoa.gr/~tyiannak
%
% input:
%     x: audio data, read through wavread or other method, one dimension
%     fs: frequency
%     options: (struct)
%       displays: list of 3 displays for plot output
%           tag for display, if input is only x and fs, then do not display result
%       method:  [ 1 | 2 ]
%           method to use for segmentation
%           1: uses threshold estimation
%           2: uses SVN classification
%       window: decimal
%           window length (and step) in seconds
%       weightSTE: integer
%           short-time-energy weight (for threshold estimation method)
%       weightSC: integer
%           spectral-centroid weight (for threshold estimation method)
% output:
%     segments: audio data with cell formats
%     fs: frequency
%
% By Shuang, 20111101
% disp('GetSpeechInOneSegment medsim namespace');
% handle options
if not (nargin > 2)
    options = struct;
end

if isfield(options, 'method')
  doSilenceRemoval = options.method;
else
  doSilenceRemoval = 1;
end

playDisplay = false;
displays = false;
plotFigure = false;
if (isfield(options, 'displays') && ~(isempty(options.displays)))
    displays = options.displays;
    if isfield(options, 'playDisplay')
        playDisplay = options.playDisplay;
    end
    if isfield(options, 'figure')
        plotFigure = options.figure;
    end
else
    displays = {};
end

if isfield(options, 'window')
    win = options.window;
    step = options.window;
else
    % Window length and step (in seconds):
    win = 0.02;
    step = 0.02;
end

if isfield(options, 'filtorder')
    filtorder = options.filtorder;
    %fprintf('`filtorder` set to %d\n', filtorder);
else
    filtorder = 7;
    %fprintf('`filtorder` set to DEFAULT %d\n', filtorder);
end

if isfield(options, 'weightSTE')
    Weight = options.weightSTE;
    %fprintf('`Weight` set to %d\n', Weight);
else
    Weight = 20;
    %fprintf('`Weight` set to DEFAULT %d\n', Weight);
end

if isfield(options, 'weightSC')
    Weight2 = options.weightSC;
    %fprintf('`Weight2` set to %d\n', Weight2);
else
    Weight2 = 10;
    %fprintf('`Weight2` set to DEFAULT %d\n', Weight2);
end


% Convert mono to stereo
if (size(x, 2)==2)
  x = mean(x')';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  THRESHOLD ESTIMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute short-time energy and spectral centroid of the signal:
warning off
Eor = getShortTimeEnergy(x, fix(win*fs), fix(step*fs));
EE = getEnergy_Entropy_Block(x, fix(win*fs), fix(step*fs), 10);
ZC = getzcr(x, fix(win*fs), fix(step*fs), fs);
Cor = getSpectralCentroid(x, fix(win*fs), fix(step*fs), fs);
% RO = getSpectralRollOff(x, fix(win*fs), fix(step*fs), 0.80, fs);
% SF = getSpectralFlux(x, fix(win*fs), fix(step*fs), fs);

disp(['Silence Removal Mode: ', num2str(doSilenceRemoval), '.................']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply median filtering in the feature sequences (twice), using 5 windows:
% (i.e., 250 mseconds)
if doSilenceRemoval == 1 %%%% "auto"
    E = medfilt1(Eor, filtorder); E = medfilt1(E, filtorder);
    C = medfilt1(Cor, filtorder); C = medfilt1(C, filtorder);

    % Get the average values of the smoothed feature sequences:
    E_mean = mean(E);
    Z_mean = mean(C);

    % Find energy threshold:
    [HistE, X_E] = hist(E, round(length(E) / 20));  % histogram computation
    [MaximaE, countMaximaE] = findMaxima(HistE, 3); % find the local maxima of the histogram
    if (size(MaximaE,2)>=2) % if at least two local maxima have been found in the histogram:
        T_E = (Weight*X_E(MaximaE(1,1))+X_E(MaximaE(1,2))) / (Weight+1); % ... then compute the threshold as the weighted average between the two first histogram's local maxima.
        T_E = max([E_mean/4, T_E]);
    else
        T_E = E_mean/4;
    end

    % Find spectral centroid threshold:
    [HistC, X_C] = hist(C, round(length(C) / 10));
    [MaximaC, countMaximaC] = findMaxima(HistC, 3);
    if (size(MaximaC,2)>=2)
        T_C = (Weight2*X_C(MaximaC(1,1))+X_C(MaximaC(1,2))) / (Weight2+1);
        T_C = mean([Z_mean/2.5, T_C]);
    else
        T_C = Z_mean/2.5;
    end

    % Thresholding:
    Flags1 = (E>=T_E);
    Flags2 = (C>=T_C);
    flags = Flags1 & Flags2;

elseif doSilenceRemoval==2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% or classify

    % load('D:\shuang research\audioseg\audioFeatureExtraction\silenceRemoval\silence_SVMStruct.mat');
    % trainf = [medfilt1(Eor,7) medfilt1(EE',7) medfilt1(Cor,7) medfilt1(ZC,7) medfilt1(RO',7) medfilt1(SF,7)];
    % load('data/silence/classifier/silence_SVMStruct_SE_EE_ZC.mat');
    load(options.silenceSVMfile);
    %trainf = [medfilt1(Eor,7) medfilt1(EE',7) medfilt1(ZC,7)];
    trainf = [medfilt1(Eor,filtorder) medfilt1(EE',filtorder) medfilt1(ZC,filtorder)];
    flags = svmclassify(silence_SVMStruct,trainf);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~(isempty(displays)) % plot results:
  %   figure('color',[1 1 1]);
  % clf;
    h = getFigure(plotFigure, displays{1});
    axes(h)
    plot(Eor, 'b'); hold on; plot(medfilt1(Eor,5), 'r'); legend({'Short time energy (original)', 'Short time energy (filtered)'});xlabel('(a)   audio stream (1sec/50)');ylabel('Energy value');
%     L = line([0 length(E)],[T_E T_E]); set(L,'Color',[0 0 0]); set(L, 'LineWidth', 2);
    axis([0 length(Eor) min(Eor) max(Eor)]);

    h = getFigure(plotFigure, displays{2});
    axes(h)
    plot(Cor, 'b'); hold on; plot(medfilt1(Cor,5), 'r'); legend({'Spectral Centroid (original)', 'Spectral Centroid (filtered)'});xlabel('(b)   audio stream (1sec/50)');ylabel('Energy value');
%   L = line([0 length(C)],[T_C T_C]); set(L,'Color',[0 0 0]); set(L, 'LineWidth', 2);
    axis([0 length(Cor) min(Cor) max(Cor)]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SPEECH SEGMENTS DETECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
count = 1;
WIN = 5;
Limits = [];
while (count < length(flags)) % while there are windows to be processed:
  % initilize:
  curX = [];
  countTemp = 1;
  % while flags=1:
  while ((flags(count)==1) && (count < length(flags)))
    if (countTemp==1) % if this is the first of the current speech segment:
      Limit1 = round((count-WIN)*step*fs)+1; % set start limit:
      if (Limit1<1) Limit1 = 1; end
    end
    count = count + 1;    % increase overall counter
    countTemp = countTemp + 1;  % increase counter of the CURRENT speech segment
  end

  if (countTemp>1) % if at least one segment has been found in the current loop:
    Limit2 = round((count+WIN)*step*fs);      % set end counter
    if (Limit2>length(x))
            Limit2 = length(x);
        end

        Limits(end+1, 1) = Limit1;
        Limits(end,   2) = Limit2;
    end
  count = count + 1; % increase overall counter
end

%%%%%%%%%%%%%%%%%%%%%%%
% POST - PROCESS      %
%%%%%%%%%%%%%%%%%%%%%%%

% A. MERGE OVERLAPPING SEGMENTS:
RUN = 1;
while (RUN==1)
    RUN = 0;
    for (i=1:size(Limits,1)-1) % for each segment
        if (Limits(i,2)>=Limits(i+1,1)-1)
            RUN = 1;
            Limits(i,2) = Limits(i+1,2);
            Limits(i+1,:) = [];
            break;
        end
    end
end

% B. Get final segments:
segments = {};
for (i=1:size(Limits,1))
    segments{end+1} = x(Limits(i,1):Limits(i,2));
end

if ~(isempty(displays))
    h = getFigure(plotFigure, displays{3});
    axes(h)
    % Plot results and play segments:
    time = 0:1/fs:(length(x)-1) / fs;
    for (i=1:length(segments))
        hold off;
        P1 = plot(time, x); set(P1, 'Color', [0.7 0.7 0.7]);
        hold on;
        for (j=1:length(segments))
            if (i~=j)
                timeTemp = Limits(j,1)/fs:1/fs:Limits(j,2)/fs;
                P = plot(timeTemp, segments{j});
                set(P, 'Color', [0.4 0.1 0.1]);
            end
        end
        timeTemp = Limits(i,1)/fs:1/fs:Limits(i,2)/fs;
        P = plot(timeTemp, segments{i});
        set(P, 'Color', [0.9 0.0 0.0]);
        axis([0 time(end) min(x) max(x)]);
        if (playDisplay)
            segmentTime = length(segments{i})/fs;
            sound(segments{i}, fs);
            fprintf('\n Playing segment %d of %d.......... ', i, length(segments));
            pause(segmentTime)
        end
    end
%     clc
    hold off;
    P1 = plot(time, x); set(P1, 'Color', [0.7 0.7 0.7]);
    hold on;
    timeTemp = [];
    for (i=1:length(segments))
        for (j=1:length(segments))
            if (i~=j)
                timeTemp = Limits(j,1)/fs:1/fs:Limits(j,2)/fs;
                P = plot(timeTemp, segments{j});
                set(P, 'Color', [0.85 0.16 0.1]);%[0.4 0.1 0.1]
                scatter(0,0,'rs')
                scatter(0,0,'bs')
            end
        end
    end
    axis([0 time(end) min(x) max(x)]);
    legend('Silence','Speech');xlabel('(c)   audio stream (second)');ylabel('Signal Amplitude');
end

% figure;subplot(211)
% subplot(212)
% legend('Silence','Speech','correctly detected silence','incorrectly detected silence');xlabel('(a)   audio stream (second)');ylabel('Signal Amplitude');
% legend('Silence','Speech','correctly detected silence','incorrectly detected silence');xlabel('(b)   audio stream (second)');ylabel('Signal Amplitude');


% figure;scatter(E,EE) % C EE ZC RO SF
% hold on
% tt = find(flags == 1);
% scatter(E(tt),EE(tt),'r')
% xlabel('ShortTimeEnergy');ylabel('EE');
% title('filtered feature')
% figure;hist(E,10)
% figure;hist(EE,10)

% tt = (flags == 1);
% figure;scatter3(E(~tt),EE(~tt)',ZC(~tt),'b');
% hold on
% scatter3(E(tt),EE(tt)',ZC(tt),'r')
% xlabel('ShortTimeEnergy');ylabel('EE');zlabel('ZC')
% title('filtered feature')
% legend('silence features', 'speech features');


% figure;
% subplot(3,2,1)
% plot(medfilt1(Eor,7)); title('SE');
% subplot(3,2,2)
% plot(medfilt1(EE,7)); title('EE');
% subplot(3,2,3)
% plot(medfilt1(Cor,7)); title('SC');
% subplot(3,2,4)
% plot(medfilt1(ZC,7)); title('ZC');
% subplot(3,2,5)
% plot(medfilt1(RO,7)); title('RO');
% subplot(3,2,6)
% plot(medfilt1(SF,7)); title('SF');

%%%%%%% SVM Train
% tt = (flags == 1);
% % trainf = [medfilt1(Eor,7) medfilt1(EE',7) medfilt1(Cor,7) medfilt1(ZC,7) medfilt1(RO',7) medfilt1(SF,7)];
% trainf = [medfilt1(Eor,7) medfilt1(EE',7) medfilt1(ZC,7)];
% silence_SVMStruct = svmtrain(trainf,tt);  %%% corresponds to .mat above


% figure;scatter(Eor,Cor)
% hold on
% scatter(Eor(tt),Cor(tt),'r')
% xlabel('ShortTimeEnergy');ylabel('SpectralCentroid');
% title('before filtered feature')

end

