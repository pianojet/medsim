function norm_hist = getHist(features, mus, mappingType, options)
  % features, mus, mappingType, options

  if ~isfield(options, 'normalize') options.normalize = true;
  end
  
  totalClusters = size(mus,1);

  %%% distance, euclidean
  %???? pdist / pdist2 ????
  allDists = [];
  for k = 1:totalClusters
    d = sum((features-repmat(mus(k,:), size(features,1),1)).^2,2);
    % dist = sqrt(sum(  ((features - repmat(mus(k,:), size(features,1),1)).^2)  , 2));
    % dist = sum(  ((features - repmat(mus(k,:), size(features,1),1)).^2)*inv(sigmas(:,:,k))  , 2);
    % d = pdist2(features, repmat(mus(k,:), size(features,1),1), 'euclidean');

    allDists = [allDists, d];
  end


  if strcmp(mappingType, 'fuzzy')
    mm = 2/(1.3-1); % degree of fuzziness, m = 1.3
    for k = 1:size(allDists,1)
        tp = 1./(allDists(k,:)+eps).^mm;
        temp_hist(k,:) = tp/(sum(tp)+eps);
    end
    temp_hist = sum(temp_hist,1);


  elseif strcmp(mappingType, 'probabilistic')
    mm = 2/(1.3-1); % degree of fuzziness, m = 1.3
    for k = 1:size(allDists,1)
      yita = median(allDists(k,:));
      mmvalue = 1./(1+(allDists(k,:)/yita).^(2/(mm-1)));
      t = isnan(mmvalue);
      mmvalue(t) = 1;
      temp_hist(k,:) = mmvalue;
    end
    temp_hist = sum(temp_hist,1);


  else %%%%%  'crisp'
    group = 1:size(mus, 1);
    idx = [];
    for k = 1:size(allDists,1)
      [cx,ix] = min(allDists(k,:));
      idx(k,:) = group(ix);
    end
    temp_hist = hist(idx,1:size(mus, 1));
  end


  norm_hist = [];
  v = temp_hist;
  sum_v = sum(v);

  normalized = [];
  for c = 1:size(v,2)
    n = v(c)/sum_v;
    normalized = [normalized n];
  end

  if options.normalize
    norm_hist = normalized;

  else
    % norm_hist = [];
    % v = temp_hist;
    % sum_v = sum(v);

    % normalized = [];
    % for c = 1:size(v,2)
    %   n = v(c)/sum_v;
    %   normalized = [normalized n];
    % end
    % norm_hist = round(normalized*10000);
    norm_hist = round(normalized .* 100000);
  end