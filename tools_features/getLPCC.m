function [ cc ] = getLPCC(d, sr, numcep, win, hop)
% extract LPCC features
% output:
%     cc: lpcc features with frames*numcep
%
% example:
% [d,sr] = wavread('.\Systems\audioFeatureExtraction\silenceRemoval\me1.wav');
% 
% len=round(sr*0.025); 
% [f,t,w]=enframe(d,hamming(len,'periodic'),round(sr*0.01));
% cc = [];
% for k = 1:size(f,1)
%     AR = lpccovar(f(k,:), 13);
%     cc(k,:)=lpcar2cc(AR);
% end
% figure;imagesc(cc');title('lpcc')


[f,t,w]=enframe(d,hamming(round(sr*win),'periodic'),round(sr*hop));
cc = zeros(size(f,1), numcep);
for k = 1:size(f,1)
    AR = lpccovar(f(k,:), numcep);
    cc(k,:)=lpcar2cc(AR);
end


end

