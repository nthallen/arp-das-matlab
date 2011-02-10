% Generates Calibration for
%   10K Thermistor
%   Pulled Up by 475K Resistor
%   Pulled Up to VRef
load TM4.mat; % contains T, Rrat
R25 = 10e3;
Rt = Rrat * R25;
R  = 475e3;
Cts = 65536 * Rt ./ (Rt + R ) - 32768;
Desc='10K Thermistor pulled up by 475K';
gencal2( T, Cts, 1, 'T10K475K', Desc, 'AD12_T10K, CELCIUS' );
