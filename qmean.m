function A = qmean( B, n );
l = length(B);
l = l - mod(l,n);
A = mean(reshape(B([1:l]),n,l/n))';
