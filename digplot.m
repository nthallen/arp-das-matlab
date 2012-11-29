function h = digplot( x, var, bits )
% h = digplot( x, var, bits )
% Plot the bits of var relative to x
offset = 1;
labels = {};
hh = [];
DT = time2d(x);
for i = [1:length(bits)]
  if any(~isnan(var))
    lDS = length(var);
    DB = ((bitand(var,2^bits(i)) > 0 )-.5)*(-.8) + offset;
    v = find(diff(DB));
    if length(v) > 0
      v = ((v+1)*[1 1])';
      vv = v - [1 0]'*ones(1,size(v,2));
    else
      vv = [];
    end
    hh = [ hh plot( DT([1; v(:); lDS]), DB([1; vv(:); lDS]), 'k' ) ];
    hold on;
  else
    hh = [ hh plot( NaN, NaN ) ];
  end
  labels{offset} = num2str(bits(i));
  offset = offset + 1;
end
hold off;
set(gca, 'YTick', [1:offset-1], 'YTickLabel', cellstr(labels), ...
  'Ylim', [ .5 offset-.5 ], 'Ydir', 'reverse' );
xlabel('UTC Seconds since Midnight');
if nargout > 0, h = hh; end
