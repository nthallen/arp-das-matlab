function success = ne_setup(reqd,args);
%ne_setup.m Create the designated axis based on the args
%structure (produced from ne_args()).

% Output is a structure with elements:
% args.HoldFig = 0/1
% args.Title set if specified
% args.Position set if specified
% args.HideX = 0/1
% args.YPos = 'left'/'right'
% args.printing = 1/0

success = 1;
printing = args.printing;
fontsize = 12;

for i=reqd
  j = char(i);
  delim = max(findstr( j, filesep ));
  if isempty(delim)
    fdir = '.';
  else
    fdir = j([1:delim-1]);
    j = j([delim+1:length(j)]);
  end
  if length(j) == 0
    success = 0;
  else
    jloaded = evalin('base', [ 'exist(''' j ''', ''var'')' ] );
    if jloaded
      jloaddir = evalin('base', [ j '.fdir' ]);
      jloaded = strcmp( jloaddir, fdir );
    end
	if jloaded ~= 1 & exist( [ fdir filesep j '.mat']) == 2
	  evalin( 'base', [ 'global ' j ';' ] );
	  eval( [ 'global ' j '; ' j ' = load( ''' fdir filesep j '.mat' ''');' ] );
	  if eval( [ 'isfield( ' j ', [ ''T'' j ] )' ] )
		T = eval( [ j '.T' j ] );
		T0 = floor(T(1)/(86400)) * 86400;
		eval( [ j '.T = T - T0; ' j '.fdir = fdir;' ] );
	  elseif eval( [ 'isfield( ' j ', ''Time'' )' ] )
		T = eval( [ j '.Time' ] );
		T0 = floor(T(1)/(86400)) * 86400;
		eval( [ j '.T = T - T0; ' j '.fdir = fdir;' ] );
      else
        error(['Unable to locate time in matrix: ' j ]);
	  end
	end
	jloaded = evalin('base', [ 'exist(''' j ''', ''var'')' ] );
	if jloaded ~= 1
	  warning(['Unable to load required matrix: ' j ] );
	  success = 0;
	end
  end
end

% if success == 0
%   return
% end

if args.HoldFig == 0
  fg = figure;
  orient tall;
  ax = axes('position',[0 0 1 1],'Visible','off');
  h1 = text( 1, .98, getrun );
  set(h1,'Verticalalignment','top','Horizontalalignment','right');
  h2 = text( 0, 0.04, [ 'Plotted ' date ] );
  set(h2,'Verticalalignment','bottom');
  set(ax,'tag','background');
  if printing
    FU = get(fg,'PaperUnits');
    set(fg,'PaperUnits','points');
    PP = get(fg,'PaperPosition');
    set(fg,'PaperUnits',FU);
    set(ax,'PlotBoxAspectRatio',[ PP(3) PP(4) 1 ] );
    for t = [ ax h1 h2 ]
      set(t,'FontUnits','normalized','FontSize',fontsize/PP(4));
    end
  end
  set( fg, 'UserData', getrundir, 'tag', 'eng_ui' );
  addzoom;
  h3 = uimenu('label','Edit');
  setuprop( fg, 'EditMenu', h3 );
  h4 = uimenu('label','Expand');
  setuprop( fg, 'ExpandMenu', h4 );
else
  fg = gcf;
end
if isfield(args, 'Position')
  ax = axes('position', args.Position );
else
  ax = axes;
end
