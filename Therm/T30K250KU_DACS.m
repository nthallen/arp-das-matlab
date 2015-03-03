% Generates Calibration for
%   30K Thermistor
%   Pulled Up by
%   75K Resistor
%   Pulled Up to VRef
% Specifically for DACS 16-bit
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 250e3;
Cts = 4096 * Rt ./ (Rt + R );
Desc='30K Thermistor pulled up by 250K';
gencal2( T, Cts, 8, 'T30K250KU', Desc, 'AI_T30K250KU, CELCIUS' );
