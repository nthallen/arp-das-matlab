function a = GetSteinhart( C, R )
% a = GetSteinhart(C, R)
% Returns the Steinhart/Hart coefficients for the specified points
% The Steinhart/Hart equation is:
%   C + 273.15 = 1 ./ ( a(0) + a(1)logR + a(2)logR^3 )
% C and R must be column vectors.
KI = 1./(C+273.15);
logR = log(R);
A = [ ones(size(R)) logR logR.^3 ];
a = A\KI;