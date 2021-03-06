function ne_cleanup( ttl, xlab, ylab, leg, args, hh )
% ne_cleanup2( ttl, xlab, ylab, leg, args );
% leg = { 'label', 'label', ... };
% leg = { [ x y xo, yo ], 'label', ... };
% args is output from ne_args();

printing = args.printing;
fontsize = 12;
fg = gcf;
ax = gca;
if printing
  FU = get(fg,'PaperUnits');
  set(fg,'PaperUnits','points');
  PP = get(fg,'PaperPosition');
  set(fg,'PaperUnits',FU);
  % assume axis units are normalized? Doesn't matter for
  % aspect ratio, but it does for axis labels!
  AP = get(ax,'Position');
  set(ax,'PlotBoxAspectRatio',[ AP(3)*PP(3) AP(4)*PP(4) 1 ], ...
      'FontUnits','normalized','FontSize',fontsize/(AP(4)*PP(4)) );
end

% Do this before we obliterate the ttl
cstack = dbstack;
sti = min( 3, length(cstack) );
if sti > 1
  callfunc = cstack(sti).name;
  cm = getappdata(gcf,'EditMenu');
  uimenu(cm,'Label', ttl, 'Callback', [ 'ne_edit ' callfunc ] );
  cm = getappdata(gcf,'ExpandMenu');
  uimenu(cm,'Label', ttl, 'Callback', [ callfunc '(''Zoom'');' ] );
end
if isfield( args, 'Title' )
  ttl = args.Title;
end
texts = [];
if ~isempty(ttl)
  title(ttl);
  texts = [ texts get(ax,'Title') ];
  set(fg,'Name',ttl,'Numbertitle','off');
end
if args.HideX == 0
  texts = [ texts xlabel(xlab) ];
else
  set(ax,'Xticklabel', [] );
end
texts = [ texts ylabel(ylab) ];
set(ax,'Yaxislocation',args.YPos);
if isfield(args,'Xlim')
  set(ax, 'Xlim', args.Xlim );
end
if printing
  for t = texts
    set(t,'FontUnits','normalized','FontSize',fontsize/(AP(4)*PP(4)));
  end
end
if ~isempty(leg)
  nlegend(leg{:});
end
custfunc = ['cust_' callfunc];
if exist(custfunc,'file') == 2
    call = eval(['@' custfunc]);
    call(hh);
    % eval([custfunc '(hh);']);
end
