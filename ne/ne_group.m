function figout = ne_group( printopt, ttl, varargin );
% figout = ne_group( printopt, ttl, plotname, ... );
% printopt is a cell array of options to be passed to
% each of the plot routines.
% ttl is the title
% plotname (and subsequent args) are the names of m-files
% that will invoke timeplot() or compatible routines.
%
% Future option:
% figout = ne_group( printopt, ttl, weights, plotname, ... );
%  where weights must be a vector as long as the number of plots
%  named.

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

nplots = length(varargin);
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
  call = [ varargin{ix} ...
      '( ''Position'', position, HideX{:},' ...
      'YPos, Ttl{:}, Fig{:}, printopt{:} );' ];
  eval( call );
end
cstack = dbstack;
caller = cstack(2).name;
cm = getuprop(gcf,'EditMenu');
uimenu(cm,'Label', [ ttl ' Group' ], 'Callback', [ 'edit ' caller ] );

figout = gcf;
