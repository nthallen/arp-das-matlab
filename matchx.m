function matchx(ax);
% matchx([ax]);
% Set xlimits on all axes in ax (except for legends and backgrounds)
% to match the current axes. If ax is omitted, matches all axes on
% the current figure.
if nargin<1
  ax = findobj(gcf,'type','axes')';
end
xl = xlim;
for i=ax
  % Tag 'legend' is set by legend and nlegend
  % Tab 'background' is set by ne_setup
  tag = get(i,'Tag');
  if ~strcmp(tag,'legend') & ~strcmp(tag,'background')
    set(i,'XLim',xl,'YLimmode','auto');
  end
end
shg;
