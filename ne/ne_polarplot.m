function h = ne_polarplot(vars,ttl,ylab,leg,varargin);
% ne_polarplot( vars, ttl, ylab, leg, ... );
% vars is a cell array of variable names
% ttl is the title of the plot
% ylab is the y label
% leg is a cell array of legends for the vars
% ... is any other 'standard' ne_args options
if length(vars) ~= 2
    error(sprintf('ne_polarplot requires two variables, received %d',length(vars)));
end
pat = [ getrundir filesep '*eng*.mat' ];
reqd = findvar( pat, vars{:});
args = ne_args(varargin{:});
n_plots = 0;
ne_setup(reqd',args);
ref1 = ne_varref(vars, reqd, 1);
ref2 = ne_varref(vars, reqd, 2);
p = ['polar(',ref1,'*pi/180,',ref2,',''.'')'];
hh = evalin('base',p);
grid;
if nargout > 0, h = hh; end

ne_cleanup( ttl, strrep(vars{1},'_','\_'), ylab, leg, args, hh );
