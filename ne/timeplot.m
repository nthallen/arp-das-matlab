function h = timeplot(vars,ttl,ylab,leg,varargin);
% timeplot( vars, ttl, ylab, leg, ... );
% vars is a cell array of variable names
% ttl is the title of the plot
% ylab is the y label
% leg is a cell array of legends for the vars
% ... is any other 'standard' ne_args options
pat = [ getrundir filesep '*eng*.mat' ];
reqd = findvar( pat, vars{:});
args = ne_args(varargin{:});
if ne_setup(reqd',args)
  p = 'plot(';
  for i = [1:length(vars)]
    if i > 1
      p = [ p ',' ];
    end
    [ ref, Tref ] = ne_varref( vars, reqd, i );
    p = [ p Tref ',' ref ',''' args.linetype, '''' ];
  end
  p = [ p ')' ];
  % fprintf(1,'%s\n',p);
  hh = evalin('base',p);
  if nargout > 0, h = hh; end
  grid;
  
  ne_cleanup( ttl, 'UTC Seconds since Midnight', ylab, leg, args );
end
