function mystem(m)
  hold on;
  colors = {'red','blue','cyan','green','magenta'};
  for r = 1:size(m,1)
    colorIndex = mod(r-1, length(colors))+1;
    stem(m(r,:), 'Color', colors{colorIndex});
  end
  hold off;