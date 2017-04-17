function [sum_along_dir, sum_along_scale, sum_avg] = GaborFeaturePostProcess( feature )
%GABORFEATUREPROCESS2 
% sum all column vectors first
% input: feature--Gabor features by gaborfunction, with H*W*Dir*Scale
% output: sum_im_dir_depth_scale--sum feature by W and then store into dir*H*scale
%         sum_im_scale_depth_dir--sum feature by W and then store into scale*H*dir
%         sum_im_dir_col        --sum feature by scale(W) and then store into dir*H


fdim = size(feature);
if length(fdim) == 4
    row = fdim(end);
    col = fdim(end-1);
elseif length(fdim) == 3
    row = 1;
    col = fdim(end);
elseif length(fdim) == 2
    row = 1;
    col = 1;
else
    error('dimension is not suitable for display');    
end

sum_along_dir = zeros(fdim(1), fdim(2), col); % x* y * dir
for k = 1:col
    temp = 0;
    for kk = 1:row
        temp = temp + feature(:,:,k,kk);
    end
    sum_along_dir(:,:,k) = temp;%/max(temp(:));
end

sum_along_scale = zeros(fdim(1), fdim(2), row); % x * y * scale
for k = 1:row
    temp = 0;
    for kk = 1:col
        temp = temp + feature(:,:,kk,k);
    end
    sum_along_scale(:,:,k) = temp;%/max(temp(:))
end

temp = sum(sum_along_dir,3);% x*y
sum_avg = temp;%/max(temp(:))

end

