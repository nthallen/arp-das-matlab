function h = ne_dstat( vars, ttl, varargin );
% h = ne_dstat( vars, varargin );
% vars is a cell array with columns for 'mnemonic', 'var' and 'bit'.
% The mnemonic is the bit mnemonic and bit is the
% bit number (0-7 or so). e.g.
% The var field contains the name of a TM variable.
% h = ne_dstat( { 'ALmpS', 'DS802', 1; 'BLmpS', 'DS802', 2 }, 'Bits' );
pat = [ getrundir filesep '*eng*.mat' ];
reqd = findvar( pat, vars{:,2});
args = ne_args(varargin{:});
offset = 1;
labels = {};
hh = [];
if ne_setup(reqd',args)
  for i = [1:size(vars,1)]
    arcvar = reqd{i};
    delim = max(findstr( arcvar, filesep ));
    if ~isempty(delim)
      arcvar = arcvar([delim+1:length(arcvar)]);
    end
    DS = evalin( 'base', [ arcvar '.' vars{i,2} ] );
    DT = evalin( 'base', [ arcvar '.T' ] );
    lDS = length(DS);
    DB = ((bitand(DS,2^vars{i,3}) > 0 )-.5)*(-.8) + offset;
    v = find(diff(DB));
    if length(v) > 0
      v = ((v+1)*[1 1])';
      vv = v - [1 0]'*ones(1,size(v,2));
    else
      vv = [];
    end
    hh = [ hh plot( DT([1; v(:); lDS]), DB([1; vv(:); lDS]), 'k' ) ];
    hold on;
    labels{offset} = vars{i,1};
    offset = offset + 1;
  end
  hold off;
  set(gca, 'YTick', [1:offset-1], 'YTickLabel', cellstr(labels), ...
      'Ylim', [ .5 offset-.5 ], 'Ydir', 'reverse' );
  ne_cleanup( ttl, 'UTC Seconds since Midnight', '', {}, args );
end
if nargout > 0, h = hh; end
