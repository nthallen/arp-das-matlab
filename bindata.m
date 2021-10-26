function [xbins,ybins] = bindata( x, y, xbin, method )
if nargin < 4
  method = 'range';
end
if size(x,2) ~= 1 && size(x,2) ~= size(y,2)
  error('x must be a column vector or the same size as y');
end
if size(x,1) ~= size(y,1)
  error('x and y must have the same number of rows');
end
if size(xbin,2) ~= 1
  xbin = xbin';
end
if size(xbin,2) ~= 1
  error('xbin must be a column vector');
end
if ~ all( diff(xbin)>0 )
  error('xbin values must be increasing');
end
if strcmp( method, 'range' )
  nbins = size(xbin,1)-1;
  xbins = NaN * zeros(nbins,size(y,2));
  ybins = NaN * zeros(nbins,size(y,2));
  row = ones(1,size(y,2));
  nonan = ~isnan(y);
  y(isnan(y)) = 0;
  if size(x,2) == 1
    xM = x * row;
  else
    xM = x;
  end
  for i = 1:nbins
    v = (xM >= xbin(i,1) & xM < xbin(i+1,1)) & nonan;
    binsum = sum(v);
    xsum = sum(xM.*v);
    ysum = sum(y.*v);
    vx = find(binsum>0);
    xbins(i,vx) = xsum(1,vx)./binsum(1,vx);
    ybins(i,vx) = ysum(1,vx)./binsum(1,vx);
  end
elseif strcmp( method, 'value' )
  nbins = size(xbin,1);
  xbins = NaN * zeros(nbins,size(y,2));
  ybins = NaN * zeros(nbins,size(y,2));
  row = ones(1,size(y,2));
  nonan = ~isnan(y);
  y(isnan(y)) = 0;
  if size(x,2) == 1
    xM = x * row;
  else
    xM = x;
  end
  for i = 1:nbins
    v = (xM == xbin(i,1)) & nonan;
    binsum = sum(v);
    xsum = sum(xM.*v);
    ysum = sum(y.*v);
    vx = find(binsum>0);
    xbins(i,vx) = xsum(1,vx)./binsum(1,vx);
    ybins(i,vx) = ysum(1,vx)./binsum(1,vx);
  end
else
  error('Unrecognized method');
end
