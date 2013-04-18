function f = ne_dialg( ttl, func, lvl, prt, callback, title, varargin )
% Set up a dialog window with an appropriate title
% f = ne_dialg( 'title' [, adhocgrps] );
% f = ne_dialg( f, 'newcol' );
% f = ne_dialg( f, 'add', lvl, prt, callback, title, varargin );
% f = ne_dialg( f, 'newtab', title );
xpad = 10;
ypad = 2;
ytop = 20;
xindent = 20;
boxdim = 14; % size of a checkbox
boxwid = 20; % width required for checkbox (add to extent)
if nargin == 0
  error('Arguments required for ne_dialg()');
elseif isstr(ttl)
  f.fig = figure;
  if nargin < 2
      func = 0;
  end
  f.adhocgrps = func;
  cstack = dbstack;
  caller = cstack(2).name;
  uimenu('Label', 'EditUI', 'Callback', [ 'edit ' caller ] );
  % f.ax = axes( 'Position', [0 0 1 1], 'Visible', 'off' );
  % h = text( .5, 1, ttl, 'VerticalAlignment', 'Top', ...
  %  'HorizontalAlignment', 'center' );
  f.figbg = get(f.fig,'Color');
  f.ttlh = uicontrol(f.fig,'Style','text','String',ttl,'units','pixels', ...
      'BackgroundColor', f.figbg, 'FontSize', 10, 'FontWeight','bold');
  ttlp = get(f.ttlh,'Extent');
  f.ttlwid = ttlp(3);
  f.xmax = 0;
  f.figpos = get(f.fig,'Position');
  f.x = xpad;
  f.ymax = f.figpos(4);
  f.count = 1;
  ttlp(1) = (f.figpos(3) - f.ttlwid)/2;
  ttlp(2) = f.ymax - ttlp(4) - ypad;
  set(f.ttlh,'Position',ttlp);
  set(f.fig, 'Name', ttl, 'NumberTitle', 'off' );
  f.panel = [];
  f.y = ttlp(2) - ypad;
  f.ymax = f.y;
  f.ymin = f.y;
  return;
elseif ~isfield(ttl,'fig')
  error('Invalid first argument to ne_dialg();');
else
  f = ttl;
end
if strcmp(func,'add');
  % lvl determines indentation
  % prt < 0 creates a radiobutton for run selection
  % prt >= 0 creates a pushbutton for graph selection
  %   prt > 0 means the graph is selected by default
  if prt < 0
    style = 'Radiobutton';
    bbg = f.panelbg;
  else
    style = 'Pushbutton';
    bbg = f.figbg;
  end
  if isempty(f.panel)
      parent = f.fig;
  else
      parent = f.panel(end);
  end
  h = uicontrol(parent, 'Style', style, 'String', title, ...
         'Callback', callback, 'HorizontalAlignment', 'left', ...
         'BackgroundColor', bbg, varargin{:} );
  e = get(h, 'Extent' );
  if prt < 0, e(3) = e(3) + boxdim; end
  % dims = ceil(e([3:4])*1.1);
  dims = e(3:4) + [ 3 3 ];
  f.y = f.y - dims(2) - ypad;
  if lvl == 0
    f.y = f.y - 2*ypad;
  end
  x = f.x + lvl * xindent;
  if (f.adhocgrps && prt == 0) || (prt >= 0 && f.adhocgrps == 0)
    uicontrol(parent,'Style','Checkbox','Tag',callback, ...
      'Position', [ f.x f.y boxdim boxdim ], 'Value', prt*f.count, ...
      'Max', f.count );
    x = x + boxwid;
  elseif prt < 0
    set(h,'Value', 2+prt );
  end
  xmax = x + dims(1) + xpad;
  if xmax > f.xmax
    f.xmax = xmax;
  end
  p = [ x f.y dims ];
  set(h,'Position', p );
  
  if f.y < f.ymin
    f.ymin = f.y;
  end
  f.count = f.count + 1;
elseif strcmp(func,'newtab')
  ttl = lvl;
  if isempty(f.panel)
    f.panelpos = [0 0 f.figpos(3) f.ymin];
    f.panelmenu = uimenu(f.fig,'Label','Panel');
    f.panelbg = [.8 .8 1];
    f.panelmenus = [];
    % f.ymax = f.panelpos(4) - ytop;
    f.ymin = f.panelpos(4); % too high, but will get corrected
    f.pxmax = 0;
    vis = 'On';
    checked = 'On';
  else
    if f.xmax > f.pxmax
      f.pxmax = f.xmax;
    end
    vis = 'Off';
    checked  = 'Off';
  end
  f.xmax = 0;
  panel = uipanel(f.fig,'units','pixels','Position',f.panelpos,...
      'BackgroundColor', f.panelbg, 'Visible',vis);
  h = uicontrol(panel,'Style','text','String',ttl,'units','pixels', ...
      'BackgroundColor', f.panelbg, 'FontSize', 10, 'FontWeight','bold');
  ttlp = get(h,'Extent');
  ttlwid = ttlp(3);
  ttlp(1) = (f.panelpos(3)+ttlp(3))/2;
  ttlp(2) = (f.panelpos(4)-ttlp(4)-2*ypad);
  set(h,'Position',ttlp);
  f.panel(end+1) = panel;
  f.panelmenus(end+1) = uimenu(f.panelmenu,'Label',ttl, ...
      'Callback', sprintf('ne_setpanel(%d);',length(f.panel)), ...
      'Checked', checked);
  f.ymax = ttlp(2);
  f.y = f.ymax;
  f.x = xpad;
  guidata(f.fig,f);
