% This file is useful simply to calculate a mean temperature for an arbitrary set of
% bit values. The input data is a fixed set of temperatures and separate bit values for
% each thermistor. This file inverts that to provide temps for a fixed set of bit values
% based on linear interpolation. (It would be interesting to see if the graph of temp vs
% mean bits is any different from the graph of mean temp vs bits) The answer is no! This
% did not improve anything. Using the mean bit values is actually better because it covers
% more ground.

% I will ignore the last two temperature points, since there is no bits data for them
% I accomplish this by truncating T_actual and then dynamically truncating each _bit
% vector to the length of T_actual (called rows)
%
% SF1F2_bit is garbage... may need to figure out how to eliminate it from the sample
%
load lowt_cal;
rows=length(T_actual);
Bit=zeros(rows,14);
for i=[ 1 2 ]
  for j=[0:6 ]
    k = i*7 + j - 6;
    cmd = sprintf('Bit(:,%d) = SF%dF%d_bit(1,[1:rows])'';', k, i, j );
    fprintf( 1, '%s\n', cmd );
    eval( cmd );
  end
end

% eliminate the bad thermistor

Bit=Bit(:,[ 1 2 4:14 ]);
[ rows, cols ] = size( Bit );

bit0 = max(min(Bit));
bit1 = min(max(Bit));
bits = (bit1 - bit0) * [0:20]'/20 + bit0;
T = zeros(length(bits), cols);
for i = [1:cols]
  T(:,i) = interp1( Bit(:,i), T_actual', bits );
end
Tmean = mean(T')';
Bmean = mean(Bit')';
plot(Tmean, bits, T_actual, Bmean, Tmean, bits, '+', T_actual, Bmean, 'x' );
