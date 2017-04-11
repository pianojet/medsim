function mus = getMus(features, classCount, numClusters)

% % deprecated




%   data = [];
%   sigmas = [];
%   mus = [];
%   all_C = [];
%   all_Idx = [];

%   % just in case we don't have enough features to get numClusters centers (fcm returns NaN)
%   sizef = size(features,1);
%   while sizef < numClusters
%     features = [features; features];
%     sizef = size(features,1);
%   end

%   for c = 1:classCount
%     [ctrs, U] = fcm(features, numClusters, [2.0]);
%     mus = [mus; ctrs];
%   end
