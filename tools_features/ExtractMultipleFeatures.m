function [ features ] = ExtractMultipleFeatures(d, sr, featureList, options)
% given featureList, extract the features
% (same frame length!, MIR not good here)


% featureList = {'mfcc';'dmfcc';'ddmfcc';
%                'plp'; 'dplp'; 'ddplp';
%                'lpcc';'dlpcc';'ddlpcc';
%                'rasplp';'feacalcmfcc';'feacalcplp';
%                'STE'; 'ZCR'; 'SpectralCentroid';'EnergyEntropy';
%                'SpectralEntropy';'SpectralFlux';'SpectralRollOff';
%                'Gabor'}
%
% all features are N*d
% other features may used later: tonal_chromagram_centroid, tonal_chromagram


if (nargin < 4)
    options = struct;
end

if ~isfield(options, 'wintime'); options.wintime = 0.02;
end
wintime = options.wintime;

if ~isfield(options, 'hoptime'); options.hoptime = 0.02;
end
hoptime = options.hoptime;

if ~isfield(options, 'numcep'); options.numcep = 13;
end
numcep = options.numcep;

if ~isfield(options, 'lifterexp'); options.lifterexp = 0.6;
end

if ~isfield(options, 'sumpower'); options.sumpower = 1;
end

if ~isfield(options, 'preemph'); options.preemph = 0.97;
end

if ~isfield(options, 'dither'); options.dither = 0;
end

if ~isfield(options, 'minfreq'); options.minfreq = 133;
end

if ~isfield(options, 'maxfreq'); options.maxfreq = 8000;
end

if ~isfield(options, 'nbands'); options.nbands = 25;
end

if ~isfield(options, 'bwidth'); options.bwidth = 1.0;
end

if ~isfield(options, 'dcttype'); options.dcttype = 2;
end

if ~isfield(options, 'fbtype'); options.fbtype = 'mel'; % 'bark' | 'mel' | 'htkmel' | 'fcmel'
end

if ~isfield(options, 'usecmp'); options.usecmp = 0;
end

if ~isfield(options, 'modelorder'); options.modelorder = 0;
end


% warning off
% if nargin < 3
%     featureList = {'mfcc'};
%     wintime = 0.02;
%     hoptime = 0.02;
%     numcep = 12;
% end
% if nargin < 4
%     wintime = 0.02;
%     hoptime = 0.02;
%     numcep = 12;
% end

if size(d,2)~=1
    d = d(:,1);
end

if ~isempty(findcell(featureList, {'all'}))
    featureList = {'mfcc';'melfcc';'dmfcc';'ddmfcc';
                   'plp'; 'dplp'; 'ddplp';
                   'lpcc';'dlpcc';'ddlpcc';
                   'teo';
                   'rasplp';'feacalcmfcc';'feacalcplp';
                   'STE'; 'ZCR'; 'SpectralCentroid';'EnergyEntropy';
                   'SpectralEntropy';'SpectralFlux';'SpectralRollOff'; 'Gabor';
                    'dynamics_rms';...
                    'fluctuation_peak';...
                    'fluctuation_centroid';...
                    'rhythm_onsets';...
                    'rhythm_attack_time';...
                    'rhythm_attack_slope';...
                    'rhythm_tempo';...
                    'spectral_s';...
                    'spectral_centroid';...
                    'spectral_brightness';...
                    'spectral_spread';...
                    'spectral_skewness';...
                    'spectral_kurtosis';...
                    'spectral_rolloff95';...
                    'spectral_rolloff85';...
                    'spectral_spectentropy';...
                    'spectral_flatness';...
                    'spectral_roughness';...
                    'spectral_irregularity';...
                    'spectral_mfcc';...
                    'spectral_dmfcc';...
                    'spectral_ddmfcc';...
                    'timbre_zerocross';...
                    'timbre_lowenergy';...
                    'timbre_spectralflux';...
                    'tonal_hcdf';...
                    'tonal_mode';...
                    'tonal_keyclarity';...
                    'tonal_chromagram_peak';...
                    'tonal_chromagram_centroid';... % good
                    'tonal_chromagram'};
