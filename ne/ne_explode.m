function ne_explode(vars,ttl,ylab,leg,varargin);

% Arguments to standard graph routines:
% 'HoldFig' Don't create a new figure
% 'Title', 'txt' Display the specified title instead
% 'Title, ''     Don't display a title
% 'Position', [ x y w h ] Create axes at this position
% 'HideX'
% 'YRight'/'YLeft'

Fig = {};
if length(ttl) > 0
  Ttl = { 'Title', ttl };
else
  Ttl = {};
end
HideX = { 'HideX' };

nplots = length(vars);
ypos = { 'YRight', 'YLeft' };

for ix = [1:nplots]
  position = nsubpos( nplots, 1, ix, 1 );
  if ix > 1
    Ttl = { 'Title', '' };
    Fig = { 'HoldFig' };
  end
  if ix == nplots
    HideX = {};
  end
  YPos = ypos{mod(ix,2)+1};
  % I could call timeplot back directly, but I'm probably
  % better off calling timeplot's caller with 'Select'
  call = [ varargin{ix} ...
      '( ''Position'', position, HideX{:},' ...
      'YPos, Ttl{:}, Fig{:}, printopt{:} );' ];
  eval( call );
end

figout = gcf;
