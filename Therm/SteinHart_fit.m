function [a0,a1,a3] = SteinHart_fit(R, K)
% a = SteinHart_fit(R, K);
% [a0, a1, a3] = SteinHart_fit(R, K);
% A = SteinHart_fit(R, K);
%   Returns a 3-element vector
if isrow(R)
  R = R';
end
if isrow(K)
  K = K';
end
if length(R) ~= length(K)
  error('R and K must be the same length');
end
lR = log(R);
M = [ ones(length(R),1), lR, lR.^3];
A = M\(1./K);
if nargout <= 1
  a0 = A;
elseif nargout == 3
  a0 = A(1);
  a1 = A(2);
  a3 = A(3);
else
  error('Invalid number of output arguments');
end
