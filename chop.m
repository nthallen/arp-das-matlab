function c = chop( x );
% c = chop(x);
% Remove last row of x. Useful for plotting against a diff().
nr = size(x,1);
c = x(1:nr-1,:);