end


features = [];
if ~isempty(findcell(featureList, {'mfcc'})) || ~isempty(findcell(featureList, {'dmfcc'})) || ~isempty(findcell(featureList, {'ddmfcc'}))

    tp = mfcc(d, sr);
    features.mfcc = tp';

    if ~isempty(findcell(featureList, {'dmfcc'}))
        features.dmfcc = getDeltas(features.mfcc);
    end
    if ~isempty(findcell(featureList, {'ddmfcc'}))
        features.ddmfcc = getDeltas(getDeltas(features.mfcc,5),5);
    end
end

if ~isempty(findcell(featureList, {'melfcc'})) || ~isempty(findcell(featureList, {'dmfcc'})) || ~isempty(findcell(featureList, {'ddmfcc'}))

    % tp = melfcc(d, sr, 'minfreq', 100, 'maxfreq', 16000, 'numcep', numcep, 'wintime', wintime, 'hoptime', hoptime);
    tp = melfcc(d, sr, ...
      'wintime', options.wintime, ...
      'hoptime', options.hoptime, ...
      'numcep', options.numcep, ...
      'lifterexp', options.lifterexp, ...
      'sumpower', options.sumpower, ...
      'preemph', options.preemph, ...
      'dither', options.dither, ...
      'minfreq', options.minfreq, ...
      'maxfreq', options.maxfreq, ...
      'nbands', options.nbands, ...
      'bwidth', options.bwidth, ...
      'dcttype', options.dcttype, ...
      'fbtype', options.fbtype, ...
      'usecmp', options.usecmp, ...
      'modelorder', options.modelorder);
    features.melfcc = tp';

    if ~isempty(findcell(featureList, {'dmfcc'}))
        features.dmfcc = getDeltas(features.melfcc);
    end
    if ~isempty(findcell(featureList, {'ddmfcc'}))
        features.ddmfcc = getDeltas(getDeltas(features.melfcc,5),5);
    end
end




if ~isempty(findcell(featureList, {'plp'})) || ~isempty(findcell(featureList, {'dplp'})) || ~isempty(findcell(featureList, {'ddplp'}))
    tp = rastaplp(d, sr, 0, numcep-1, wintime, hoptime);
    features.plp = tp';
    if ~isempty(findcell(featureList, {'dplp'}))
        features.dplp = getDeltas(features.plp);
    end
    if ~isempty(findcell(featureList, {'ddplp'}))
        features.ddplp = getDeltas(getDeltas(features.plp,5),5);
    end
end

if ~isempty(findcell(featureList, {'lpcc'})) || ~isempty(findcell(featureList, {'dlpcc'})) || ~isempty(findcell(featureList, {'ddlpcc'}))
    features.lpcc = getLPCC(d, sr, numcep, wintime, hoptime);
    if ~isempty(findcell(featureList, {'dlpcc'}))
        features.dlpcc = getDeltas(features.lpcc);
    end
    if ~isempty(findcell(featureList, {'ddlpcc'}))
        features.ddlpcc = getDeltas(getDeltas(features.lpcc,5),5);
    end
end

if ~isempty(findcell(featureList, {'teo'})) % not good
    teo = getEnergyOperator(sr);
    features.teo = teo;
end

if ~isempty(findcell(featureList, {'rasplp'})) % not good
    tp = rastaplp(d, sr, 1, numcep-1, wintime, hoptime);
    features.rasplp = tp';
end

if ~isempty(findcell(featureList, {'feacalcmfcc'}))
    tp = melfcc(d*5.5289, sr, 'lifterexp', 0.6, 'nbands', 19, 'dcttype', 4, 'maxfreq', 16000, 'wintime', wintime, 'hoptime', hoptime, 'numcep', numcep, 'fbtype', 'fcmel', 'preemph', 0);
    features.feacalcmfcc = tp';
end

