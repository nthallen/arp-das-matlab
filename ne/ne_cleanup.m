function ne_cleanup( ttl, xlab, ylab, leg, args );
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
if length(cstack) >= 3
  caller = cstack(3).name;
  ci = 1+max(findstr('\', caller));
  cj = length(caller)-2;
  callfunc = caller([ci:cj]);
  cm = getuprop(gcf,'EditMenu');
  uimenu(cm,'Label', ttl, 'Callback', [ 'edit ' caller ] );
  cm = getuprop(gcf,'ExpandMenu');
  uimenu(cm,'Label', ttl, 'Callback', [ callfunc '(''Zoom'');' ] );
end
if isfield( args, 'Title' )
  ttl = args.Title;
end
texts = [];
if length(ttl) > 0
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
if length(leg) > 0
  nlegend(leg{:});
end
