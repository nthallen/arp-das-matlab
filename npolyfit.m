function V = npolyfit(X,Y,n);
% V = npolyfit(X, Y, n );
% Like polyfit, except n is a vector of exponent values
% for which coefficients should be fit. All other terms
% are set to zero.
A = zeros(length(X), length(n));
for i = [1:length(n)]
  A(:,i) = X.^n(i);
end
v = A\Y;
V = zeros(1,max(n)+1);
V(max(n)-n+1) = v;
