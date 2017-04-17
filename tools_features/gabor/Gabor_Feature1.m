function [GaborFeature Gab] = Gabor_Feature1(I,f_set,theta_set, featuretype, GaborSize)

% example refer to gabor_example.m

% [row, col, theta, scale] 4-D tensor

psi     = [0 pi/2];
gamma   = 0.5;
bw      = 1; % in mines data, choose 0.1

if strcmp(featuretype, 'Gabor')
    GaborFeature = zeros(size(I,1),size(I,2),length(theta_set),length(f_set));
elseif strcmp(featuretype, 'GaborD')
    GaborFeature = zeros(size(I,1),size(I,2),length(f_set));
elseif strcmp(featuretype, 'GaborS')
    GaborFeature = zeros(size(I,1),size(I,2),length(theta_set));
elseif strcmp(featuretype, 'GaborSD')
    GaborFeature = zeros(size(I,1),size(I,2));
else
    error('Please specify feature type, Gabor, GaborS, GaborD, or GaborSD');
end

for k = 1:length(f_set)
    for kk = 1:length(theta_set)
        % generate Gabor function gb
        gb = gabor_fn(bw,gamma,psi(1),f_set(k),theta_set(kk), GaborSize) + 1i * gabor_fn(bw,gamma,psi(2),f_set(k),theta_set(kk), GaborSize);
        Gab(kk,k).gb = gb;
        xx = abs(imfilter(I, gb, 'symmetric'));
        
        if strcmp(featuretype, 'Gabor')
            GaborFeature(:,:,kk,k) = xx./max(xx(:));
        elseif strcmp(featuretype, 'GaborD')
            GaborFeature(:,:,k) = GaborFeature(:,:,k) + xx./max(xx(:));
        elseif strcmp(featuretype, 'GaborS')
            GaborFeature(:,:,kk) = GaborFeature(:,:,kk) + xx./max(xx(:));
        elseif strcmp(featuretype, 'GaborSD')
            GaborFeature = GaborFeature + xx./max(xx(:));
        end
        
        
%         spectrumDisplay(GaborFeature, 'GaborFeature1', f_set, theta_set);

    end
end
% GaborDisplay(Gab, 'GaborFunction', f_set, theta_set);
end