% Generates Calibration for
%   30K Thermistor
%   Pulled Up by 475K Resistor
%   Pulled Up to VRef
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 475e3;
Cts = 65536 * Rt ./ (Rt + R ) - 32768;
Desc='30K Thermistor pulled up by 475K';
gencal2( T, Cts, 1, 'T30K475K', Desc, 'AD12_T30K, CELCIUS' );
