% Generates Calibration for
%   30K Thermistor
%   Pulled Up by 1M Resistor
%   Pulled Up to VRef
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
Ru  = 75e3;
Cts = 65536 * Rt ./ (Rt + Ru ) - 32768;
Desc='30K Thermistor pulled up by 75K';
gencal2( T, Cts, 1, 'Herc_T30K', Desc, 'Herc_T30K, CELCIUS', 2 );
