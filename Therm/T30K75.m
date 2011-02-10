% Generates Calibration for
%   30K Thermistor
%   Pulled Up by
%   75K Resistor
%   Pulled Up to VRef
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 75e3;
Cts = 4096 * Rt ./ (Rt + R );
Desc='30K Thermistor pulled up by 75K';
gencal( T, Cts, .1, 1, 'T30K75.TMC', Desc, 'AD12_T30K, CELCIUS' );
