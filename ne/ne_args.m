function args = ne_args( varargin );
% args = ne_args(...);
% Arguments to standard graph routines:
% 'HoldFig' Don't create a new figure
% 'Title', 'txt' Display the specified title instead
% 'Title, ''     Don't display a title
% 'Position', [ x y w h ] Create axes at this position
% 'HideX'
% 'YRight'/'YLeft'
% 'Printing'
% 'Zoom'
% 'Linetype', '-' Specify line type
% 'Explode'
% 'Select', [...] Array of indices.
%
% Output is a structure with elements:
% args.HoldFig = 0/1
% args.Title set if specified
% args.Position set if specified
% args.HideX = 0/1
% args.YPos = 'left'/'right'
% args.printing = 1/0
% args.linetype = '-'
% args.zoom = 0/1  Whether to turn zoom on instead of uicontext menu
% args.explode = 0/1  Separate out individual elements of a timeplot
% args.select = [] vector of indices into vector of variables (and legends)

args.HoldFig = 0;
args.HideX = 0;
args.YPos = 'left';
args.printing = 0;
args.zoom = 0;
args.linetype = '-';
args.explode = 0;
args.select = [];
i = 1;
while i <= length(varargin)
  arg = varargin{i};
  if strcmp(arg,'HoldFig')
    args.HoldFig = 1;
  elseif strcmp(arg,'HideX')
    args.HideX = 1;
  elseif strcmp(arg,'YRight')
    args.YPos = 'right';
  elseif strcmp(arg,'YLeft')
    args.YPos = 'left';
  elseif strcmp(arg,'Printing')
	args.printing = 1;
  elseif strcmp(arg,'Position')
    i = i+1;
    args.Position = varargin{i};
  elseif strcmp(arg,'Title')
    i = i+1;
    args.Title = varargin{i};
  elseif strcmp(arg,'Zoom')
    args.zoom = 1;
  elseif strcmpi(arg,'Linetype');
    i = i+1;
    args.linetype = varargin{i};
  elseif strcmp(arg,'Explode')
    args.explode = 1;
  elseif strcmpi(arg,'Select');
    i = i+1;
    args.select = varargin{i};
  end
  i = i + 1;
end
if args.printing == 0
  [h,fig] = gcbo;
  if length(fig) == 1
	k = findobj(fig,'tag','PrtPrview');
	if length(k) == 1
	  v = get(k,'Value');
	  if v == 0
	    args.printing = 1;
	  end
	end
  end
end
