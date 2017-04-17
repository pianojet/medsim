function [ mainFeature, GaborF ] = GaborAudioFeatures( data, sr, varargin )
% compute the Gabor audio features
%
% Input is the audio signal. (data, sr)
% Output is the Gabor features. (GaborF.GaborCc, GaborF.GaborMel, GaborF.GaborSp, GaborF.Spec, etc...)
%
% check "GetAudioGaborFeatures.m" and "trainingdataLoadandGaborFeatureExtraction.m"
%        "test_main_Gabor_GMM_Audio.m", "test_main_Gabor_Audio.m"
%
% After GaborAudioFeatures function, there should be another function:"GaborFeaturePostProcess"
%
% Integrated into previous feature extraction: "ExtractMultipleFeatures.m"
%
% 2013-07-02

GaborF = [];

% Parse out the optional arguments
[f_set, theta_set, re_size, GaborSize, wintime, hoptime, numcep] = ...
    process_options(varargin, 'freq', 1:1:4, 'theta', 0:pi/4:pi*3/4, ...
                're_size', 0, 'GaborSize', 0, 'wintime', 0.025, 'hoptime', 0.01, 'numcep', 12);

[cep1, aspec1, spec1] = melfcc(data,sr,'wintime',wintime,'hoptime', hoptime, 'numcep',numcep, 'nbands',40);
GaborF.Spec = spec1;

%[GaborFeature1 Gab] = Gabor_Feature1(spec1,f_set,theta_set,'Gabor', 17);
[GaborFeature1 Gab] = Gabor_Feature1(spec1,f_set,theta_set,'Gabor', 0);
GaborF.GaborSp = GaborFeature1;

MelFeature1 = Mel_Feature(GaborFeature1, sr);
GaborF.GaborMel = MelFeature1;

CepFeature1 = Cep_Feature(MelFeature1, numcep, sr);
GaborF.GaborCc = CepFeature1;

[GaborF.GaborMelAlongDir, GaborF.GaborMelAlongScale, GaborF.GaborMelAvg] = GaborFeaturePostProcess(GaborF.GaborMel);
[GaborF.GaborCcAlongDir, GaborF.GaborCcAlongScale, GaborF.GaborCcAvg] = GaborFeaturePostProcess(GaborF.GaborCc);

mainFeature = GaborF.GaborCcAvg';

displayopt = 0;
if displayopt == 1
    figure;subplot(221); specgram(data,256,sr); title('original spectrum');
%     figure;subplot(221); spectrogram(data,length(hamming(round(wintime*sr))),0.5*length(hamming(round(wintime*sr))),256,sr); title('original spectrum');
    subplot(222); imagesc(10*log10(spec1)); axis xy; title('power spectrum');
    subplot(223); imagesc(10*log10(aspec1)); axis xy; title('critical band analysis');
    subplot(224); imagesc(cep1); axis xy; title('mfcc cepectrum');

%     spectrumDisplay(GaborF.Spec, 'spectrum', f_set, theta_set);
%     GaborDisplay(Gab, 'GaborFunction', f_set, theta_set);
%     spectrumDisplay(GaborF.GaborSp, 'GaborSp', f_set, theta_set);
%     spectrumDisplay(GaborF.GaborMel, 'GaborMel', f_set, theta_set);
    spectrumDisplay(GaborF.GaborCc, 'GaborCc', f_set, theta_set);
%     spectrumDisplay(GaborF.GaborCcAlongDir, 'GaborCcAlongDir', f_set, theta_set);
%     spectrumDisplay(GaborF.GaborCcAlongScale, 'GaborCcAlongScale', f_set, theta_set);
%     spectrumDisplay(GaborF.GaborCcAvg, 'GaborCcAvg', f_set, theta_set);

end



end

