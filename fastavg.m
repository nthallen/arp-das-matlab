function avgout = fastavg( data, binsize )
% function avgout = fastavg( data, binsize )
% data is a row or column vector
% binsize is an integer specifying how many points to average
% avgout is a column vector
[x y]=size(data);
if x>1
   data=data';
end
small = length(data) + 1;
big = binsize * ceil(length(data)/binsize);
data(small:big) = nan * (small:big);
p = reshape( data, binsize, length(data)/binsize);
so = sum(~isnan(p));
i = find(isnan(p));
p(i) = 0 * i;
soz = ( so == 0 );
avgout = ( sum(p)./ ( so + soz ) )';
avgout(find(soz)) = NaN;