if ~isempty(findcell(featureList, {'feacalcplp'}))
    tp = melfcc(d*5.5289, sr, 'lifterexp', 0.6, 'nbands', 21, 'dcttype', 1, 'maxfreq', 16000, 'wintime', wintime, 'hoptime', hoptime, 'numcep', numcep, 'fbtype', 'bark', 'preemph', 0, 'modelorder', numcep-1, 'usecmp', 1);
    features.feacalcplp = tp';
end

if ~isempty(findcell(featureList, {'STE'}))
    features.STE = getShortTimeEnergy(d, round(wintime*sr), round(hoptime*sr));
end

if ~isempty(findcell(featureList, {'ZCR'})) % so so
    features.ZCR = getzcr(d, round(wintime*sr), round(hoptime*sr), sr);
end

if ~isempty(findcell(featureList, {'SpectralCentroid'})) % not good
    features.SpectralCentroid = getSpectralCentroid(d, round(wintime*sr), round(hoptime*sr), sr);
end

if ~isempty(findcell(featureList, {'EnergyEntropy'}))
    warning off
    tp = getEnergy_Entropy_Block(d, round(wintime*sr), round(hoptime*sr), 10);
    features.EnergyEntropy = tp';
end

if ~isempty(findcell(featureList, {'SpectralEntropy'}))
    features.SpectralEntropy = getSpectralEntropy(d, round(wintime*sr), round(hoptime*sr), 256, 64);
end

if ~isempty(findcell(featureList, {'SpectralFlux'})) % not good
    features.SpectralFlux = getSpectralFlux(d, round(wintime*sr), round(hoptime*sr), sr);
end

if ~isempty(findcell(featureList, {'SpectralRollOff'})) % not good
    tp = getSpectralRollOff(d, round(wintime*sr), round(hoptime*sr), 0.80, sr);
    features.SpectralRollOff = tp';
end

if ~isempty(findcell(featureList, {'Gabor'}))
    [GaborF, GaborS] = GaborAudioFeatures(d, sr, 'wintime', wintime, 'hoptime', hoptime, 'numcep', numcep);
    features.Gabor = GaborF;
%     features.Gabor = GaborS.GaborMelAvg';
end


% features from mirtoolbox
% combined from AudioFeatureExtractByUSERinit.m
% and AudioFeatureExtractByUSER.m
mirtoolboxlist = {'dynamics_rms';...
                    'fluctuation_peak';...
                    'fluctuation_centroid';...
                    'rhythm_onsets';...
                    'rhythm_attack_time';...
                    'rhythm_attack_slope';...
                    'rhythm_tempo';...
                    'spectral_s';...
                    'spectral_centroid';...
                    'spectral_brightness';...
                    'spectral_spread';...
                    'spectral_skewness';...
                    'spectral_kurtosis';...
                    'spectral_rolloff95';...
                    'spectral_rolloff85';...
                    'spectral_spectentropy';...
                    'spectral_flatness';...
                    'spectral_roughness';...
                    'spectral_irregularity';...
                    'spectral_mfcc';...
                    'spectral_dmfcc';...
                    'spectral_ddmfcc';...
                    'timbre_zerocross';...
                    'timbre_lowenergy';...
                    'timbre_spectralflux';...
                    'tonal_hcdf';...
                    'tonal_mode';...
                    'tonal_keyclarity';...
                    'tonal_chromagram_peak';...
                    'tonal_chromagram_centroid';... % good
                    'tonal_chromagram'};
for i = 1:length(featureList)
    if findcell(mirtoolboxlist, featureList(i))
        a = miraudio(d,sr);
        fram = mirframe(a,0.025,'s', 0.01, 's');
        feat = ExtractFeaturesByUSER(featureList(i), fram);
        f = mirgetdata(feat);
        tmpfeature = mir2struct(f, featureList(i));
        features = setfield(features,featureList{i},getfield(tmpfeature,featureList{i}));
    end
end

%disp('feature extraction is finished!');

end

