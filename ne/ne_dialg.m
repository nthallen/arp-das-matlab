function f = ne_dialg( ttl, func, lvl, prt, callback, title, varargin )
% Set up a dialog window with an appropriate title
% f = ne_dialg( 'title' );
% f = ne_dialg( f, 'newcol' );
% f = ne_dialg( f, 'add', lvl, prt, callback, title, varargin );
xpad = 10;
ypad = 2;
ytop = 20;
xindent = 20;
boxdim = 14;
boxwid = 20;
if nargin == 0
  error('Arguments required for ne_dialg()');
elseif nargin == 1
  f.fig = figure;
  cstack = dbstack;
  caller = cstack(2).name;
  uimenu('Label', 'EditUI', 'Callback', [ 'edit ' caller ] );
  f.ax = axes( 'Position', [0 0 1 1], 'Visible', 'off' );
  h = text( .5, 1, ttl, 'VerticalAlignment', 'Top', ...
    'HorizontalAlignment', 'center' );
  u = get(h, 'Units');
  set(h,'Units', 'pixels');
  p = get(h,'Extent');
  set(h,'Units',u);
  f.ttlwid = p(3);
  f.xmax = 0;
  p = get(f.fig,'Position');
  f.x = xpad;
  f.ymax = p(4);
  f.y = f.ymax - ytop;
  f.ymin = f.y;
  f.count = 1;
  set(f.fig, 'Name', ttl, 'NumberTitle', 'off' );
  return;
elseif ~isfield(ttl,'fig')
  error('Invalid first argument to ne_dialg();');
else
  f = ttl;
end
if strcmp(func,'add');
  
  if prt < 0
    style = 'Radiobutton';
  else
    style = 'Pushbutton';
  end
  h = uicontrol( f.fig, 'Style', style, 'String', title, ...
         'Callback', callback, 'HorizontalAlignment', 'left', varargin{:} );
  e = get(h, 'Extent' );
  if prt < 0, e(3) = e(3) + boxdim; end
  % dims = ceil(e([3:4])*1.1);
  dims = e(3:4) + [ 3 3 ];
  f.y = f.y - dims(2) - ypad;
  if lvl == 0
    f.y = f.y - 2*ypad;
  end
  x = f.x + boxwid + lvl * xindent;
  xmax = x + dims(1) + xpad;
  if xmax > f.xmax
    f.xmax = xmax;
  end
  p = [ x f.y dims ];
  set(h,'Position', p );
  if prt >= 0
    uicontrol(f.fig,'Style','Checkbox','Tag',callback, ...
      'Position', [ f.x f.y boxdim boxdim ], 'Value', prt*f.count, ...
      'Max', f.count );
  else
    set(h,'Value', 2+prt );
  end
  if f.y < f.ymin
    f.ymin = f.y;
  end
  f.count = f.count + 1;
elseif strcmp(func,'newcol')
  % find all the elements in the present column
  % and adjust their width so they line up nicely
  k = findobj(f.fig,'style','pushbutton');
  for i = k';
    p = get(i,'Position');
    if p(1) >= f.x && p(1) < f.xmax
      p(3) = f.xmax - xpad - p(1);
      set(i,'Position', p);
    end
  end
  f.x = f.xmax + xpad;
  f.y = f.ymax - ytop;
elseif strcmp(func,'resize')
  % Make value for this always <= 0 so it won't be picked up by
  % ne_print
  k = uicontrol(f.fig,'Style','Checkbox','Tag','PrtPrview', ...
	   	'Max', 0, 'Min', -1, 'Value', -1, ...
  		'String', 'Format for Printing' );
  ce = get( k, 'Extent' );
  y = f.ymin - ce(4) - 3*ypad;
  f.ymin = y;
  if ce(4) < boxdim
    ce(4) = boxdim;
  end
  ce = [ xpad y boxwid 0 ] + [ 0 0 ce(3) ce(4) ];
  set( k, 'Position', ce );
  
  h = uicontrol(f.fig,'String','Print Selected','Callback','ne_print;');
  e = get(h,'Extent');
  x = (f.xmax - e(3))/2;
  y = f.ymin;
  dims = ceil(e(3:4)*1.1);
  if ce(1)+ce(3)+xpad >= x
    x = ce(1)+ce(3)+xpad;
  end
  if x+dims(1) > f.xmax
    f.xmax = x + dims(1);
  end
  set(h,'Position',[x y dims]);
  f.ymin = f.ymin - ypad;
  if f.ttlwid > f.xmax; f.xmax = f.ttlwid; end
  f.xmax = f.xmax + xpad;
  fp = get(gcf,'Position');
  fp(2) = fp(2) - (f.ymax-f.ymin-fp(4));
  fp(3) = f.xmax; fp(4) = f.ymax - f.ymin;
  set(gcf,'Position',fp);
  % Adjust x,y of each uicontrol
  c = findobj(f.fig,'type','uicontrol')';
  for ctrl = c
    p = get(ctrl,'Position');
    p(2) = p(2) - f.ymin;
    set(ctrl,'Position',p);
  end
else
  error('Invalid option to ne_dialg');
end
