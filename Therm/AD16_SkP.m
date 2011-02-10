% Generates Calibration for
%   Thermometrics 100K Thermistor
%   Pulled Up by 475K Resistor
%   Pulled Up to VRef
c0 = -0.03415668;
c1 = 0.1359041;
c2 = 0.05873713;
c3 = 0.0152044;
c6 = 6.21e-6;
V = [ c6 0 0 c3 c2 c1 0 ];
X = [0:100]'/100;
P = 1 ./ ( c0 + 1 ./ polyval( V, X ) );
Cts = 32768*X;
Desc='Sk_P';
gencal2( P, Cts, 1, 'AD16_Sk_P', Desc, 'AD6_Sk_P, mBAR' );
