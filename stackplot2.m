function stackplot2( X, Y, C )
% stackplot2( X, Y [, C] );

nfuncs = size(Y,2);
SY = cumsum([ zeros(size(Y,1),1) Y ]')';
rX = flipud(X);
if nargin < 3
  C = rainbow(nfuncs);
end
for i = nfuncs:-1:1
  Y = SY(:,i+1);
  rY = flipud(SY(:,i));
  fill([ X; rX; X(1) ], [ Y; rY; Y(1) ], C(i,:));
  hold on;
end
hold off;
xlim([min(X) max(X)]);
