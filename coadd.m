function [ aout, bout, cout ] = coadd( a, b, c );
% cobj = coadd(); % create cobj
% cobj = coadd( cobj, x, y ); % Add into cobj
% [x,y] = coadd(cobj); % calculate final coadd
% [x,y,n] = coadd(cobj); % return bin counts also
% cobj is a struct containing x, y and n
% x input must round to monotonically changing integral values.
if nargin == 0
  aout.x = [];
  aout.y = [];
  aout.n = [];
  aout.total = 0;
  return
end
if nargin == 1
  aout = a.x;
  bout = a.y ./ (a.n*ones(1,size(a.y,2)));
  if nargout > 2
      cout = a.n;
  end
  return
end

% must be the 3-arg form
cobj = a;
x = round(b);
y = c;
if size(x,1) == 1 & size(x,2) > 1
  x = x';
  y = y';
end
dx = sign(diff(x));
if any(dx==0) | any(diff(dx)~=0)
  error('x input to coadd must round to monotonically changing integers');
end
if size(x,1) ~= size(y,1)
  error('y must have as many points as x');
end
if length(cobj.x) == 0
  cobj.x = (min(x):max(x))';
  cobj.y = zeros(size(cobj.x,1),size(y,2));
  cobj.n = zeros(size(cobj.x));
  xi = x - min(cobj.x) + 1;
  cobj.y(xi,:) = y;
  cobj.n(xi) = ones(size(x));
else
  xi = x - min(cobj.x) + 1;
  if min(xi) < 1
    % pad cobj on the top
    npad = 1-min(xi);
    cobj.x = [ (min(x):min(cobj.x)-1)'; cobj.x ];
    cobj.n = [ zeros(npad,1); cobj.n ];
    cobj.y = [ zeros(npad,size(cobj.y,2)); cobj.y ];
    xi = xi + npad;
  end
  if max(xi) > length(cobj.x)
    % pad cobj on the bottom
    npad = max(xi) - length(cobj.x);
    cobj.x = [ cobj.x; (max(cobj.x)+1:max(x))' ];
    cobj.n = [ cobj.n; zeros(npad,1) ];
    cobj.y = [ cobj.y; zeros(npad,size(cobj.y,2)) ];
  end
  cobj.y(xi,:) = cobj.y(xi,:) + y;
  cobj.n(xi) = cobj.n(xi) + 1;
end
cobj.total = cobj.total+1;
aout = cobj;
return;
