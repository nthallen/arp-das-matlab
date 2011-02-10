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
gencal2( T, Cts, 8, 'T10K75KU', Desc, 'AI_T10K, CELCIUS',2 );
