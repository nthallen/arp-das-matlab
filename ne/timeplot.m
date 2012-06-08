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
n_plots = 0;
ne_setup(reqd',args);
p = 'plot(';
for i = [1:length(vars)]
  [ ref, Tref ] = ne_varref( vars, reqd, i );
  if n_plots > 0
    p = [ p ',' ];
  end
  p = [ p Tref ',' ref ',''' args.linetype, '''' ];
  n_plots = n_plots+1;
end
if n_plots > 0
  p = [ p ')' ];
  % fprintf(1,'%s\n',p);
  hh = evalin('base',p);
  grid;
else
  hh = [];
end
if nargout > 0, h = hh; end

ne_cleanup( ttl, 'UTC Seconds since Midnight', ylab, leg, args, hh );
