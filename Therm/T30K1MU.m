% Generates Calibration for
%   30K Thermistor
%   Pulled Up by 1M Resistor
%   Pulled Up to VRef
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 1e6;
Cts = 4096 * Rt ./ (Rt + R );
Desc='30K Thermistor pulled up by 1M';
gencal2( T, Cts, 16, 'T30K1MU', Desc, 'AD12_T30K1MU, CELCIUS', 2 );
