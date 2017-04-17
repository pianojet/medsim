function GaborFeature = Gabor_Feature(I,Sx,Sy,f_set,theta_set)

% [row, col, theta, scale] 4-D tensor

GaborFeature = zeros(size(I,1),size(I,2),length(theta_set),length(f_set));
for k = 1:length(f_set)
    for kk = 1:length(theta_set)
        [G,gabout] = gaborfilter1(I,Sx,Sy,f_set(k),theta_set(kk));
        GaborFeature(:,:,kk,k) = gabout;
        Gab(:,:,kk,k) = G;
    end
end
GaborDisplay(Gab, 'GaborFunction', f_set, theta_set);
end