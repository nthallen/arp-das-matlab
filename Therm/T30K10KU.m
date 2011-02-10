% Generates Calibration for
%   30K Thermistor
%   Pulled Up by
%   10K Resistor
%   Pulled Up to VRef
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 10e3;
Cts = 4096 * Rt ./ (Rt + R );
Desc='30K Thermistor pulled up by 10K';
gencal2( T, Cts, 1, 'T30K10KU', Desc, 'AD12_T30K10KU, CELCIUS', 2 );
