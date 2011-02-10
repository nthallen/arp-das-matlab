% Generates Calibration for
%   Thermometrics 100K Thermistor
%   Pulled Up by 475K Resistor
%   Pulled Up to VRef
load C00385.dat;
T = C00385(:,1);
Rt = C00385(:,2);
Rser = 1210;
V = 1e-3 * ( Rt + Rser );
Cts = ( 65536 * V/5 ) - 32684;
Desc='RTD with series 1.21K Resistor';
gencal2( T, Cts, 1, 'AD16_RTD', Desc, 'AD16_RTD, CELCIUS' );
