% Generates Calibration for
%   10K Thermistor
%   Pulled Up by 75K Resistor
%   Pulled Up to VRef
load TM4.mat; % contains T, Rrat
R25 = 10e3;
Rt = Rrat * R25;
R  = 75e3;
Cts = 4096 * Rt ./ (Rt + R );
Desc='10K Thermistor pulled up by 75K';
gencal2( T, Cts, 1, 'T10K75KU', Desc, 'AD12_T10K75KU, CELCIUS',2 );
