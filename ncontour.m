function ax = ncontour(xrange,yrange,data,crange)
% ax = ncontour(xrange,yrange,data,crange);
% xrange and yrange correspond to columns and rows of data.
% crange are the extrema for the range of colors.
f = figure;
M = colormap(f);
img = ((data - crange(1))/(crange(end)-crange(1))) * size(M,1) + 1;
ax = axes('parent',f);
image(xrange([1 end]), yrange([1 end]),img,'parent',ax);
set(ax,'Ydir','normal');
cb = colorbar;
ticklabels = interp1([0 1], crange([1 end]), [0 .5 1]);
ticks = interp1(crange([1 end]), [1 size(M,1)+1], ticklabels);
cb.Ticks = ticks;
cb.TickLabels = ticklabels;
