function [V,W] = findcell(x,y)

% findcell.m
% - find cell elements y in a cell aray x
% - x and y must be cell array
%
% - CREATED & DEVELOPED BY TAE HOON YANG 2007 HiLAiT



warning off
V = []; W = [];
if ~isempty(x)
    for k = 1:length(x)
        for kk = 1:length(y)
            if ~isempty(strmatch(x{k},y{kk},'exact'))
                V = [V;k];
                W(k,kk) = 1;
            else
                W(k,kk) = 0;
            end
        end
    end
end
if isempty(y)
   V=[]; 
   W=[1:1:length(x)]'; 
else
   if length(y) == 1
      W = find(W==0);
   else
      W = find(sum(W')==0)';
   end
end
warning on