elseif strcmp(func,'newcol')
  % find all the elements in the present column
  % and adjust their width so they line up nicely
  if isempty(f.panel)
      parent = f.fig;
  else
      parent = f.panel(end);
  end
  k = findobj(parent,'style','pushbutton');
  for i = k';
    p = get(i,'Position');
    if p(1) >= f.x && p(1) < f.xmax
      p(3) = f.xmax - xpad - p(1);
      set(i,'Position', p);
    end
  end
  f.x = f.xmax + xpad;
  f.y = f.ymax;
elseif strcmp(func,'resize')
  % Make value for this always <= 0 so it won't be picked up by
  % ne_print
  if ~isempty(f.panel)
    f.ymin = f.ymin - 2*ypad;
    f.pymin = f.ymin;
    if f.pxmax > f.xmax
        f.xmax = f.pxmax;
    end
  end
  f.prtfmt = uicontrol(f.fig,'Style','Checkbox','Tag','PrtPrview', ...
	   	'Max', 0, 'Min', -1, 'Value', -1, ...
  		'String', 'Format for Printing' );
  ce = get(f.prtfmt, 'Extent' );
  y = f.ymin - ce(4) - 3*ypad;
  f.ymin = y;
  if ce(4) < boxdim
    ce(4) = boxdim;
  end
  ce = [ xpad y boxwid 0 ] + [ 0 0 ce(3) ce(4) ];
  set(f.prtfmt, 'Position', ce );
  
  if f.adhocgrps
      f.prtsel = uicontrol(f.fig,'String','Graph Selected', ...
          'Callback','ne_adhoc;');
  else
      f.prtsel = uicontrol(f.fig,'String','Print Selected', ...
          'Callback','ne_print;');
  end
  e = get(f.prtsel,'Extent');
  x = (f.xmax - e(3))/2;
  y = f.ymin;
  dims = ceil(e(3:4)*1.1);
  if ce(1)+ce(3)+xpad >= x
    x = ce(1)+ce(3)+xpad;
  end
  if x+dims(1) > f.xmax
    f.xmax = x + dims(1);
  end
  set(f.prtsel,'Position',[x y dims]);
  f.ymin = f.ymin - ypad;
  if f.ttlwid > f.xmax; f.xmax = f.ttlwid; end
  f.xmax = f.xmax + xpad;
  % fp = get(gcf,'Position');
  % f.figpos(2) = f.figpos(2) - (f.ymax-f.ymin-f.figpos(4));
  f.figpos(2) = f.figpos(2) + f.ymin;
  f.figpos(3) = f.xmax;
  f.figpos(4) = f.figpos(4) - f.ymin;
  set(f.fig,'Position',f.figpos,'Resize','Off');
  % Adjust x,y of each uicontrol
  if isempty(f.panel)
      c = findobj(f.fig,'type','uicontrol')';
      for ctrl = c
          p = get(ctrl,'Position');
          if strcmp(get(ctrl,'Style'),'text')
              p(1) = (f.xmax - p(3))/2;
          end
          p(2) = p(2) - f.ymin;
          set(ctrl,'Position',p);
      end
  else
      %adjust ypos of f.ttlh, f.prtfmt, f.prtsel by -f.ymin
      for ctrl = [f.ttlh f.prtfmt f.prtsel]
          p = get(ctrl,'Position');
          if strcmp(get(ctrl,'Style'),'text')
              p(1) = (f.xmax - p(3))/2;
          end
          p(2) = p(2) - f.ymin;
          set(ctrl,'Position',p);
      end
      %adjust size of each panel
      f.panelpos(2) = f.pymin - f.ymin;
      f.panelpos(3) = f.xmax;
      f.panelpos(4) = f.panelpos(4) - f.pymin;
      set(f.panel,'Position',f.panelpos);
      %adjust ypos of each child uicontrol by -f.pymin 
      for panel = f.panel
        c = findobj(panel,'type','uicontrol')';
        for ctrl = c
          p = get(ctrl,'Position');
          if strcmp(get(ctrl,'Style'),'text')
              p(1) = (f.xmax - p(3))/2;
          end
          p(2) = p(2) - f.pymin;
          set(ctrl,'Position',p);
        end
      end
  end
else
  error('Invalid option to ne_dialg');
end
