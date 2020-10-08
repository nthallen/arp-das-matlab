% Generates Calibration for
%   30K Thermistor
%   Pulled Up by
%   75K Resistor
%   Pulled Up to VRef
% Specifically for uDACS AD7770
load t30k.dat;
T  = t30k(:,1);
Rt = t30k(:,2);
R  = 75e3;
Cts = 65536 * Rt ./ (Rt + R );
Desc='uDACS 30K Thermistor pulled up by 75K';
gencal2( T, Cts, 2^7, 'T30K75KU_uDACS', Desc, 'uDACS_AI_T30K75KU, uDACS_CELCIUS' );
