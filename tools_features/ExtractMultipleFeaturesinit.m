function [ feature ] = ExtractMultipleFeaturesinit( featureList )


if ~isempty(findcell(featureList, {'all'}))
	featureList = {'mfcc';'melfcc';'dmfcc';'ddmfcc';
               'plp'; 'dplp'; 'ddplp';
               'lpcc';'dlpcc';'ddlpcc';
               'teo';
               'rasplp';'feacalcmfcc';'feacalcplp';
               'STE'; 'ZCR'; 'SpectralCentroid';'EnergyEntropy';
               'SpectralEntropy';'SpectralFlux';'SpectralRollOff';
               'Gabor';
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

feature = [];
for k = 1:length(featureList)
    eval(['feature.' featureList{k} '=[];']);
end

end

