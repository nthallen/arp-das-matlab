function c = rainbow(m)
%RAINBOW Shades of the rainbow colormap.
%   RAINBOW(M) returns an M-by-3 matrix containing a "RAINBOW" colormap.
%   RAINBOW, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(rainbow)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.
if nargin < 1, m = size(get(gcf,'colormap'),1); end
roygbiv = [
  0    1     0  0
  0.01 1   0.4  0
  1    1   1    0
  1.99 0.4 1    0
  2    0   1    0
  2.01 0   1    0.4
  2.99 0   0.2  1
  3    0   0    1
  3.01 0.3 0    1
  4    1   0    1 ];

v = [0:m-1]'/(m-1);
x = roygbiv(:,1);
x = x/max(x);
c = interp1(x,roygbiv(:,[2:4]),v);
