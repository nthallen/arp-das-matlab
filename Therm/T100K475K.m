% Generates Calibration for
%   Thermometrics 100K Thermistor
%   Pulled Up by 475K Resistor
%   Pulled Up to VRef
load TM457.mat;
v = [ 5:length(T) ];
T = T(v);
Rt = RR7(v)*100e3;
R  = 475e3;
Cts = ( 65536 * Rt ./ (Rt + R ) ) - 32684;
Desc='100K Thermistor pulled up by 475K';
gencal2( T, Cts, 1, 'AD16_T100K', Desc, 'AD16_T100K, CELCIUS' );
