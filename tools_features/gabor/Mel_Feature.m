function MelFeature = Mel_Feature(GaborFeature, sr)

% Mel filter applied to 4-D Gabor feature

[row, col, di, sc] = size(GaborFeature);
MelFeature = zeros(40, col, di, sc); % 40 = nbands
for k = 1:di
    for kk = 1:sc
        MelFeature(:,:,k,kk) = audspec(GaborFeature(:,:,k,kk), sr, 40, 'mel', 0, sr/2, 1, 1); % Third para. is 40
    end
end




end